// lib/screens/universal_chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/chat_bubble.dart';
import '../services/azure_stt_service.dart';

class UniversalChatScreen extends StatefulWidget {
  final String personaKey;
  final Map<String, dynamic> personaData;

  const UniversalChatScreen({
    Key? key,
    required this.personaKey,
    required this.personaData
  }) : super(key: key);

  @override
  State<UniversalChatScreen> createState() => _UniversalChatScreenState();
}

class _UniversalChatScreenState extends State<UniversalChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final AzureSttService _azureSttService = AzureSttService();
  final FlutterTts _flutterTts = FlutterTts();

  List<Map<String, dynamic>> _messages = [];
  bool _isRecording = false;
  bool _isLoading = false;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _azureSttService.dispose();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // ★★★ [수정된 부분] 복잡한 성우 찾기 제거하고 Pitch만 조절 ★★★
  Future<void> _initializeServices() async {
    // 1. API Key 설정
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";
    if (apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
    }

    // 2. 기본 언어 설정
    await _flutterTts.setLanguage("ko-KR");

    // 3. 성별에 따른 Pitch(톤) 단순 설정
    String gender = widget.personaData['gender'] ?? 'male';

    double targetPitch = 1.0;

    if (gender == 'female') {
      targetPitch = 1.2; // 여성이면 높게
    } else {
      targetPitch = 0.6; // 남성이면 낮게 (굵게)
    }

    await _flutterTts.setPitch(targetPitch);
    await _flutterTts.setSpeechRate(0.5); // 속도는 조금 느리게 고정
  }

  // --- [DB] 대화 기록 불러오기 ---
  void _loadChatHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref("users/${user.uid}/personas/${widget.personaKey}/chat_history");

    ref.orderByKey().limitToLast(50).get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final sortedKeys = data.keys.toList()..sort();

        final List<Map<String, dynamic>> loaded = [];

        for (var key in sortedKeys) {
          final value = data[key];
          loaded.add({
            "text": value['text'],
            "isUser": value['isUser'] ?? true,
          });
        }

        setState(() => _messages = loaded);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      } else {
        // 첫 인사
        String charName = widget.personaData['title'] ?? widget.personaData['name'] ?? '가상 인물';
        String greeting = "$charName이오. 무엇이 궁금하시오?";

        _addMessageToUI(greeting, isUser: false);
        _saveMessageToDB(greeting, false);
        _speak(greeting);
      }
    });
  }

  // --- [로직] 메시지 전송 및 GPT 통신 ---
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addMessageToUI(text, isUser: true);
    _saveMessageToDB(text, true);

    setState(() => _isLoading = true);

    try {
      final systemPrompt = widget.personaData['prompt'] ?? "너는 역사적 인물이다.";

      List<OpenAIChatCompletionChoiceMessageModel> requestMessages = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
        )
      ];

      int historyCount = 0;
      for (var msg in _messages.reversed) {
        if (historyCount >= 10) break;
        requestMessages.insert(1, OpenAIChatCompletionChoiceMessageModel(
          role: msg['isUser'] ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(msg['text'])],
        ));
        historyCount++;
      }

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: requestMessages,
      );

      final botReply = response.choices.first.message.content?.first.text ?? "말씀을 이해하지 못했소.";

      _addMessageToUI(botReply, isUser: false);
      _saveMessageToDB(botReply, false);
      _speak(botReply);

    } catch (e) {
      print("GPT 오류: $e");
      _addMessageToUI("통신 상태가 좋지 않소.", isUser: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMessageToUI(String text, {required bool isUser}) {
    setState(() => _messages.add({"text": text, "isUser": isUser}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _saveMessageToDB(String text, bool isUser) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseDatabase.instance
        .ref("users/${user.uid}/personas/${widget.personaKey}/chat_history")
        .push()
        .set({
      "text": text,
      "isUser": isUser,
      "timestamp": ServerValue.timestamp,
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _toggleRecording() async {
    if (_isRecording) {
      setState(() => _isRecording = false);
      setState(() => _isLoading = true);

      String? result = await _azureSttService.stopRecordingAndGetText();
      if (result != null && result.isNotEmpty) {
        _sendMessage(result);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('말씀을 듣지 못했소.'), duration: Duration(seconds: 1)),
        );
      }
    } else {
      setState(() => _isRecording = true);
      _flutterTts.stop();
      await _azureSttService.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bgImage = widget.personaData['image'] ?? "assets/images/general_male.png";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.personaData['title'] ?? widget.personaData['name'] ?? '가상 인물',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 10, color: Colors.black)]
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isChatOpen)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isChatOpen = true;
                  });
                },
                child: Center(
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(),
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          if (_isChatOpen)
            const SizedBox(width: 56),
        ],
      ),
      body: Stack(
        children: [
          // 1. 배경 이미지
          Positioned.fill(
            child: Image.asset(
              bgImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                    color: Colors.grey[800],
                    child: const Center(child: Text("이미지 로드 실패", style: TextStyle(color: Colors.white)))
                );
              },
            ),
          ),

          // 2. 오른쪽 채팅 패널
          if (_isChatOpen)
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.45,
                child: Container(
                  color: Colors.white.withOpacity(0.9),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),

                      // 닫기 버튼
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            setState(() {
                              _isChatOpen = false;
                            });
                          },
                        ),
                      ),
                      const Divider(height: 1),

                      // 채팅 리스트
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return ChatBubble(text: msg['text'], isUser: msg['isUser']);
                          },
                        ),
                      ),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),

                      // 하단 마이크 버튼
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: GestureDetector(
                          onTap: _toggleRecording,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: _isRecording ? Colors.redAccent : Colors.blueAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 2)
                              ],
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white, size: 35,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}