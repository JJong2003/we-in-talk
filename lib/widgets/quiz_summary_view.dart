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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          // 1. 헤더
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                SizedBox(width: 12),
                Text(
                  "퀴즈 총정리",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. 정리 목록 (스크롤 가능)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: problems.length,
              itemBuilder: (context, index) {
                return _buildSummaryItem(problems[index]);
              },
            ),
          ),

          // 3. 하단 버튼
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("퀴즈 만들기"), // 이미지 4에는 '퀴즈 만들기'로 되어있음
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[800],
                  ),
                ),
                ElevatedButton(
                  child: Text("퀴즈 닫기"),
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 각 정리 항목
  Widget _buildSummaryItem(QuizProblem problem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문
          Text(
            problem.summaryQuestion,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          // 답변
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("→ ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  problem.summaryAnswer,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}