import 'dart:async'; // [추가] 타이머 사용을 위해 필요
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AzureSttService {
  final String subscriptionKey = dotenv.env['AZURE_SUBSCRIPTION_KEY'] ?? "";
  final String region = dotenv.env['AZURE_REGION'] ?? "koreacentral";

  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;

  // ----------------------------------------------------------
  // ▼ [추가] 침묵 감지를 위한 변수들
  // ----------------------------------------------------------
  Timer? _amplitudeTimer; // 소리 크기 체크용 타이머
  Timer? _silenceTimer;   // 침묵 지속 시간 체크용 타이머

  // 침묵 기준 데시벨 (주변 소음에 따라 조절: 보통 -30.0 ~ -40.0)
  // 이 값보다 소리가 작으면 '침묵'으로 간주합니다.
  final double _silenceThreshold = -30.0;

  // 침묵 유지 시간 (이 시간 동안 말이 없으면 녹음 종료)
  final Duration _silenceDuration = const Duration(seconds: 1);

  // 침묵 감지 시 실행할 콜백 함수
  Function()? onSilenceDetected;
  // ----------------------------------------------------------

  /// 녹음 시작
  /// [onSilence]: 침묵이 감지되었을 때 실행할 함수 (선택 사항)
  Future<void> startRecording({Function()? onSilence}) async {
    // [추가] 콜백 등록
    this.onSilenceDetected = onSilence;

    if (!await _audioRecorder.hasPermission()) {
      print("❌ 마이크 권한이 없습니다.");
      return;
    }

    final Directory tempDir = await getTemporaryDirectory();
    _recordedFilePath = '${tempDir.path}/temp_audio.wav';

    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );

    final file = File(_recordedFilePath!);
    if (await file.exists()) {
      await file.delete();
    }

    await _audioRecorder.start(config, path: _recordedFilePath!);
    print("🎤 녹음 시작 (Path: $_recordedFilePath)");

    // [추가] 소리 크기 모니터링 시작
    _startAmplitudeMonitoring();
  }

  // ----------------------------------------------------------
  // ▼ [추가] 소리 크기 모니터링 및 침묵 감지 로직
  // ----------------------------------------------------------
  void _startAmplitudeMonitoring() {
    // 0.1초마다 소리 크기 체크
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      // 녹음 중이 아니면 타이머 종료
      if (!await _audioRecorder.isRecording()) {
        timer.cancel();
        return;
      }

      // 현재 소리 크기(dB) 가져오기
      final amplitude = await _audioRecorder.getAmplitude();
      final currentDb = amplitude.current;

      // print("🔊 현재 데시벨: $currentDb"); // 디버깅이 필요하면 주석 해제

      if (currentDb < _silenceThreshold) {
        // 소리가 기준치보다 작음 (침묵 상태)
        // 침묵 타이머가 돌고 있지 않다면 시작
        if (_silenceTimer == null || !_silenceTimer!.isActive) {
          _silenceTimer = Timer(_silenceDuration, () {
            print("🤫 1초간 침묵 감지됨! 녹음 자동 종료.");
            _stopMonitoring(); // 모니터링 중지
            if (onSilenceDetected != null) {
              onSilenceDetected!(); // 외부(ChatView)에 알림
            }
          });
        }
      } else {
        // 소리가 기준치보다 큼 (말하는 중)
        // 침묵 타이머가 돌고 있었다면 취소 (말을 계속 이어가고 있으므로)
        _silenceTimer?.cancel();
        _silenceTimer = null;
      }
    });
  }

  // 모니터링 타이머 정리 함수
  void _stopMonitoring() {
    _amplitudeTimer?.cancel();
    _silenceTimer?.cancel();
    _amplitudeTimer = null;
    _silenceTimer = null;
  }
  // ----------------------------------------------------------

  /// 녹음 중지 및 Azure 전송
  Future<String?> stopRecordingAndGetText() async {
    // [추가] 녹음이 끝나면 모니터링도 중지
    _stopMonitoring();

    if (!await _audioRecorder.isRecording()) return null;

    final path = await _audioRecorder.stop();
    if (path == null) {
      print("❌ 녹음 파일 생성 실패");
      return null;
    }

    print("⏹️ 녹음 종료. Azure로 전송 시작...");
    return await _sendToAzure(path);
  }

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
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded['RecognitionStatus'] == 'Success') {
          print("✅ Azure 인식 성공: ${decoded['DisplayText']}");
          return decoded['DisplayText'];
        } else {
          print("⚠️ 인식 실패 (Status: ${decoded['RecognitionStatus']})");
          return null;
        }
      } else {
        print("❌ Azure 서버 오류: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ 통신 오류: $e");
      return null;
    }
  }

  void dispose() {
    // [추가] 객체 소멸 시 타이머 정리
    _stopMonitoring();
    _audioRecorder.dispose();
  }
}