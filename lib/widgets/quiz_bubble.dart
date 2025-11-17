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

// 퀴즈 화면의 상태를 정의
enum QuizState { viewingQuestion, showingResult, viewingSummary }

class QuizScreen extends StatefulWidget {
  final ValueChanged<bool> onToggleQuizMode;
  final ValueChanged<bool> onToggleKingPosition;

  const QuizScreen({
    Key? key,
    required this.onToggleQuizMode,
    required this.onToggleKingPosition,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizState _quizState = QuizState.viewingQuestion;
  int _currentProblemIndex = 0;
  bool? _selectedAnswer; // O(true) 또는 X(false)
  bool _isCorrect = false;

  // Mock 퀴즈 데이터
  final List<QuizProblem> _problems = [
    QuizProblem(
        question: "1. 훈민정음이 창제되기 전에는 우리말을 표기할 문자가 있었다.",
        answer: true,
        explanation: "훈민정음은 1443년에 '창제'되었고, 3년 뒤인 1446년에 '반포'되었습니다.",
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
        explanation: "한글날(10월 9일)은 이 '반포'된 날을 기준으로 기념하는 날입니다.",
        summaryQuestion: "문제 3. 한글날은 훈민정음의 어떤 것을 기념하는 날인가?",
        summaryAnswer: "한글날은 훈민정음의 반포(공개)를 기념하는 날 입니다."
    ),
  ];

  // '제출' 버튼 클릭 시
  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    setState(() {
      _isCorrect = (_selectedAnswer == _problems[_currentProblemIndex].answer);
      _quizState = QuizState.showingResult;
    });
  }

  // '다음 문제'로 이동 (결과 화면에서 사용)
  void _nextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedAnswer = null;
        _quizState = QuizState.viewingQuestion;
      });
    } else {
      // 마지막 문제였다면 요약 화면으로
      _showSummary();
    }
  }

  // '이전 문제'로 이동 (화살표 버튼용)
  void _goToPreviousProblem() {
    if (_currentProblemIndex > 0) {
      setState(() {
        _currentProblemIndex--;
        _selectedAnswer = null; // 문제 이동 시 선택 초기화
        _quizState = QuizState.viewingQuestion;
      });
    }
  }

  // '다음 문제'로 이동 (화살표 버튼용)
  void _goToNextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedAnswer = null; // 문제 이동 시 선택 초기화
        _quizState = QuizState.viewingQuestion;
      });
    }
  }

  void _showSummary() {
    setState(() {
      _quizState = QuizState.viewingSummary;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentProblemIndex = 0;
      _selectedAnswer = null;
      _quizState = QuizState.viewingQuestion;
    });
  }

  // [새로 추가] 현재 문제 다시 풀기 (인덱스 초기화 안 함)
  void _retryCurrentProblem() {
    setState(() {
      // _currentProblemIndex = 0; // <--- 이 줄을 빼서 1번으로 안 돌아가게 함
      _selectedAnswer = null;      // 선택한 답만 초기화
      _quizState = QuizState.viewingQuestion; // 문제 화면으로 복귀
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLastProblem = _currentProblemIndex == _problems.length - 1;

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          // --------------------------------------------------------
          // [수정 1] 상단바: 화살표 + 프로그레스 바 + 닫기 버튼
          // --------------------------------------------------------
          Row(
            children: [
              // 1. 화살표 버튼 그룹
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        // 첫 번째 문제면 회색, 아니면 파란색
                        color: _currentProblemIndex > 0 ? Colors.blue[700] : Colors.grey),
                    onPressed: _goToPreviousProblem, // 이전 문제로 이동
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward,
                        // 마지막 문제면 회색, 아니면 파란색
                        color: _currentProblemIndex < _problems.length - 1 ? Colors.blue[700] : Colors.grey),
                    onPressed: _goToNextProblem, // 다음 문제로 이동
                  ),
                ],
              ),

              const SizedBox(width: 16), // 간격

              // 2. 프로그레스 바 (퀴즈 개수만큼 표시)
              Expanded(
                child: _buildProgressBar(),
              ),

              const SizedBox(width: 16), // 간격

              // 3. 닫기 버튼
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  widget.onToggleQuizMode(false);
                },
              ),
            ],
          ),

          // --------------------------------------------------------
          // [수정 2] 메인 컨텐츠 영역
          // --------------------------------------------------------
          Expanded(
            child: Stack(
              children: [
                // 2-1. 퀴즈 본체 or 요약
                _quizState == QuizState.viewingSummary
                    ? QuizSummaryView(
                  problems: _problems,
                  onRestart: _restartQuiz,
                  onClose: (){
                    widget.onToggleQuizMode(false);
                  },
                )
                    : _buildQuestionView(),

                // 2-2. 결과 오버레이
                if (_quizState == QuizState.showingResult)
                  QuizResultOverlay(
                    isCorrect: _isCorrect,
                    explanation: _problems[_currentProblemIndex].explanation,
                    isLastProblem: isLastProblem,
                    onNextProblem: _nextProblem,
                    onShowSummary: _showSummary,

                    // ----------------------------------------------------
                    // ▼ [수정] _restartQuiz 대신 _retryCurrentProblem 연결
                    // ----------------------------------------------------
                    onTryAgain: _retryCurrentProblem,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // [새로 추가] 프로그레스 바 위젯
  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_problems.length, (index) {
        // 현재 문제인지 확인
        bool isActive = index == _currentProblemIndex;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0), // 바 사이 간격
            height: 6.0, // 바 높이
            decoration: BoxDecoration(
              // 현재 문제는 파란색, 나머지는 연한 파란색(회색 느낌)
              color: isActive ? Colors.blue : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3.0), // 둥근 모서리
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionView() {
    QuizProblem currentProblem = _problems[_currentProblemIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(flex: 1), // 위쪽 여백

        // 문제 텍스트
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            currentProblem.question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(flex: 1), // 중간 여백

        // O / X 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOxButton("O", _selectedAnswer == true),
            const SizedBox(width: 20),
            _buildOxButton("X", _selectedAnswer == false),
          ],
        ),

        const Spacer(flex: 2), // 아래쪽 여백 (버튼을 위로 올림)

        // 제출 버튼
        Align(
          alignment: Alignment.centerRight, // 오른쪽 정렬
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("제출"),
          ),
        ),
      ],
    );
  }

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
          borderRadius: BorderRadius.circular(12.0), // 둥근 사각형
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