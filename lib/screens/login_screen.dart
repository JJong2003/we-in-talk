// lib/screens/login_screen.dart
//아이디 admin@naver.com 비번 123456

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weintalk/screens/home_screen.dart';
import 'package:weintalk/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      String userName = user?.displayName ?? "김철수";

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userName: userName),),
        );
      }
    } catch (e) {
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // [main.dart의 Theme 설정을 따름]
    const Color primaryNavy = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 크림색 배경
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. 로고 이미지 ---
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
                          // TextField는 main.dart의 InputDecorationTheme를 따름
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
                        onPressed: _isLoading ? null : _signIn,
                        // [디자인 변경] primaryNavy는 Theme에서 자동 상속 받음
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: primaryNavy, // Theme에서 상속
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 좀 더 둥글게
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          elevation: 0, // 입체감은 Theme에서 관리
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. 계정 생성하기 텍스트 버튼 ---
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  '계정 생성하기',
                  style: TextStyle(
                    color: primaryNavy, // 네이비색 포인트
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

  // [디자인 변경] InputTheme을 사용하도록 TextField의 Decoration을 단순화
  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      // Decoration을 비워두어 main.dart의 InputDecorationTheme를 상속받게 함
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        // 나머지 border 관련 설정은 Theme에서 가져옴
      ),
      style: TextStyle(color: Colors.black87),
      cursorColor: Theme.of(context).primaryColor,
    );
  }
}