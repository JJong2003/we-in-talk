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

  bool _isQuizMode = false;
  bool _isKingCentered = false;

  // ★★★ [수정 핵심] true -> false로 변경! (처음엔 듣지 말고 말하기 위해) ★★★
  bool _isRecording = false;

  void _toggleQuizMode(bool isQuiz) {
    setState(() {
      _isQuizMode = isQuiz;
      if (isQuiz) {
        _isKingCentered = false;
      }
    });
  }

  void _toggleKingPosition(bool isCentered) {
    setState(() {
      _isKingCentered = isCentered;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double panelWidth = screenSize.width * (_isQuizMode ? 0.55 : 0.35);

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

      // [수정] 드로어가 닫힐 때 상태를 채팅 모드로 초기화하여 세종대왕 중앙 복귀
      onEndDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() {
            _isQuizMode = false;
            _isKingCentered = false;
          });
        }
      },

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
              // 드로어를 열 때는 캐릭터 위치 초기화
              setState(() {
                _isKingCentered = false;
              });
            },
          ),
        ],
      ),

      endDrawer: Drawer(
        width: panelWidth,
        child: ChatView(
          isQuizMode: _isQuizMode,
          onToggleQuizMode: _toggleQuizMode,
          onToggleKingPosition: _toggleKingPosition,
          isRecording: _isRecording,
          onToggleRecording: _toggleRecording,
        ),
      ),

      body: Stack(
        children: [
          // 배경 이미지 (변동 없음)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/kingsaejong/saejong_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 세종대왕 캐릭터 (변동 없음)
          AnimatedAlign(
            alignment: sejongAlignment,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: screenSize.height * 0.75,
              child: Image.asset(
                "assets/images/kingsaejong/saejong_character.png",
                fit: BoxFit.fitHeight,
              ),
            ),
          ),

          // 사건 흐름 위젯 (EventFlowWidget)
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