// lib/widgets/chat_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
  List<ChatMessage> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  final AzureSttService _azureSttService = AzureSttService();
  final FlutterTts _flutterTts = FlutterTts();

  final String _sejongKey = "persona_sejong";
  final String _systemPrompt =
      "너는 조선의 4대 왕, 세종대왕이다. 훈민정음을 창제하였으며, 백성을 매우 사랑한다. "
      "말투는 '하노라', '하였느니라' 같은 하오체를 사용하라. 답변은 2~3문장으로 짧게 하라.";

  @override
  void initState() {
    super.initState();
    _initializeServices().then((_) {
      _loadChatHistory();
    });
  }

  Future<void> _initializeServices() async {
    String? openAiKey = dotenv.env['OPENAI_API_KEY'];
    if (openAiKey != null && openAiKey.isNotEmpty) {
      OpenAI.apiKey = openAiKey;
    }

    try {
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setPitch(0.6); // 굵은 목소리
      await _flutterTts.setVolume(1.0); // 볼륨 최대

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
  }

  void _loadChatHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref("users/${user.uid}/personas/$_sejongKey/chat_history");

    ref.orderByKey().limitToLast(50).get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final sortedKeys = data.keys.toList()..sort();

        final List<ChatMessage> loaded = [];
        for (var key in sortedKeys) {
          final value = data[key];
          loaded.add(ChatMessage(
            text: value['text'],
            isUser: value['isUser'] ?? true,
          ));
        }

        setState(() => _chatHistory = loaded);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        // [수정] 대화가 딱 1개(인사말)만 있으면 다시 읽어줌 (1초 딜레이)
        if (loaded.length == 1 && !loaded.last.isUser) {
          Future.delayed(const Duration(seconds: 1), () {
            _speak(loaded.last.text);
          });
        }

      } else {
        // [첫 인사]
        String greeting = "과인이 조선의 임금, 이도니라. 백성아, 무엇이 궁금하느냐?";
        _addMessage(greeting, isUser: false);
        _saveMessageToDB(greeting, false);

        // [수정] 1초 기다렸다가 말하기
        Future.delayed(const Duration(seconds: 1), () {
          _speak(greeting);
        });
      }
    });
  }

  void _saveMessageToDB(String text, bool isUser) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseDatabase.instance
        .ref("users/${user.uid}/personas/$_sejongKey/chat_history")
        .push()
        .set({
      "text": text,
      "isUser": isUser,
      "timestamp": ServerValue.timestamp,
    });
  }

  @override
  void dispose() {
    _azureSttService.dispose();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isQuizMode) {
      if (widget.isRecording != oldWidget.isRecording) {
        if (widget.isRecording) {
          _startListening();
        } else {
          _stopListeningAndProcess();
        }
      }
    }
  }

  Future<void> _startListening() async {
    await _flutterTts.stop();
    await _azureSttService.startRecording();
  }

  Future<void> _stopListeningAndProcess() async {
    setState(() => _isLoading = true);

    try {
      String? userText = await _azureSttService.stopRecordingAndGetText();

      if (userText != null && userText.isNotEmpty) {
        _addMessage(userText, isUser: true);
        _saveMessageToDB(userText, true);
        await _sendToOpenAI();
      } else {
        print("음성 인식 결과 없음");
      }
    } catch (e) {
      print("프로세스 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("통신 중 오류가 발생하였소.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendToOpenAI() async {
    try {
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(_systemPrompt)],
      );

      final historyMessages = _chatHistory.map((msg) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: msg.isUser ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text)],
        );
      }).toList();

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [systemMessage, ...historyMessages],
        maxTokens: 250,
      );

      final botResponse = response.choices.first.message.content?.first.text;

      if (botResponse != null) {
        _addMessage(botResponse, isUser: false);
        _saveMessageToDB(botResponse, false);
        _speak(botResponse);
      }
    } catch (e) {
      print("GPT API 오류: $e");
      _addMessage("과인이 잠시 깊은 생각에 잠겼노라.", isUser: false);
    }
  }

  Future<void> _speak(String text) async {
    // [디버깅 로그 추가] 왜 안 말하는지 확인
    if (widget.isRecording) {
      print("📢 [TTS Skipped] 녹음 중이라서 말을 안 합니다.");
      return;
    }
    print("🔊 [TTS Speaking] 말하기 시작: $text");
    await _flutterTts.speak(text);
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _chatHistory.add(ChatMessage(text: text, isUser: isUser));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  // ... (하단 위젯 빌드 함수들은 동일함)
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
              return ChatBubble(text: msg.text, isUser: msg.isUser);
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(backgroundColor: Colors.grey, color: Colors.blue),
          ),
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
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onChatTap,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: !isQuizActive ? Colors.blue : Colors.grey.shade300, width: 3)),
                ),
                child: Text("대화하기", style: TextStyle(fontWeight: FontWeight.bold, color: !isQuizActive ? Colors.blue : Colors.grey)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onQuizTap,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isQuizActive ? Colors.blue : Colors.grey.shade300, width: 3)),
                ),
                child: Text("역사 퀴즈", style: TextStyle(fontWeight: FontWeight.bold, color: isQuizActive ? Colors.blue : Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}