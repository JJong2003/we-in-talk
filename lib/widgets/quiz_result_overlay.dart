// lib/widgets/quiz_result_overlay.dart

import 'package:flutter/material.dart';

class QuizResultOverlay extends StatelessWidget {
  const QuizResultOverlay({
    Key? key,
    required this.isCorrect,
    required this.explanation,
    required this.isLastProblem,
    required this.onNextProblem,
    required this.onShowSummary,
    required this.onTryAgain,
  }) : super(key: key);

  final bool isCorrect;
  final String explanation;
  final bool isLastProblem;
  final VoidCallback onNextProblem;
  final VoidCallback onShowSummary;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    // [디자인 변경] 차분한 색상과 네이비색 정의
    Color statusColor = isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828); // 청록/다홍
    const Color primaryNavy = Color(0xFF1A237E);
    IconData iconData = isCorrect ? Icons.check_circle : Icons.cancel;
    String title = isCorrect ? "정답입니다!" : "오답입니다!";

    return Container(
      // [디자인 변경] 뒷배경을 반투명 크림색으로 변경
      color: const Color(0xFFFDFBF7).withOpacity(0.95),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. '정답/오답' 아이콘 및 텍스트 (직접적으로 배치)
          Icon(iconData, color: statusColor, size: 80),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: statusColor,
              fontSize: 28, // 크기 조정
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 30),

          // 2. 해설 및 버튼 카드
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 30), // 마진 조정
            padding: const EdgeInsets.all(24), // 패딩 조정
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // 해설 본문 (타이틀/구분선 삭제, 본문 위주로)
                Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 버튼 영역
                Row(
                  children: [
                    // '다시 풀기' 버튼 (회색)
                    Expanded(
                      child: ElevatedButton(
                        child: const Text("다시 풀기"),
                        onPressed: onTryAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black54,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // '다음 문제' 또는 '퀴즈 정리하기' 버튼 (네이비)
                    Expanded(
                      child: ElevatedButton(
                        child: Text(isLastProblem ? "결과 보기" : "다음 문제"), // 텍스트 변경
                        onPressed: isLastProblem ? onShowSummary : onNextProblem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryNavy, // 네이비색 적용
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}