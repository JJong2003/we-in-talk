// main.dart (LoginScreen 부분)

// 1. home_screen.dart와 signup_screen.dart를 import 합니다.
import 'package:flutter/material.dart';
import 'package:weintalk/screens/home_screen.dart';
import 'package:weintalk/screens/signup_screen.dart'; // 회원가입 화면 import

// (MyApp 클래스는 동일합니다...)

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. 로고 이미지 --- (이 부분은 동일)
              Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // --- 2. 입력 필드 및 로그인 버튼 (SizedBox로 감싸기) ---
              // 이 SizedBox가 최대 너비를 350으로 제한하고, Center가 가운데 정렬합니다.
              SizedBox(
                width: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(Icons.person_outline, '아이디'),
                          const SizedBox(height: 12),
                          _buildTextField(Icons.lock_outline, '비밀번호', isPassword: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 116,
                      child: ElevatedButton(
                        onPressed: () {
                          print('로그인 버튼 클릭됨');
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF333333),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Text('로그인'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. 계정 생성하기 텍스트 버튼 ---
              TextButton(
                onPressed: () {
                  print('계정 생성하기 클릭됨');
                  // SignupScreen으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  '계정 생성하기',
                  style: TextStyle(
                    color: Colors.grey[700],
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
              // (주석 처리된 4번 회원가입 버튼은 제거했습니다)
            ],
          ),
        ),
      ),
    );
  }

  // --- 공통 TextField 위젯 (이 부분은 동일) ---
  Widget _buildTextField(IconData icon, String hintText, {bool isPassword = false}) {
    // ... (기존 코드와 동일)
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      style: TextStyle(color: Colors.black87),
      cursorColor: Colors.blueAccent,
    );
  }
}