// lib/widgets/quiz_summary_view.dart

import 'package:flutter/material.dart';
import 'quiz_bubble.dart'; // QuizProblem 모델 import

class QuizSummaryView extends StatelessWidget {
  final List<QuizProblem> problems;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const QuizSummaryView({
    Key? key,
    required this.problems,
    required this.onRestart,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A237E);

    // [디자인 변경] 컨테이너 스타일 변경 (배경색, 테두리 제거)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 헤더 (디자인 변경)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "오늘 배운 내용 복습하기",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryNavy, // 네이비색 적용
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(),

        // 2. 정리 목록 (스크롤 가능)
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: problems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildSummaryItem(problems[index], index);
            },
          ),
        ),

        // 3. 하단 버튼 (디자인 변경)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRestart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryNavy,
                  side: const BorderSide(color: primaryNavy), // 네이비 테두리
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("다시 풀기"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy, // 네이비 배경
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("학습 종료"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 각 정리 항목 (디자인 변경)
  Widget _buildSummaryItem(QuizProblem problem, int index) {
    const Color primaryNavy = Color(0xFF1A237E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // 아주 연한 회색 배경
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Q 마크 (네이비색 배경)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("Q", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  problem.summaryQuestion,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 32), // Q 마크만큼 들여쓰기
              const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  problem.summaryAnswer,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}