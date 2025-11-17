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
    // 오버레이 색상 결정
    Color primaryColor = isCorrect ? Colors.green : Colors.red;
    IconData iconData = isCorrect ? Icons.check_circle : Icons.cancel;
    String title = isCorrect ? "정답입니다!" : "오답입니다!";

    return Container(
      // 1. 뒷배경을 어둡게 (딤드)
      color: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2. '정답/오답' 아이콘 및 텍스트
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white, size: 80),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // Text에 기본 적용되는 밑줄 제거
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 3. 해설 및 버튼 카드
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                // 해설 타이틀
                Row(
                  children: [
                    Icon(iconData, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),

                // 해설 텍스트
                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 20),

                // 버튼 영역
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // '질문하기' (퀴즈 재시작) 버튼
                    ElevatedButton(
                      child: Text("질문 하기"),
                      onPressed: onTryAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black54,
                      ),
                    ),

                    // '다음 문제' 또는 '퀴즈 정리하기' 버튼
                    ElevatedButton(
                      // 마지막 문제인지 여부에 따라 버튼 텍스트와 기능 변경
                      child: Text(isLastProblem ? "퀴즈 정리" : "다음 문제"),
                      onPressed: isLastProblem ? onShowSummary : onNextProblem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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