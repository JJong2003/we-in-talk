import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dart_openai/dart_openai.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quiz_bubble.dart';
import '../services/azure_stt_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatView extends StatefulWidget {
  final bool isQuizMode;
  final ValueChanged<bool> onToggleQuizMode;
  final ValueChanged<bool> onToggleKingPosition;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  const ChatView({
    Key? key,
    required this.isQuizMode,
    required this.onToggleQuizMode,
    required this.onToggleKingPosition,
    required this.isRecording,
    required this.onToggleRecording,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<ChatMessage> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false; // 로딩 상태

  // 서비스 인스턴스
  final AzureSttService _azureSttService = AzureSttService();
  final FlutterTts _flutterTts = FlutterTts();

  // 세종대왕 페르소나
  final String _systemPrompt =
      "너는 조선의 4대 왕, 세종대왕이다. "
      "너는 훈민정음을 창제하였으며, 백성을 매우 사랑한다. "
      "말투는 항상 '하노라', '하였느니라' 같은 고풍스러운 하오체를 사용하라. "
      "현대 문물(스마트폰, AI 등)에 대해서는 신기해하는 반응을 보여라. "
      "답변은 2~3문장으로 간결하고 위엄 있게 하라.";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // 1. OpenAI 키 설정
    String? openAiKey = dotenv.env['OPENAI_API_KEY'];
    if (openAiKey != null && openAiKey.isNotEmpty) {
      OpenAI.apiKey = openAiKey;
    } else {
      print("⚠️ 경고: .env에 OPENAI_API_KEY가 없습니다.");
    }

    // 2. TTS 설정 (최신 flutter_tts v4 대응)
    try {
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.setSpeechRate(0.4); // 세종대왕이므로 천천히
      await _flutterTts.setPitch(0.9);      // 약간 낮은 톤

      // iOS 오디오 설정 (무음 모드에서도 소리 나게)
      await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ]
      );
    } catch (e) {
      print("TTS 초기화 오류: $e");
    }

    // 3. 첫 인사
    _addMessage("과인이 조선의 임금, 이도니라. 백성아, 무엇이 궁금하느냐?", isUser: false);
  }

  @override
  void dispose() {
    _azureSttService.dispose();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // [상태 감지] 부모 위젯의 마이크 버튼 상태 변화 감지
  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isQuizMode) {
      // 녹음 상태가 변경되었을 때
      if (widget.isRecording != oldWidget.isRecording) {
        if (widget.isRecording) {
          // false -> true : 녹음 시작
          _startListening();
        } else {
          // true -> false : 녹음 종료 및 처리
          _stopListeningAndProcess();
        }
      }
    } else {
      // 퀴즈 모드 진입 시 녹음 중이면 강제 종료
      if (widget.isQuizMode && widget.isRecording) {
        // 필요한 경우 로직 추가
      }
    }
  }

  // 1. 녹음 시작
  Future<void> _startListening() async {
    await _flutterTts.stop(); // 말하고 있었다면 중단
    await _azureSttService.startRecording();
  }

  // 2. 녹음 종료 -> Azure -> GPT -> TTS 흐름
  Future<void> _stopListeningAndProcess() async {
    setState(() => _isLoading = true); // 로딩 바 표시

    try {
      // A. Azure STT로 텍스트 변환
      String? userText = await _azureSttService.stopRecordingAndGetText();

      if (userText != null && userText.isNotEmpty) {
        // B. 사용자 말풍선 추가
        _addMessage(userText, isUser: true);

        // C. GPT에게 질문
        await _sendToOpenAI();
      } else {
        // 인식이 안 됐을 때 (침묵 등)
        print("음성 인식 결과 없음");
      }
    } catch (e) {
      print("프로세스 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("통신 중 오류가 발생하였소.")),
      );
    } finally {
      setState(() => _isLoading = false); // 로딩 바 숨김
    }
  }

  // 3. OpenAI 통신
  Future<void> _sendToOpenAI() async {
    try {
      // 대화 내역을 OpenAI 포맷으로 변환
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(_systemPrompt)
        ],
      );

      final historyMessages = _chatHistory.map((msg) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: msg.isUser ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text)
          ],
        );
      }).toList();

      // API 요청 (gpt-4o-mini 사용 추천 - 속도/비용 효율적)
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [systemMessage, ...historyMessages],
        maxTokens: 250, // 답변 길이 제한
      );

      final botResponse = response.choices.first.message.content?.first.text;

      if (botResponse != null) {
        // D. 답변 표시 및 읽기
        _addMessage(botResponse, isUser: false);
        _speak(botResponse);
      }
    } catch (e) {
      print("GPT API 오류: $e");
      _addMessage("과인이 잠시 깊은 생각에 잠겼노라. 다시 말해주겠느냐?", isUser: false);
    }
  }

  // 4. TTS 읽기
  Future<void> _speak(String text) async {
    if (widget.isRecording) return; // 녹음 중엔 말하지 않음
    await _flutterTts.speak(text);
  }

  // UI 업데이트 헬퍼
  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _chatHistory.add(ChatMessage(text: text, isUser: isUser));
    });
    // 스크롤 최하단으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // (이 부분은 기존 UI 구조와 동일합니다)
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildTopTabBar(
              context: context,
              isQuizActive: widget.isQuizMode,
              onQuizTap: () => widget.onToggleQuizMode(true),
              onChatTap: () => widget.onToggleQuizMode(false),
            ),
            Expanded(
              child: widget.isQuizMode
                  ? QuizScreen(
                onToggleQuizMode: widget.onToggleQuizMode,
                onToggleKingPosition: widget.onToggleKingPosition,
              )
                  : _buildChatLog(),
            ),
            if (!widget.isQuizMode) _buildMicrophoneControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatLog() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: _chatHistory.length,
            itemBuilder: (context, index) {
              final msg = _chatHistory[index];
              // 이미 만들어둔 ChatBubble 위젯 사용
              return ChatBubble(text: msg.text, isUser: msg.isUser);
            },
          ),
        ),
        // 로딩 인디케이터
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                color: Colors.blue
            ),
          ),
        // 녹음 중 상태 메시지
        if (widget.isRecording)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "세종대왕님이 경청하고 계십니다...",
                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)
            ),
          ),
      ],
    );
  }

  // 기존 마이크 버튼 위젯 재사용
  Widget _buildMicrophoneControl() {
    return GestureDetector(
      onTap: widget.onToggleRecording,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: widget.isRecording ? _buildRecordingIcon() : _buildOfflineIcon(),
      ),
    );
  }

  Widget _buildOfflineIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
      child: const Icon(Icons.mic_off, color: Colors.white, size: 32),
    );
  }

  Widget _buildRecordingIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10.0, spreadRadius: 2.0),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 32),
    );
  }

  Widget _buildTopTabBar({required BuildContext context, required bool isQuizActive, required VoidCallback onQuizTap, required VoidCallback onChatTap}) {
    // 기존 코드 유지
    return Container(height: 50);
  }
}