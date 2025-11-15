// lib/screens/chat_view.dart

import 'package:flutter/material.dart';
// 1. 새로 만든 ChatBubble 위젯 import
import '../widgets/chat_bubble.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. SafeArea로 감싸서 상단 상태바 영역 침범 방지
    return SafeArea(
      child: Container(
        // 2. height와 decoration 속성 제거 (Drawer에 맞게 수정)
        // height: MediaQuery.of(context).size.height * 0.85, // <-- 제거
        // decoration: const BoxDecoration( ... ), // <-- 제거

        color: Colors.white, // Drawer의 배경색 (이미 설정되어 있지만 명시)

        // 3. Column 구조 수정 (탭 + 리스트)
        child: Column(
          children: [
            // 3-1. 상단 탭 (퀴즈 만들기, 질문 정리)
            _buildTopTabBar(context),

            // 3-2. 대화 내역 (스크롤 가능)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 2. _buildChatBubble -> ChatBubble 위젯으로 변경
                  const ChatBubble(
                    text: "한글을 만들 때 여러 반대가 있었다던데, 누가 왜 반대했었어요?",
                    isUser: true,
                  ),
                  const ChatBubble(
                    text: "짐이 아끼던 집현전 학자 최만리 등이 반대했단다. 중국을 섬겨야 한다는 이유와, 백성들이 글을 알면 자신들의 특권을 잃을까 봐 두려워했기 때문이지.",
                    isUser: false,
                  ),
                  const ChatBubble(
                    text: "그러면 좋은거지 않았어요? 한글은 좋은거잖아요.",
                    isUser: true,
                  ),
                  const ChatBubble(
                    text: "짜증보다는 답답하고 안타까웠단다. 글 몰라 억울한 백성을 위해 만들었는데, 신하들이 백성의 아픔은 모르고 자신들의 권력만 지키려 하니 마음이 아팠지.",
                    isUser: false,
                  ),
                  const ChatBubble(
                    text: "아, 측우기 말이냐. 그것은 하늘의 비를 정확히 재어 백성들의 농사를 돕고자 짐이 만들게 한 것이란다. 어떠하냐, 이 측우기에 대해 짐이 더 자세히 알려주길 바라느냐?",
                    isUser: false,
                  ),
                  // TODO: 실제 채팅 데이터로 교체
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 탭바 위젯 (이미지 참고)
  Widget _buildTopTabBar(BuildContext context) {
    // 1. Row -> Stack으로 변경하여 레이아웃 안정화
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // 패딩 약간 조절
      child: Stack(
        alignment: Alignment.center, // Stack의 자식들을 중앙 정렬
        children: [
          // 2. 중앙 버튼 그룹 (가운데에 배치)
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              // "퀴즈 만들기" 버튼 (비활성)
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text("퀴즈 만들기"),
                onPressed: () {
                  // TODO: 퀴즈 만들기 기능 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200], // 비활성 색상
                  foregroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // "질문 정리" 탭 (현재 활성 탭)
              ElevatedButton.icon(
                icon: const Icon(Icons.article, size: 20),
                label: const Text("질문 정리"),
                onPressed: () {
                  // 이미 활성화된 탭
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 활성 색상
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          // 3. 뒤로가기 화살표 (왼쪽 정렬)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios), // 이미지의 화살표
              onPressed: () => Navigator.of(context).pop(), // Drawer 닫기
              iconSize: 20.0,
            ),
          ),

          // 4. 오른쪽 공간 확보용 SizedBox 제거 (Stack이라 불필요)
        ],
      ),
    );
  }
}