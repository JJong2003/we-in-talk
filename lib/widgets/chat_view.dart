// lib/screens/chat_view.dart

import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
// 1. 새로 만들 QuizScreen import (widgets 폴더에 위치)
import '../widgets/quiz_bubble.dart';

// 2. StatelessWidget -> StatefulWidget으로 변경
class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // 3. 현재 퀴즈 탭을 보고 있는지 관리하는 상태 변수
  bool _isShowingQuiz = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 4. 상태를 변경할 수 있도록 콜백 함수 전달
            _buildTopTabBar(
              context: context,
              isQuizActive: _isShowingQuiz,
              onQuizTap: () {
                // '퀴즈 만들기' 탭 클릭
                setState(() {
                  _isShowingQuiz = true; // 퀴즈 탭 활성화
                });
              },
              onChatTap: () {
                // '질문 정리' 탭 클릭
                setState(() {
                  _isShowingQuiz = false; // 질문 정리 탭 활성화
                });
              },
            ),

            // 5. _isShowingQuiz 값에 따라 다른 화면을 보여줌
            Expanded(
              child: _isShowingQuiz
                  ? const QuizScreen() // 퀴즈 화면
                  : _buildChatLog(), // 기존 질문 정리 화면
            ),
          ],
        ),
      ),
    );
  }

  // 6. 기존 질문 정리 (채팅 로그) UI를 별도 메서드로 분리
  Widget _buildChatLog() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        // (기존 ChatBubble Mock 데이터)
        ChatBubble(
          text: "한글을 만들 때 여러 반대가 있었다던데, 누가 왜 반대했었어요?",
          isUser: true,
        ),
        ChatBubble(
          text: "짐이 아끼던 집현전 학자 최만리 등이 반대했단다. 중국을 섬겨야 한다는 이유와, 백성들이 글을 알면 자신들의 특권을 잃을까 봐 두려워했기 때문이지.",
          isUser: false,
        ),
        // (기존 ChatBubble Mock 데이터)
        ChatBubble(
          text: "그러면 짜증나지 않았어요? 한글은 좋은거잖아요.",
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

  // 7. 상단 탭바 위젯 (상태에 따라 버튼 스타일이 바뀌도록 수정)
  Widget _buildTopTabBar({
    required BuildContext context,
    required bool isQuizActive,
    required VoidCallback onQuizTap,
    required VoidCallback onChatTap,
  }) {
    // 비활성/활성 버튼 스타일 정의
    final inactiveStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200], // 비활성 색상
      foregroundColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
    final activeStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // 활성 색상
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
                onPressed: onQuizTap, // 퀴즈 탭 보기
                style: isQuizActive ? activeStyle : inactiveStyle, // 상태에 따라 스타일 적용
              ),
              const SizedBox(width: 8),
              // "질문 정리" 탭
              ElevatedButton.icon(
                icon: const Icon(Icons.article, size: 20),
                label: const Text("질문 정리"),
                onPressed: onChatTap, // 질문 탭 보기
                style: isQuizActive ? inactiveStyle : activeStyle, // 상태에 따라 스타일 적용
              ),
            ],
          ),
          // 뒤로가기 화살표
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => Navigator.of(context).pop(), // Drawer 닫기
              iconSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}