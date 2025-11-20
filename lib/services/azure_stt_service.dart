// lib/services/azure_stt_service.dart

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

  /// 녹음 시작
  Future<void> startRecording() async {
    try {
      // 1. 권한 확인
      if (!await _audioRecorder.hasPermission()) {
        print("[AzureSTT] ❌ 마이크 권한이 거부되었습니다.");
        return;
      }

      final Directory tempDir = await getTemporaryDirectory();
      _recordedFilePath = '${tempDir.path}/temp_audio.wav';

      // 2. Azure 맞춤형 오디오 설정 (매우 중요)
      // Azure는 16kHz, Mono, PCM WAV 형식을 선호합니다.
      const config = RecordConfig(
        encoder: AudioEncoder.wav, // WAV 포맷
        sampleRate: 16000,         // 16000Hz (필수)
        numChannels: 1,            // Mono (필수)
        bitRate: 128000,
      );

      // 기존 파일 삭제
      final file = File(_recordedFilePath!);
      if (await file.exists()) {
        await file.delete();
      }

      // 녹음 시작
      await _audioRecorder.start(config, path: _recordedFilePath!);
      print("[AzureSTT] 🎤 녹음 시작됨 (파일 경로: $_recordedFilePath)");

    } catch (e) {
      print("[AzureSTT] ❌ 녹음 시작 중 에러: $e");
    }
  }

  /// 녹음 중지 및 전송
  Future<String?> stopRecordingAndGetText() async {
    try {
      if (!await _audioRecorder.isRecording()) {
        print("[AzureSTT] ⚠️ 녹음 중이 아닙니다.");
        return null;
      }

      // 녹음 중지
      final path = await _audioRecorder.stop();
      if (path == null) {
        print("[AzureSTT] ❌ 녹음 파일 경로가 null입니다.");
        return null;
      }

      // 3. 녹음된 파일 확인 (중요!)
      final file = File(path);
      if (!await file.exists()) {
        print("[AzureSTT] ❌ 녹음 파일이 생성되지 않았습니다.");
        return null;
      }

      final fileSize = await file.length();
      print("[AzureSTT] ⏹️ 녹음 종료. 파일 크기: $fileSize bytes");

      // 파일 크기가 너무 작으면(예: 1KB 미만) 녹음이 안 된 것임
      if (fileSize < 1000) {
        print("[AzureSTT] ⚠️ 경고: 녹음 파일이 너무 작습니다. (무음이거나 에뮬레이터 마이크 문제)");
      }

      // Azure로 전송
      return await _sendToAzure(path);

    } catch (e) {
      print("[AzureSTT] ❌ 녹음 중지 중 에러: $e");
      return null;
    }
  }

  /// Azure API 전송
  Future<String?> _sendToAzure(String filePath) async {
    if (subscriptionKey.isEmpty) {
      print("[AzureSTT] ❌ .env 키가 없습니다. AZURE_SUBSCRIPTION_KEY를 확인하세요.");
      return null;
    }

    final url = Uri.parse(
        "https://$region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=ko-KR");

    try {
      print("[AzureSTT] 🚀 Azure로 데이터 전송 중...");

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

      print("[AzureSTT] 📩 서버 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        // 응답 본문 디코딩
        final decodedBody = utf8.decode(response.bodyBytes);
        print("[AzureSTT] 📜 서버 응답 내용: $decodedBody");

        final jsonResponse = jsonDecode(decodedBody);
        final status = jsonResponse['RecognitionStatus'];

        if (status == 'Success') {
          final text = jsonResponse['DisplayText'];
          print("[AzureSTT] ✅ 인식 성공: $text");
          return text;
        } else if (status == 'NoMatch') {
          print("[AzureSTT] ⚠️ 인식 실패: 말소리를 감지하지 못했습니다 (NoMatch).");
          return null;
        } else {
          print("[AzureSTT] ⚠️ 기타 상태: $status");
          return null;
        }
      } else {
        print("[AzureSTT] ❌ HTTP 에러: ${response.body}");
        return null;
      }
    } catch (e) {
      print("[AzureSTT] ❌ 네트워크 통신 오류: $e");
      return null;
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}