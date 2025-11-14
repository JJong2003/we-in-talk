// lib/screens/saejong_chat_screen.dart

import 'package:flutter/material.dart';
import '../widgets/event_flow_widget.dart';
import '../widgets/chat_view.dart';

// 1-1. StatelessWidget -> StatefulWidget로 변경
class SaejongChatScreen extends StatefulWidget {
  const SaejongChatScreen({Key? key}) : super(key: key);

  @override
  State<SaejongChatScreen> createState() => _SaejongChatScreenState();
}

class _SaejongChatScreenState extends State<SaejongChatScreen> {
  // 1-2. Scaffold를 제어하기 위한 GlobalKey 추가
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져오기 (캐릭터 이미지 크기 조절에 사용)
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // 1-3. key 연결
      key: _scaffoldKey,
      // 1. AppBar 설정 (배경이 보이도록 투명하게)
      extendBodyBehindAppBar: true, // Body를 AppBar 뒤까지 확장
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경색 투명
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white), // 이미지의 아이콘
            onPressed: () {
              // 1-4. showModalBottomSheet -> openEndDrawer로 변경
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      // 1-5. endDrawer 속성 추가 (오른쪽에서 나오는 Drawer)
      endDrawer: Drawer(
        // ChatView 위젯을 Drawer의 자식으로 넣음
        child: const ChatView(),
      ),

      // --- Body 부분은 수정사항 없음 ---
      body: Stack(
        children: [
          // 레이어 1: 배경 이미지 (화면 전체)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // TODO: 'assets/images/saejong_background.png' 경로에 배경 이미지 추가
                image: AssetImage("assets/images/kingsaejong/saejong_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 레이어 2: 세종대왕 캐릭터 (하단 중앙)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // 화면 높이의 약 75%를 차지하도록 설정 (조절 가능)
              height: screenSize.height * 0.75,
              // TODO: 'assets/images/saejong_character.png' 경로에 캐릭터 이미지 추가
              child: Image.asset(
                "assets/images/kingsaejong/saejong_character.png",
                fit: BoxFit.fitHeight,
              ),
            ),
          ),

          // 레이어 3: 사건 흐름 위젯 (상단 좌측)
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