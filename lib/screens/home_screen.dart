import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 앱 바 및 하단 바의 기본 배경색을 흰색으로 설정
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // 아이콘 및 텍스트 색상
          elevation: 0,
        ),
        // Scaffold의 기본 배경색 설정 (앱 프레임 색상)
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // 이미지의 여백과 비슷한 색
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단 바의 아래쪽 경계선
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300]!,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로가기 기능 구현
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // 메뉴 기능 구현
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand, // Stack의 자식들이 body 전체를 채우도록 함
        children: [
          // 1. 배경 이미지
          Image.asset(
            'assets/images/kingsaejong/KingSaeJong_standing_photo.png', // 실제 배경 이미지 경로로 변경
            fit: BoxFit.cover, // 화면에 꽉 차게 표시
          ),

          // 2. '사건 흐름' 카드
          Positioned(
            top: 20.0,
            left: 20.0,
            child: _buildEventFlowCard(),
          ),

          // 3. 중앙 캐릭터 (의도적으로 비워둠)
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset('assets/images/character.png'), // 캐릭터는 여기에 추가
          // ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        // 'shape' 프로퍼티를 제거하고, 'child'를 Container로 감싸서 테두리를 구현합니다.
        child: Container(
          // Container의 decoration을 사용하여 테두리 설정
          decoration: BoxDecoration(
            border: Border(
              // 위쪽 테두리만 설정
              top: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // 아이콘을 오른쪽으로 정렬
            children: [
              IconButton(
                icon: Icon(Icons.subject, color: Colors.grey[700]), // 이미지와 유사한 아이콘
                onPressed: () {
                  // 하단 메뉴 기능 구현
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// '사건 흐름' 카드를 생성하는 위젯
  Widget _buildEventFlowCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // 반투명한 흰색 배경
        borderRadius: BorderRadius.circular(25.0), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞게 조절
        children: [
          Text(
            '사건 흐름',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildEventStep('assets/images/SunClock.png', '앙부일구'),
              _buildArrow(),
              _buildEventStep('assets/images/RainMeasure.png', '측우기'),
              _buildArrow(),
              _buildEventStep('assets/images/Hangeul.png', '훈민정음'),
            ],
          ),
        ],
      ),
    );
  }

  /// '사건 흐름'의 각 단계를 생성하는 위젯
  Widget _buildEventStep(String imagePath, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(imagePath), // 각 단계별 이미지 경로
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ],
    );
  }

  /// 단계 사이의 화살표 아이콘
  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0), // 아이콘 높이 맞춤
      child: Icon(
        Icons.arrow_forward,
        size: 18,
        color: Colors.grey[700],
      ),
    );
  }
}