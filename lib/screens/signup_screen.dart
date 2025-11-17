// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
// 1. Firebase Auth 패키지 import
import 'package:firebase_auth/firebase_auth.dart';

// 2. StatelessWidget -> StatefulWidget으로 변경
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 3. 컨트롤러 선언 (ID 컨트롤러 제거)
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  // 4. 로딩 상태 관리를 위한 변수
  bool _isLoading = false;

  // 5. 컨트롤러 리소스 해제 (ID 컨트롤러 제거)
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // 6. 실제 회원가입 로직을 처리할 함수
  Future<void> _signUp() async {
    // 로딩 시작
    setState(() {
      _isLoading = true;
    });

    try {
      // 6-1. 비밀번호 일치 확인
      if (_passwordController.text != _passwordConfirmController.text) {
        throw '비밀번호가 일치하지 않습니다.';
      }

      // 6-2. Firebase Auth로 이메일/비밀번호 유저 생성
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 6-3. (중요) 생성된 유저 정보에 '이름(DisplayName)' 업데이트
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        // (ID 관련 로직 완전 제거)
      }

      // 6-4. 성공 시 화면 스택에서 제거 (로그인 화면으로 돌아가기)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 로그인해 주세요.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      // 6-5. 에러 처리
      String errorMessage = '회원가입에 실패했습니다.';
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          errorMessage = '비밀번호가 너무 짧습니다. (6자 이상)';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = '이미 사용 중인 이메일입니다.';
        } else if (e.code == 'invalid-email') {
          errorMessage = '유효하지 않은 이메일 형식입니다.';
        }
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 로딩 종료
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

              // --- 2. 회원가입 입력 필드 (SizedBox로 너비 350 제한) ---
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    // 7. 컨트롤러 연결 (ID 필드 제거, 힌트 텍스트 변경)
                    _buildTextField(Icons.email_outlined, '이메일 (로그인 ID)', _emailController),
                    const SizedBox(height: 12),
                    _buildTextField(Icons.badge_outlined, '이름 (AI 튜터가 부를 이름)', _nameController),
                    const SizedBox(height: 12),
                    // (ID 필드 제거됨)
                    _buildTextField(Icons.lock_outline, '비밀번호', _passwordController, isPassword: true),
                    const SizedBox(height: 12),
                    _buildTextField(Icons.lock_outline, '비밀번호 확인', _passwordConfirmController, isPassword: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. 회원가입 버튼 (동일) ---
              SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333330),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('계정 생성하기', style: TextStyle(fontSize: 16)),
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

  // 10. _buildTextField 함수 (동일)
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