// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. 로고 이미지 (동일) ---
              Container(
                width: 250,
                height: 200,
                // ... (기존 코드와 동일)
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

              // --- 2. 회원가입 입력 필드 (SizedBox로 감싸기) ---
              // 이 SizedBox가 최대 너비를 350으로 제한하고, Center가 가운데 정렬합니다.
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    _buildTextField(Icons.email_outlined, '이메일 (인증용)'),
                    const SizedBox(height: 12),
                    _buildTextField(Icons.badge_outlined, '이름 (AI 튜터가 부를 이름)'),
                    const SizedBox(height: 12),
                    _buildTextField(Icons.person_outline, '아이디'),
                    const SizedBox(height: 12),
                    _buildTextField(Icons.lock_outline, '비밀번호', isPassword: true),
                    const SizedBox(height: 12),
                    // 'lock_check_outlined' 대신 'lock_outline' 또는 'check_circle_outline' 사용
                    _buildTextField(Icons.lock_outline, '비밀번호 확인', isPassword: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. 회원가입 버튼 (SizedBox로 감싸기) ---
              // 너비를 위와 동일하게 350으로 맞춰줍니다.
              SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    print('회원가입 버튼 클릭됨');
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333333),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('계정 생성하기', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),

              // --- 4. 로그인 화면으로 돌아가기 (동일) ---
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '이미 계정이 있으신가요? 로그인',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 공통 TextField 위젯 (동일) ---
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