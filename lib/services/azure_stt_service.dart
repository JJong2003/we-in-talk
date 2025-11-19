import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AzureSttService {
  // .env 파일이 로드되지 않았을 때를 대비한 안전장치 추가
  final String subscriptionKey = dotenv.env['AZURE_SUBSCRIPTION_KEY'] ?? "";
  final String region = dotenv.env['AZURE_REGION'] ?? "koreacentral";

  // 최신 record 패키지는 AudioRecorder 클래스를 사용합니다.
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;

  /// 녹음 시작 (Azure 호환 포맷: 16k, Mono, WAV)
  Future<void> startRecording() async {
    // 권한 확인
    if (!await _audioRecorder.hasPermission()) {
      print("❌ 마이크 권한이 없습니다.");
      return;
    }

    final Directory tempDir = await getTemporaryDirectory();
    _recordedFilePath = '${tempDir.path}/temp_audio.wav';

    // [중요] Azure STT가 요구하는 정확한 오디오 포맷 설정
    const config = RecordConfig(
      encoder: AudioEncoder.wav, // WAV 필수
      sampleRate: 16000,         // 16000Hz 필수
      numChannels: 1,            // Mono(1) 필수
    );

    // 기존 파일이 있다면 삭제 (충돌 방지)
    final file = File(_recordedFilePath!);
    if (await file.exists()) {
      await file.delete();
    }

    // 파일로 녹음 시작
    await _audioRecorder.start(config, path: _recordedFilePath!);
    print("🎤 녹음 시작 (Path: $_recordedFilePath)");
  }

  /// 녹음 중지 및 Azure 전송 -> 텍스트 반환
  Future<String?> stopRecordingAndGetText() async {
    // 녹음 중이 아니면 리턴
    if (!await _audioRecorder.isRecording()) return null;

    // 녹음 중지 (저장된 파일 경로 반환)
    final path = await _audioRecorder.stop();

    if (path == null) {
      print("❌ 녹음 파일 생성 실패");
      return null;
    }

    print("⏹️ 녹음 종료. Azure로 전송 시작...");
    return await _sendToAzure(path);
  }

  /// Azure Speech REST API 호출
  Future<String?> _sendToAzure(String filePath) async {
    if (subscriptionKey.isEmpty) {
      print("❌ .env에 AZURE_SUBSCRIPTION_KEY가 설정되지 않았습니다.");
      return "API 키 오류";
    }

    final url = Uri.parse(
        "https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=ko-KR");

    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      final response = await http.post(
        url,
        headers: {
          "Ocp-Apim-Subscription-Key": subscriptionKey,
          "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
          "Accept": "application/json",
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위한 UTF-8 디코딩
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        // RecognitionStatus가 Success인 경우에만 텍스트 반환
        if (decoded['RecognitionStatus'] == 'Success') {
          print("✅ Azure 인식 성공: ${decoded['DisplayText']}");
          return decoded['DisplayText'];
        } else {
          print("⚠️ 인식 실패 (Status: ${decoded['RecognitionStatus']})");
          return null; // "NoMatch" 등
        }
      } else {
        print("❌ Azure 서버 오류: ${response.statusCode} / ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ 네트워크 통신 오류: $e");
      return null;
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}