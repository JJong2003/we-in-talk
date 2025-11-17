// lib/screens/chat_view.dart

import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quiz_bubble.dart';

class ChatView extends StatefulWidget {
  // [1] 부모로부터 '현재 퀴즈 모드인지'와 '모드를 변경할 함수'를 받습니다.
  final bool isQuizMode;
  final ValueChanged<bool> onToggleQuizMode;
  final ValueChanged<bool> onToggleKingPosition;

  const ChatView({
    Key? key,
    required this.isQuizMode, // 부모가 퀴즈 모드 상태를 전달
    required this.onToggleQuizMode, // 부모의 상태 변경 함수를 전달
    required this.onToggleKingPosition
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // 마이크 상태 변수 (이건 ChatView가 자체적으로 가져도 됨)
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // [3] 부모로부터 받은 상태와 함수를 _buildTopTabBar에 전달
            _buildTopTabBar(
              context: context,
              isQuizActive: widget.isQuizMode, // 부모가 준 상태 사용
              onQuizTap: () {
                widget.onToggleQuizMode(true); // 부모에게 '퀴즈 켬' 알림
              },
              onChatTap: () {
                widget.onToggleQuizMode(false); // 부모에게 '퀴즈 끔' 알림
              },
            ),

            // 5. _isShowingQuiz 값에 따라 다른 화면을 보여줌
            Expanded(
              // ----------------------------------------------------
              // ▼ [수정 2] QuizScreen에 '두 개'의 함수 전달
              // ----------------------------------------------------
              child: widget.isQuizMode
                  ? QuizScreen(
                onToggleQuizMode: widget.onToggleQuizMode,
                onToggleKingPosition: widget.onToggleKingPosition,
              )
                  : _buildChatLog(),
            ),

            // 마이크 버튼 (기존과 동일)
            _buildMicrophoneControl(),
          ],
        ),
      ),
    );
  }

  // 6. 기존 질문 정리 (채팅 로그) UI를 별도 메서드로 분리
  Widget _buildChatLog() {
    // (기존 코드와 동일)
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        ChatBubble(
          text: "한글을 만들 때 여러 반대가 있었다던데, 누가 왜 반대했었어요?",
          isUser: true,
        ),
        ChatBubble(
          text: "짐이 아끼던 집현전 학자 최만리 등이 반대했단다. 중국을 섬겨야 한다는 이유와, 백성들이 글을 알면 자신들의 특권을 잃을까 봐 두려워했기 때문이지.",
          isUser: false,
        ),
        ChatBubble(
          text: "그러면 짜증나지 않았어요?\n 한글은 좋은거잖아요.",
          isUser: true,
        ),
        ChatBubble(
          text: "짜증보다는 답답하고 안타까웠단다. 글 몰라 억울한 백성을 위해 만들었는데, 신하들이 백성의 아픔은 모르고 자신들의 권력만 지키려 하니 마음이 아팠지.",
          isUser: false,
        ),
        ChatBubble(
          text: "아, 측우기 말이냐. 그것은 하늘의 비를 정확히 재어 백성들의 농사를 돕고자 짐이 만들게 한 것이란다. 어떠하냐, 이 측우기에 대해 짐이 더 자세히 알려주길 바라느냐?",
          isUser: false,
        ),
      ],
    );
  }

  // 마이크 컨트롤 위젯 (기존과 동일)
  Widget _buildMicrophoneControl() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRecording = !_isRecording;
        });
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: _isRecording
            ? _buildRecordingIcon()
            : _buildOfflineIcon(),
      ),
    );
  }

  // "OFFLINE" 아이콘 (기존과 동일)
  Widget _buildOfflineIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
      ),
      child: const Icon(
        Icons.mic_off,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  // "RECORDING" 아이콘 (기존과 동일)
  Widget _buildRecordingIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: const Icon(
        Icons.mic,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  // 7. 상단 탭바 위젯 (기존과 동일 - 전달된 함수를 그대로 사용)
  Widget _buildTopTabBar({
    required BuildContext context,
    required bool isQuizActive,
    required VoidCallback onQuizTap,
    required VoidCallback onChatTap,
  }) {
    // ... (스타일 정의는 기존과 동일)
    final inactiveStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
    final activeStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 버튼 그룹
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "퀴즈 만들기" 버튼
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text("퀴즈 만들기"),
                onPressed: onQuizTap, // [5] 전달받은 onQuizTap 함수를 그대로 연결
                style: isQuizActive ? activeStyle : inactiveStyle,
              ),
              const SizedBox(width: 8),
              // "질문 정리" 탭
              ElevatedButton.icon(
                icon: const Icon(Icons.article, size: 20),
                label: const Text("질문 정리"),
                onPressed: onChatTap, // [5] 전달받은 onChatTap 함수를 그대로 연결
                style: isQuizActive ? inactiveStyle : activeStyle,
              ),
            ],
          ),
          // 뒤로가기 화살표
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onToggleKingPosition(true);
              },
              iconSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}