// lib/widgets/event_flow_widget.dart

import 'package:flutter/material.dart';

class EventFlowWidget extends StatelessWidget {
  const EventFlowWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이미지와 유사하게 반투명 검은색 배경에 둥근 모서리 적용
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // 반투명 검은색
        borderRadius: BorderRadius.circular(30.0), // 둥근 모서리
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞게 Row 크기 조절
        children: [
          // "흑무" 아이콘 + 텍스트
          _buildFlowItem(Icons.home, "측우기"), // TODO: 아이콘 변경

          // 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),

          // "확인용품" 아이콘 + 텍스트
          _buildFlowItem(Icons.inventory_2, "훈민정음"), // TODO: 아이콘 변경

          // 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),

          // "확인용품" 아이콘 + 텍스트
          _buildFlowItem(Icons.inventory_2, ""), // TODO: 아이콘 변경
        ],
      ),
    );
  }

  // 사건 흐름의 각 항목을 만드는 헬퍼 위젯
  Widget _buildFlowItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}