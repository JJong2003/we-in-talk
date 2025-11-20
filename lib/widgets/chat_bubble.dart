// lib/widgets/chat_bubble.dart

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [디자인 변경] 네이비색 상수 정의
    const Color primaryNavy = Color(0xFF1A237E);

    // 1. isUser 값에 따라 정렬 위치, 색상, 테두리를 설정합니다.
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    // [디자인 변경] 사용자 말풍선 색상을 네이비로
    final bubbleColor = isUser ? primaryNavy : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black87;
    // 봇 말풍선에만 연한 테두리 (안전한 Color.shade200 사용)
    final border = isUser ? null : Border.all(color: Colors.grey.shade200, width: 1);

    // 2. 둥근 모서리와 뾰족한 모서리 값을 정의합니다.
    const roundedRadius = Radius.circular(16.0);
    const sharpRadius = Radius.circular(4.0);

    // 3. isUser 값에 따라 모서리 모양을 다르게 설정합니다. (꼬리 효과)
    final borderRadius = isUser
        ? const BorderRadius.only(
      // [사용자: 오른쪽] -> 오른쪽 위만 뾰족
      topLeft: roundedRadius,
      bottomLeft: roundedRadius,
      bottomRight: roundedRadius,
      topRight: sharpRadius,
    )
        : const BorderRadius.only(
      // [봇: 왼쪽] -> 왼쪽 위만 뾰족
      topLeft: sharpRadius,
      topRight: roundedRadius,
      bottomLeft: roundedRadius,
      bottomRight: roundedRadius,
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          border: border,
          boxShadow: [
            // 그림자 효과 추가
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      ),
    );
  }
}