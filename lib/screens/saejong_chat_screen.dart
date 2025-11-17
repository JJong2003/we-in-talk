import 'package:flutter/material.dart';
import '../widgets/event_flow_widget.dart';
import '../widgets/chat_view.dart'; // [중요] 1단계에서 수정한 ChatView여야 합니다.

class SaejongChatScreen extends StatefulWidget {
  const SaejongChatScreen({Key? key}) : super(key: key);

  @override
  State<SaejongChatScreen> createState() => _SaejongChatScreenState();
}

class _SaejongChatScreenState extends State<SaejongChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // [1] '퀴즈 모드'인지 여부를 부모 스크린이 관리합니다.
  bool _isQuizMode = false;
  // 퀴즈 중 세종대왕 위치를 제어할 새 상태 추가
  bool _isKingCentered = false;

  // 퀴즈 모드/채팅 모드 전환 함수
  void _toggleQuizMode(bool isQuiz) {
    setState(() {
      _isQuizMode = isQuiz;
      // 퀴즈 모드가 되면, 항상 세종대왕은 왼쪽에서 시작
      if (isQuiz) {
        _isKingCentered = false;
      }
    });
  }

  // 퀴즈 중 세종대왕 위치만 바꾸는 함수
  void _toggleKingPosition(bool isCentered) {
    setState(() {
      _isKingCentered = isCentered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // [2] _isQuizMode 상태에 따라 패널 너비와 세종대왕 위치를 결정합니다.

    // 퀴즈 모드일 때: 화면 너비의 55%
    // 채팅 모드일 때: 화면 너비의 35% (값은 원하시는 대로 조절하세요)
    final double panelWidth = screenSize.width * (_isQuizMode ? 0.55 : 0.35);

    // 퀴즈 모드일 때: 하단 좌측 (x: -0.5, y: 1.0)
    // 채팅 모드일 때: 하단 중앙 (x: 0.0, y: 1.0)
    final Alignment sejongAlignment;
    if(!_isQuizMode){
      sejongAlignment = const Alignment(0.0, 1.0);
    } else{
      sejongAlignment = _isKingCentered
          ? const Alignment(0.0, 1.0)
          : const Alignment(-0.55, 1.0);
    }

    return Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
              _isKingCentered = false;
              _toggleKingPosition(false);
            },
          ),
        ],
      ),

      // [3] endDrawer를 수정합니다.
      endDrawer: Drawer(
        // [2]에서 계산한 동적 너비를 적용합니다.
        width: panelWidth,
        // [중요] ChatView에 상태와 콜백 함수를 전달합니다.
        child: ChatView(
          isQuizMode: _isQuizMode, // 현재 퀴즈 모드 상태 전달
          onToggleQuizMode: _toggleQuizMode,
          onToggleKingPosition: _toggleKingPosition,
          // onToggleQuizMode: (isQuiz) {
          //   // ChatView에서 버튼이 눌리면 이 함수가 실행됨
          //   setState(() {
          //     _isQuizMode = isQuiz; // 부모의 상태를 변경
          //   });
          // },
        ),
      ),

      body: Stack(
        children: [
          // 레이어 1: 배경 이미지 (기존과 동일)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/kingsaejong/saejong_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 레이어 2: 세종대왕 캐릭터 (기존과 동일)
          AnimatedAlign(
            alignment: sejongAlignment, // [1]에서 정의한 값을 사용
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Container(
              height: screenSize.height * 0.75,
              child: Image.asset(
                "assets/images/kingsaejong/saejong_character.png",
                fit: BoxFit.fitHeight,
              ),
            ),
          ),

          // 레이어 3: 사건 흐름 위젯 (변경 없음)
          Positioned(
            top: kToolbarHeight + 16.0,
            left: 16.0,
            child: const EventFlowWidget(),
          ),
        ],
      ),
    );
  }
}