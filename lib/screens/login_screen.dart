import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'History AI Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(), // 앱 시작 시 LoginScreen을 보여줍니다.
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색을 흰색으로 설정
      body: Center(
        child: SingleChildScrollView( // 화면이 작아질 경우 스크롤 가능하도록
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. 로고 이미지 ---
              Container(
                width: 250, // 로고 너비
                height: 200, // 로고 높이
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // 모서리 둥글게
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // 그림자 색상
                      spreadRadius: 2, // 그림자 퍼짐 정도
                      blurRadius: 10, // 그림자 흐림 정도
                      offset: Offset(0, 5), // 그림자 위치 (x, y)
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  // 실제 로고 이미지를 assets/images/logo.png 경로에 넣어주세요.
                  // pubspec.yaml 파일에 assets/images/ 경로를 등록해야 합니다.
                  child: Image.asset(
                    'assets/images/logo.png', // <-- 여기에 실제 로고 이미지 경로를 넣어주세요.
                    fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 채움
                  ),
                ),
              ),
              const SizedBox(height: 50), // 로고와 입력 필드 사이 간격

              // --- 2. 아이디, 비밀번호 입력 필드 및 로그인 버튼 ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // 버튼과 텍스트필드 정렬을 위함
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildTextField(Icons.person_outline, '아이디'),
                        const SizedBox(height: 12), // 아이디와 비밀번호 필드 사이 간격
                        _buildTextField(Icons.lock_outline, '비밀번호', isPassword: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // 입력 필드와 로그인 버튼 사이 간격
                  SizedBox(
                    height: 116, // 두 텍스트 필드의 총 높이에 맞춰 로그인 버튼 높이 설정
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 로그인 버튼 클릭 시 수행할 로직 구현
                        print('로그인 버튼 클릭됨');
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF333333), // 버튼 배경색 (짙은 회색)
                        foregroundColor: Colors.white, // 버튼 텍스트 색상
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24), // 버튼 내부 패딩
                      ),
                      child: Text('로그인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30), // 로그인 섹션과 '계정 생성하기' 사이 간격

              // --- 3. 계정 생성하기 텍스트 버튼 ---
              TextButton(
                onPressed: () {
                  // TODO: '계정 생성하기' 클릭 시 수행할 로직 구현
                  print('계정 생성하기 클릭됨');
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text(
                  '계정 생성하기',
                  style: TextStyle(
                    color: Colors.grey[700], // 텍스트 색상
                    decoration: TextDecoration.underline, // 밑줄
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12), // '계정 생성하기'와 '회원가입' 버튼 사이 간격

              // --- 4. 회원가입 버튼 ---
              // ElevatedButton(
              //   onPressed: () {
              //     // TODO: '회원가입' 버튼 클릭 시 수행할 로직 구현
              //     print('회원가입 버튼 클릭됨');
              //     // Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF333333), // 버튼 배경색 (짙은 회색)
              //     foregroundColor: Colors.white, // 버튼 텍스트 색상
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
              //     ),
              //     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // 버튼 내부 패딩
              //   ),
              //   child: Text('회원가입', style: TextStyle(fontSize: 16)),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 공통 TextField 위젯 (아이콘, 힌트 텍스트, 비밀번호 마스킹) ---
  Widget _buildTextField(IconData icon, String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword, // isPassword가 true면 텍스트를 숨깁니다.
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]), // 텍스트 필드 왼쪽 아이콘
        hintText: hintText, // 힌트 텍스트
        hintStyle: TextStyle(color: Colors.grey[400]), // 힌트 텍스트 스타일
        // 밑줄 스타일 설정
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!), // 기본 밑줄 색상
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent), // 포커스 시 밑줄 색상
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0), // 텍스트 필드 내부 패딩
      ),
      style: TextStyle(color: Colors.black87), // 입력 텍스트 색상
      cursorColor: Colors.blueAccent, // 커서 색상
    );
  }
}