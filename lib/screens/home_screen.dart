// home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // 위에서 만든 Drawer 위젯 import

class HomeScreen extends StatefulWidget {
  // username 저장할 변수
  final String userName;
  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Scaffold의 Drawer를 코드에서 제어하기 위한 GlobalKey
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 마이크의 on/off 상태를 저장하는 변수 (false: OFFLINE, true: RECORDING)
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // key 연결
      // 1. AppBar 구현
      appBar: AppBar(
        // 오른쪽 메뉴 버튼 (Drawer 열기)
        actions: [
          IconButton(
            // icon: const Icon(Icons.menu),
            icon: const Icon(Icons.menu_open),
            onPressed: () {
              // GlobalKey를 이용해 대화창 열기
              // _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
        
        
        // 중앙 제목 (줄바꿈 포함)
        // userName에 따라 바뀌도록 수정
        title: Text(
          '안녕하세요\n${widget.userName}',
          style: const TextStyle(fontSize: 18.0, height: 1.2),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        
        // 배경 색상
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // 2. Drawer 연결
      drawer: const AppDrawer(),
      // 3. Body (메인 컨텐츠)
      body: Center(
        // 3-1. 버튼 클릭 감지를 위한 GestureDetector
        child: GestureDetector(
          onTap: () {
            // 3-2. 버튼 클릭 시 setState를 호출하여 상태 변경
            setState(() {
              _isRecording = !_isRecording; // 현재 상태의 반대값으로 변경
            });
          },
          // 3-3. _isRecording 값에 따라 다른 위젯을 보여줌 (삼항 연산자)
          child: _isRecording
              ? _buildRecordingState() // true일 때 (RECORDING)
              : _buildOfflineState(), // false일 때 (OFFLINE)
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // "OFFLINE" 상태의 위젯을 생성하는 헬퍼 메소드
  Widget _buildOfflineState() {
    // 이미지와 유사하게 검은색 원에 아이콘을 배치
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade800, // 어두운 회색 배경
          ),
          child: const Icon(
            Icons.mic_off,
            color: Colors.white,
            size: 80,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "OFFLINE",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // "RECORDING" 상태의 위젯을 생성하는 헬퍼 메소드
  Widget _buildRecordingState() {
    // 이미지와 유사하게 파란색 원에 아이콘을 배치
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade600, // 파란색 배경
            // "RECORDING" 상태의 빛나는 효과 (간단한 그림자)
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 80,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "RECORDING",
          style: TextStyle(
            color: Colors.blue.shade600,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}