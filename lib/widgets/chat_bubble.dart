// lib/widgets/chat_bubble.dart

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    // 기존 _buildChatBubble 메서드의 로직을 그대로 사용
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // isUser 값에 따라 정렬 변경
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          // isUser 값에 따라 색상 변경
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        // 말풍선 최대 너비 제한
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }
}