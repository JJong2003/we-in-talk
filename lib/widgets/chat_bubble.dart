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
    // 1. isUser 값에 따라 정렬 위치, 색상, 테두리를 설정합니다. (이전과 동일)
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser ? Colors.blue : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black;
    final border = isUser ? null : Border.all(color: Colors.grey[300]!, width: 1);

    // 2. 둥근 모서리와 뾰족한(덜 둥근) 모서리 값을 정의합니다.
    const roundedRadius = Radius.circular(16.0);
    const sharpRadius = Radius.circular(4.0); // 뾰족한 부분의 반지름

    // 3. ⭐️⭐️⭐️핵심⭐️⭐️⭐️
    // isUser 값에 따라 모서리 모양을 다르게 설정합니다.
    final borderRadius = isUser
        ? BorderRadius.only(
      // [사용자: 오른쪽] -> '오른쪽 위' 모서리만 뾰족하게
      topLeft: roundedRadius,
      bottomLeft: roundedRadius,
      bottomRight: roundedRadius,
      topRight: sharpRadius, // <-- 이 부분
    )
        : BorderRadius.only(
      // [봇: 왼쪽] -> '왼쪽 위' 모서리만 뾰족하게
      topLeft: sharpRadius, // <-- 이 부분
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
          borderRadius: borderRadius, // ⭐️ [3]에서 만든 조건부 모서리 적용
          border: border,
          boxShadow: [
            // 스크린샷과 비슷하게 그림자 효과
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

// // lib/widgets/chat_bubble.dart
//
// import 'package:flutter/material.dart';
//
// class ChatBubble extends StatelessWidget {
//   const ChatBubble({
//     Key? key,
//     required this.text,
//     required this.isUser,
//   }) : super(key: key);
//
//   final String text;
//   final bool isUser;
//
//   @override
//   Widget build(BuildContext context) {
//     // 기존 _buildChatBubble 메서드의 로직을 그대로 사용
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       // isUser 값에 따라 정렬 변경
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         decoration: BoxDecoration(
//           // isUser 값에 따라 색상 변경
//           color: isUser ? Colors.blue[100] : Colors.grey[200],
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         // 말풍선 최대 너비 제한
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
//         ),
//       ),
//     );
//   }
// }