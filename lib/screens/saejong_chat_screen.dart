// lib/screens/saejong_chat_screen.dart

import 'package:flutter/material.dart';
import '../widgets/event_flow_widget.dart';
import '../widgets/chat_view.dart';

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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/kingsaejong/saejong_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedAlign(
            alignment: sejongAlignment,
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