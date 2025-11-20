// lib/widgets/event_flow_widget.dart

import 'package:flutter/material.dart';

// 1. 사건(Event)의 데이터 구조를 정의합니다. (아이콘과 라벨)
class _EventData {
  final String imagePath;
  final String label;

  const _EventData({required this.imagePath, required this.label});
}

// 2. StatelessWidget -> StatefulWidget으로 변경
class EventFlowWidget extends StatefulWidget {
  const EventFlowWidget({Key? key}) : super(key: key);

  @override
  State<EventFlowWidget> createState() => _EventFlowWidgetState();
}

class _EventFlowWidgetState extends State<EventFlowWidget> {
  // 3. 전체 '사건' 목록 (배열)
  final List<_EventData> _allEvents = [
    const _EventData(imagePath: "assets/images/SunClock.png", label: "앙부일구"),
    const _EventData(imagePath: "assets/images/RainMeasure.png", label: "측우기"),
    const _EventData(imagePath: "assets/images/Hangeul.png", label: "훈민정음"),
  ];

  // 4. 현재 중앙에 표시될 아이템의 인덱스 (State)
  int _currentIndex = 1;

  // 5. '이전'으로 이동하는 함수
  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // 6. '다음'으로 이동하는 함수
  void _goToNext() {
    if (_currentIndex < _allEvents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // [디자인 상수] 네이비 색상 정의
    const navyColor = Color(0xFF1A237E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        // [디자인 변경] 배경: 반투명 크림색 적용
        color: const Color(0xFFFDFBF7).withOpacity(0.9),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: navyColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이전 아이템
          GestureDetector(
            onTap: _currentIndex > 0 ? _goToPrevious : null,
            child: _buildFlowItem(
              _currentIndex > 0 ? _allEvents[_currentIndex - 1] : null,
              isActive: false,
            ),
          ),

          // [디자인 변경] 왼쪽 화살표 (끝이면 투명)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
                Icons.arrow_forward_ios,
                color: _currentIndex > 0 ? navyColor.withOpacity(0.3) : Colors.transparent,
                size: 12
            ),
          ),

          // 현재 아이템
          _buildFlowItem(
            _allEvents[_currentIndex],
            isActive: true,
          ),

          // [디자인 변경] 오른쪽 화살표 (끝이면 투명)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
                Icons.arrow_forward_ios,
                color: _currentIndex < _allEvents.length - 1 ? navyColor.withOpacity(0.3) : Colors.transparent,
                size: 12
            ),
          ),

          // 다음 아이템
          GestureDetector(
            onTap: _currentIndex < _allEvents.length - 1 ? _goToNext : null,
            child: _buildFlowItem(
              _currentIndex < _allEvents.length - 1 ? _allEvents[_currentIndex + 1] : null,
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowItem(_EventData? event, {required bool isActive}) {
    const navyColor = Color(0xFF1A237E);

    return SizedBox(
      width: 70,
      child: Opacity(
        opacity: (event == null) ? 0.0 : (isActive ? 1.0 : 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (event?.imagePath != null)
                ? Container(
              // [디자인 변경] 활성화된 아이템에만 연한 테두리
              decoration: isActive ? BoxDecoration(border: Border.all(color: navyColor.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)) : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  event!.imagePath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Icon(
              Icons.help_outline,
              color: navyColor, // [디자인 변경] 아이콘 색상
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              event?.label ?? "",
              style: TextStyle(
                color: navyColor, // [디자인 변경] 텍스트 색상
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}