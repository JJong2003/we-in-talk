// lib/screens/login_screen.dart
//아이디 admin@naver.com 비번 123456

import 'package:flutter/material.dart';
// 1. Firebase Auth와 HomeScreen import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weintalk/screens/home_screen.dart';
import 'package:weintalk/screens/signup_screen.dart';

// 2. StatelessWidget -> StatefulWidget으로 변경
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 3. ID(Email)와 비밀번호 컨트롤러 선언
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 4. 로딩 상태 변수
  bool _isLoading = false;

  // 5. 컨트롤러 리소스 해제
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 6. Firebase 로그인 로직 함수
  Future<void> _signIn() async {
    // 7. 로딩 시작
    setState(() {
      _isLoading = true;
    });

    try {
      // 8. Firebase Auth로 로그인 시도
      // (중요!) Firebase Auth는 '아이디'가 아닌 '이메일'로 로그인합니다.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 9. 로그인 성공 시 HomeScreen으로 이동 (pushReplacement)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      // 10. 에러 처리
      String errorMessage = '로그인에 실패했습니다.';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
          errorMessage = '이메일 또는 비밀번호가 일치하지 않습니다.';
        } else if (e.code == 'user-not-found') {
          errorMessage = '존재하지 않는 계정입니다.';
        } else if (e.code == 'invalid-email') {
          errorMessage = '유효하지 않은 이메일 형식입니다.';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 11. 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              // --- 1. 로고 이미지 (동일) ---
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

              // --- 2. 입력 필드 및 로그인 버튼 (SizedBox 너비 350 제한) ---
              SizedBox(
                width: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // 12. 컨트롤러 연결
                          _buildTextField(Icons.person_outline, '아이디 (이메일)', _emailController),
                          const SizedBox(height: 12),
                          _buildTextField(Icons.lock_outline, '비밀번호', _passwordController, isPassword: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 116,
                      child: ElevatedButton(
                        // 13. onPressed에 _signIn 함수 연결 (로딩 중 비활성화)
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF333333),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24),
                        ),
                        // 14. 로딩 중이면 인디케이터 표시
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('로그인'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. 계정 생성하기 텍스트 버튼 (동일) ---
              TextButton(
                onPressed: () {
                  print('계정 생성하기 클릭됨');
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
            ],
          ),
        ),
      ),
    );
  }

  // 15. _buildTextField 함수가 컨트롤러를 받도록 수정
  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller, // 컨트롤러 연결
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