import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRecording = false;
  final Widget _appDrawer = AppDrawer();

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.month}월 ${now.day}일";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A237E);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFDFBF7), // 크림색 배경
      drawer: _appDrawer,

      // AppBar 디자인 (투명)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_open, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 환영 메시지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTodayDate(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: widget.userName, style: const TextStyle(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.bold)),
                        const TextSpan(text: "님,\n오늘도 역사를 배워볼까요?", style: TextStyle(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.w300, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 2. 정보 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("오늘의 역사 상식", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                        SizedBox(height: 4),
                        Text("세종대왕은 고기를 매우 좋아하셨다는 사실, 알고 계셨나요?", style: TextStyle(fontSize: 15, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 3. 메인 마이크 버튼 (물결 & 진동)
            Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact(); // 햅틱 진동 추가
                  setState(() { _isRecording = !_isRecording; });
                },
                child: _isRecording ? _buildRecordingState() : _buildOfflineState(),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // 오프라인 상태 (흰색 입체 버튼)
  Widget _buildOfflineState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 5))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Icon(Icons.mic_none, color: Colors.grey[400], size: 70),
        ),
        const SizedBox(height: 24),
        Text("버튼을 눌러\n대화를 시작하세요", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 16, height: 1.5)),
      ],
    );
  }

  // 녹음 중 상태 (네이비 그라데이션 + 물결)
  Widget _buildRecordingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarGlow(
          glowColor: const Color(0xFF1A237E), // 네이비색 물결
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.4), blurRadius: 20.0, spreadRadius: 2.0, offset: const Offset(0, 5))],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 70),
          ),
        ),
        const SizedBox(height: 16),
        const Text("듣고 있습니다...", style: TextStyle(color: Color(0xFF1A237E), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }
}