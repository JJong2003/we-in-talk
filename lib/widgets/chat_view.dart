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
  // 마이크 상태 변수
  bool _isRecording = true;

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

            _buildMicrophoneControl(),
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

  Widget _buildMicrophoneControl() {
    // 탭을 감지하기 위해 GestureDetector 사용
    return GestureDetector(
      onTap: () {
        // 탭하면 setState를 호출하여 상태 변경
        setState(() {
          _isRecording = !_isRecording;
        });
      },
      child: Container(
        color: Colors.white, // 배경색
        padding: const EdgeInsets.symmetric(vertical: 16.0), // 위아래 여백
        // _isRecording 상태에 따라 다른 아이콘을 표시
        child: _isRecording
            ? _buildRecordingIcon() // true일 때 (RECORDING)
            : _buildOfflineIcon(), // false일 때 (OFFLINE)
      ),
    );
  }

  // "OFFLINE" 상태의 아이콘 (크기 축소됨)
  Widget _buildOfflineIcon() {
    return Container(
      padding: const EdgeInsets.all(16), // 원본(40)보다 크기 축소
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
      ),
      child: const Icon(
        Icons.mic_off,
        color: Colors.white,
        size: 32, // 원본(80)보다 크기 축소
      ),
    );
  }

  // "RECORDING" 상태의 아이콘 (크기 축소됨, Text 제거)
  Widget _buildRecordingIcon() {
    return Container(
      padding: const EdgeInsets.all(16), // 원본(40)보다 크기 축소
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 10.0, // 원본(20)보다 효과 축소
            spreadRadius: 2.0, // 원본(5)보다 효과 축소
          ),
        ],
      ),
      child: const Icon(
        Icons.mic,
        color: Colors.white,
        size: 32, // 원본(80)보다 크기 축소
      ),
    );
  }

  // 7. 상단 탭바 위젯 (Row + Expanded로 Overflow 오류 해결)
  // 7. 상단 탭바 위젯 (Row + Expanded로 Overflow 오류 해결)
// 7. 상단 탭바 위젯 (버튼 크기 자체를 줄여서 Overflow 해결)
  // 7. 상단 탭바 위젯 (버튼의 좌우 Padding을 줄여 Overflow 해결)
  Widget _buildTopTabBar({
    required BuildContext context,
    required bool isQuizActive,
    required VoidCallback onQuizTap,
    required VoidCallback onChatTap,
  }) {
    // 1. 버튼 스타일 정의에 'padding' 속성 추가
    final inactiveStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // 이 버튼의 좌우 여백을 기본값보다 좁게 설정 (8.0)
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
    );
    final activeStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // 이 버튼의 좌우 여백을 기본값보다 좁게 설정 (8.0)
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
    );

    // 2. 이 아래의 Row 레이아웃은 이전과 동일하게 유지합니다.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          // [왼쪽 영역]
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 20.0,
          ),

          // [중앙 영역]
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "퀴즈 만들기" 버튼 (아이콘 없이)
                ElevatedButton(
                  child: const Text("퀴즈 만들기"),
                  onPressed: onQuizTap,
                  style: isQuizActive ? activeStyle : inactiveStyle,
                ),
                const SizedBox(width: 8),
                // "질문 정리" 탭 (아이콘 없이)
                ElevatedButton(
                  child: const Text("질문 정리"),
                  onPressed: onChatTap,
                  style: isQuizActive ? inactiveStyle : activeStyle,
                ),
              ],
            ),
          ),

          // [오른쪽 영역]
          Opacity(
            opacity: 0.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: null,
              iconSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}