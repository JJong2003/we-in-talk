// lib/widgets/quiz_screen.dart

import 'package:flutter/material.dart';
import 'quiz_result_overlay.dart';
import 'quiz_summary_view.dart';

// 퀴즈 문제 데이터 모델
class QuizProblem {
  final String question;
  final bool answer; // true: O, false: X
  final String explanation;
  final String summaryQuestion; // 정리 화면용 질문
  final String summaryAnswer; // 정리 화면용 답변

  QuizProblem({
    required this.question,
    required this.answer,
    required this.explanation,
    required this.summaryQuestion,
    required this.summaryAnswer,
  });
}

// 퀴즈 화면의 상태를 정의 (문제풀이중, 결과확인중, 최종요약)
enum QuizState { viewingQuestion, showingResult, viewingSummary }

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // --- 퀴즈 데이터 및 상태 변수 ---
  QuizState _quizState = QuizState.viewingQuestion;
  int _currentProblemIndex = 0;
  bool? _selectedAnswer; // O(true) 또는 X(false)
  bool _isCorrect = false;

  // Mock 퀴즈 데이터 (이미지 1, 3 참고)
  final List<QuizProblem> _problems = [
    QuizProblem(
        question: "1. 훈민정음이 창제되기 전에는 우리말을 표기할 문자가 있었다.",
        answer: true,
        explanation: "훈민정음은 1443년에 '창제'되었고, 3년 뒤인 1446년에 '반포'되었습니다. '창제'와 '반포'는 시점이 달라 자주 혼동합니다.",
        summaryQuestion: "문제 1. 훈민정음 창제 전에도 우리말 표기가 있었나?",
        summaryAnswer: "한자의 음(소리)이나 훈(뜻)을 빌려 우리말을 표기하는 '이두(吏讀)' 등이 사용되었습니다."
    ),
    QuizProblem(
        question: "2. 수양대군은 한글 창제에 찬성했다.",
        answer: true,
        explanation: "수양대군은 훈민정음 창제를 적극적으로 도운 핵심 인물 중 하나였습니다.",
        summaryQuestion: "문제 2. 수양대군은 한글창제에 찬성했나?",
        summaryAnswer: "수양대군은 훈민정음 창제를 적극적으로 도운 핵심 인물 중 하나였습니다."
    ),
    QuizProblem(
        question: "3. 우리가 기념하는 한글날은 훈민정음을 창제한 것을 기념하는 날일까요?",
        answer: false,
        explanation: "한글날(10월 9일)은 이 '반포'된 날을 기준으로 기념하는 날입니다. '창제'와 '반포'는 시점이 달라 자주 혼동합니다.",
        summaryQuestion: "문제 3. 한글날은 훈민정음의 어떤 것을 기념하는 날인가?",
        summaryAnswer: "한글날은 훈민정음의 반포(공개)를 기념하는 날 입니다."
    ),
  ];
  // ---

  // '제출' 버튼 클릭 시
  void _submitAnswer() {
    if (_selectedAnswer == null) return; // 답을 선택하지 않으면 무시

    setState(() {
      _isCorrect = (_selectedAnswer == _problems[_currentProblemIndex].answer);
      _quizState = QuizState.showingResult; // '결과' 상태로 변경
    });
  }

  // '다음 문제' 버튼 클릭 시
  void _nextProblem() {
    setState(() {
      _currentProblemIndex++;
      _selectedAnswer = null;
      _quizState = QuizState.viewingQuestion; // '문제' 상태로 변경
    });
  }

  // '퀴즈 정리하기' 버튼 클릭 시
  void _showSummary() {
    setState(() {
      _quizState = QuizState.viewingSummary; // '정리' 상태로 변경
    });
  }

  // '퀴즈 다시 풀기' (질문하기 버튼)
  void _restartQuiz() {
    setState(() {
      _currentProblemIndex = 0;
      _selectedAnswer = null;
      _quizState = QuizState.viewingQuestion;
    });
  }


  @override
  Widget build(BuildContext context) {
    bool isLastProblem = _currentProblemIndex == _problems.length - 1;

    // Stack을 사용해 문제 화면과 결과 화면을 겹침
    return Stack(
      children: [
        // 1. 퀴즈 본체 (문제 또는 최종 정리)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _quizState == QuizState.viewingSummary
              ? QuizSummaryView( // '정리' 화면
            problems: _problems,
            onRestart: _restartQuiz,
          )
              : _buildQuestionView(), // '문제' 화면
        ),

        // 2. 결과 오버레이 (결과 보여주기 상태일 때만)
        if (_quizState == QuizState.showingResult)
          QuizResultOverlay(
            isCorrect: _isCorrect,
            explanation: _problems[_currentProblemIndex].explanation,
            isLastProblem: isLastProblem,
            onNextProblem: _nextProblem,
            onShowSummary: _showSummary,
            onTryAgain: _restartQuiz, // '질문하기' 버튼 -> 퀴즈 재시작
          ),
      ],
    );
  }

  // '문제' 화면을 그리는 위젯 (이미지 1)
  Widget _buildQuestionView() {
    QuizProblem currentProblem = _problems[_currentProblemIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 퀴즈 상단바 (좌우 화살표, 닫기)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.grey),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.grey),
                ],
              ),
              Icon(Icons.close, color: Colors.black),
            ],
          ),

          // 문제 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Text(
              currentProblem.question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // O / X 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOxButton("O", _selectedAnswer == true),
              SizedBox(width: 20),
              _buildOxButton("X", _selectedAnswer == false),
            ],
          ),

          SizedBox(height: 20),

          // 제출 버튼
          ElevatedButton(
            child: Text("제출"),
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: Size(100, 40),
            ),
          ),
        ],
      ),
    );
  }

  // O / X 버튼 위젯
  Widget _buildOxButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = (text == "O");
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}