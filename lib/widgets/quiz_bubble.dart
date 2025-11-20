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

  // Mock 퀴즈 데이터 (원본 유지)
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

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    setState(() {
      _isCorrect = (_selectedAnswer == _problems[_currentProblemIndex].answer);
      _quizState = QuizState.showingResult;
    });
  }

  void _nextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedAnswer = null;
        _quizState = QuizState.viewingQuestion;
      });
    } else {
      _showSummary();
    }
  }

  void _goToPreviousProblem() {
    if (_currentProblemIndex > 0) {
      setState(() {
        _currentProblemIndex--;
        _selectedAnswer = null;
        _quizState = QuizState.viewingQuestion;
      });
    }
  }

  void _goToNextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedAnswer = null;
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

  void _retryCurrentProblem() {
    setState(() {
      _selectedAnswer = null;
      _quizState = QuizState.viewingQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLastProblem = _currentProblemIndex == _problems.length - 1;
    const Color primaryNavy = Color(0xFF1A237E);

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(20.0), // 마진 조정
      padding: const EdgeInsets.all(24.0), // 패딩 조정
      decoration: BoxDecoration(
        color: Colors.white, // [디자인 변경] 배경 흰색
        borderRadius: BorderRadius.circular(24.0),
        // [디자인 변경] 테두리 제거, 그림자 추가
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단바: 화살표 + 프로그레스 바 + 닫기 버튼
          Row(
            children: [
              // 1. 화살표 버튼 그룹 (디자인 변경)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 18,
                        color: _currentProblemIndex > 0 ? primaryNavy : Colors.grey[300]), // 네이비색 적용
                    onPressed: _goToPreviousProblem,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 18,
                        color: _currentProblemIndex < _problems.length - 1 ? primaryNavy : Colors.grey[300]), // 네이비색 적용
                    onPressed: _goToNextProblem,
                  ),
                ],
              ),
              Expanded(
                child: _buildProgressBar(),
              ),
              // 3. 닫기 버튼 (아이콘 변경)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  widget.onToggleQuizMode(false);
                },
              ),
            ],
          ),

          const Divider(height: 30), // 구분선 추가

          // 메인 컨텐츠 영역
          Expanded(
            child: Stack(
              children: [
                _quizState == QuizState.viewingSummary
                    ? QuizSummaryView(
                  problems: _problems,
                  onRestart: _restartQuiz,
                  onClose: (){
                    widget.onToggleQuizMode(false);
                  },
                )
                    : _buildQuestionView(),

                if (_quizState == QuizState.showingResult)
                  QuizResultOverlay(
                    isCorrect: _isCorrect,
                    explanation: _problems[_currentProblemIndex].explanation,
                    isLastProblem: isLastProblem,
                    onNextProblem: _nextProblem,
                    onShowSummary: _showSummary,
                    onTryAgain: _retryCurrentProblem,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // [디자인 변경] 프로그레스 바 색상
  Widget _buildProgressBar() {
    const Color primaryNavy = Color(0xFF1A237E);

    return Row(
      children: List.generate(_problems.length, (index) {
        bool isActive = index == _currentProblemIndex;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 8.0,
            decoration: BoxDecoration(
              // 네이비색 적용
              color: isActive ? primaryNavy : Colors.grey[200],
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        );
      }),
    );
  }

  // [디자인 변경] 질문 뷰
  Widget _buildQuestionView() {
    QuizProblem currentProblem = _problems[_currentProblemIndex];
    const Color primaryNavy = Color(0xFF1A237E);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        // Q 번호 강조
        Text(
          "Q${_currentProblemIndex + 1}.",
          style: const TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 16),
        // 문제 텍스트
        Text(
          currentProblem.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.4, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 1),

        // O / X 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOxButton("O", _selectedAnswer == true),
            const SizedBox(width: 24), // 간격 조정
            _buildOxButton("X", _selectedAnswer == false),
          ],
        ),

        const Spacer(flex: 2),

        // 제출 버튼
        SizedBox(
          width: double.infinity, // 너비 확장
          height: 56, // 높이 조정
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy, // 네이비색 적용
              foregroundColor: Colors.white,
              elevation: 0, // Theme에서 그림자 관리
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // 둥근 모서리
              ),
            ),
            child: const Text("정답 확인하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 텍스트 변경
          ),
        ),
      ],
    );
  }

  // [디자인 변경] O/X 버튼
  Widget _buildOxButton(String text, bool isSelected) {
    const Color primaryNavy = Color(0xFF1A237E);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = (text == "O");
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100, // 크기 조정
        height: 100, // 크기 조정
        decoration: BoxDecoration(
          color: isSelected ? primaryNavy : Colors.white, // 선택되면 네이비, 아니면 흰색
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryNavy.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 48, // 크기 조정
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade300, // 색상 조정
            ),
          ),
        ),
      ),
    );
  }
}