// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      if (_passwordController.text != _passwordConfirmController.text) {
        throw '비밀번호가 일치하지 않습니다.';
      }

      // 1. 계정 생성 (원본 로직 유지)
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. DB에 기본 데이터 저장 (원본 로직 유지)
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String name = _nameController.text.trim();
        String email = _emailController.text.trim();

        await userCredential.user!.updateDisplayName(name);

        DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");

        // ★ 세종대왕 기본 데이터 ★
        await userRef.set({
          "profile": {
            "name": name,
            "email": email,
            "createdAt": DateTime.now().toIso8601String(),
          },
          "personas": {
            "persona_sejong": {
              "id": "persona_sejong",
              "name": "세종대왕",
              "desc": "조선의 4대 국왕, 훈민정음 창제",
              "prompt": "너는 조선의 세종대왕이다. 백성을 사랑하는 마음으로 '하오체'(~하오, ~이오)를 써라. 답변은 짧게 하라.",
              "image": "assets/images/kingsaejong/sejong_character.png",
              "voiceSettings": {"pitch": 0.8, "rate": 0.4}
            }
          }
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 완료! 세종대왕님이 기다리고 계십니다.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      print("❌ 에러 발생: $e");
      String message = '회원가입 실패: $e';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') message = '이미 가입된 이메일입니다.';
        if (e.code == 'weak-password') message = '비밀번호는 6자 이상이어야 합니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme에서 네이비 색상 가져오기
    final Color primaryNavy = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: IconThemeData(color: Colors.black)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // 로고
              Container(
                width: 250, height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 50),

              // 입력창 (너비 320 고정)
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    // _buildInput은 main.dart의 Theme를 따름
                    _buildInput(Icons.email_outlined, "이메일 (로그인 ID)", _emailController),
                    const SizedBox(height: 12),
                    _buildInput(Icons.badge_outlined, "이름", _nameController),
                    const SizedBox(height: 12),
                    _buildInput(Icons.lock_outline, "비밀번호", _passwordController, isPw: true),
                    const SizedBox(height: 12),
                    _buildInput(Icons.lock_outline, "비밀번호 확인", _passwordConfirmController, isPw: true),

                    const SizedBox(height: 40),

                    // 버튼 (Theme 상속)
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        // style은 Theme에서 상속
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("계정 생성하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // 로그인 버튼 (네이비색 포인트)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                    '이미 계정이 있으신가요? 로그인',
                    style: TextStyle(
                        color: primaryNavy,
                        fontSize: 14,
                        decoration: TextDecoration.underline
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [디자인 변경] TextField를 Theme에 맞게 단순화
  Widget _buildInput(IconData icon, String hint, TextEditingController ctrl, {bool isPw = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPw,
      // Decoration을 비워두어 main.dart의 InputDecorationTheme를 상속받게 함
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        // 나머지 border 관련 설정은 Theme에서 가져옴
      ),
      style: const TextStyle(color: Colors.black87),
      cursorColor: Theme.of(context).primaryColor,
    );
  }
}