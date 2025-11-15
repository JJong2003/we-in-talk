// lib/widgets/event_flow_widget.dart

import 'package:flutter/material.dart';

// 1. 사건(Event)의 데이터 구조를 정의합니다. (아이콘과 라벨)
class _EventData {
  final IconData icon;
  final String label;

  const _EventData({required this.icon, required this.label});
}

// 2. StatelessWidget -> StatefulWidget으로 변경
class EventFlowWidget extends StatefulWidget {
  const EventFlowWidget({Key? key}) : super(key: key);

  @override
  State<EventFlowWidget> createState() => _EventFlowWidgetState();
}

class _EventFlowWidgetState extends State<EventFlowWidget> {
  // 3. 전체 '사건' 목록 (배열)
  // (임시 데이터)
  final List<_EventData> _allEvents = [
    const _EventData(icon: Icons.cloudy_snowing, label: "측우기"),
    const _EventData(icon: Icons.book, label: "훈민정음"),
    const _EventData(icon: Icons.castle, label: "집현전"),
    const _EventData(icon: Icons.person, label: "신숙주"),
    const _EventData(icon: Icons.people, label: "사대부"),
  ];

  // 4. 현재 중앙에 표시될 아이템의 인덱스 (State)
  int _currentIndex = 0; // 0번 인덱스("측우기")에서 시작

  // 5. '이전'으로 이동하는 함수
  void _goToPrevious() {
    // 0보다 클 때만 인덱스 감소
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // 6. '다음'으로 이동하는 함수
  void _goToNext() {
    // 배열의 끝보다 작을 때만 인덱스 증가
    if (_currentIndex < _allEvents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기존의 반투명 배경 Container는 그대로 사용
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // 반투명 검은색
        borderRadius: BorderRadius.circular(30.0), // 둥근 모서리
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞게 Row 크기 조절
        children: [
          // 7. [이전 아이템] - 클릭 가능하도록 GestureDetector로 감싸기
          GestureDetector(
            // 0번 인덱스일 경우 탭 비활성화 (null)
            onTap: _currentIndex > 0 ? _goToPrevious : null,
            child: _buildFlowItem(
              // 0번 인덱스일 경우 표시할 데이터가 없음 (null)
              _currentIndex > 0 ? _allEvents[_currentIndex - 1] : null,
              isActive: false, // 중앙이 아니므로 false
            ),
          ),

          // 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),

          // 8. [현재 아이템] - 항상 활성화
          _buildFlowItem(
            _allEvents[_currentIndex], // 현재 인덱스의 아이템
            isActive: true, // 중앙이므로 true
          ),

          // 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),

          // 9. [다음 아이템] - 클릭 가능하도록 GestureDetector로 감싸기
          GestureDetector(
            // 마지막 인덱스일 경우 탭 비활성화 (null)
            onTap: _currentIndex < _allEvents.length - 1 ? _goToNext : null,
            child: _buildFlowItem(
              // 마지막 인덱스일 경우 표시할 데이터가 없음 (null)
              _currentIndex < _allEvents.length - 1 ? _allEvents[_currentIndex + 1] : null,
              isActive: false, // 중앙이 아니므로 false
            ),
          ),
        ],
      ),
    );
  }

  // 사건 흐름의 각 항목을 만드는 헬퍼 위젯 (수정됨)
  Widget _buildFlowItem(_EventData? event, {required bool isActive}) {
    // 10. 아이템의 너비를 고정하여, null일 때도 레이아웃이 깨지지 않게 함
    return SizedBox(
      width: 65, // 너비 고정
      child: Opacity(
        // 11. null이면 투명하게, 비활성이면 반투명하게
        opacity: (event == null) ? 0.0 : (isActive ? 1.0 : 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 12. event가 null일 경우를 대비 (??)
            Icon(event?.icon ?? Icons.help_outline, color: Colors.white, size: 30),
            const SizedBox(height: 4),
            Text(
              event?.label ?? "", // null이면 빈 텍스트
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis, // 이름이 길면 ... 처리
            ),
          ],
        ),
      ),
    );
  }
}