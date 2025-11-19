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

      // 1. 계정 생성
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. DB에 기본 데이터 저장
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String name = _nameController.text.trim();
        String email = _emailController.text.trim();

        await userCredential.user!.updateDisplayName(name);

        DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");

        // ★★★ [수정된 부분] 세종대왕만 남기고 나머지는 삭제 ★★★
        await userRef.set({
          "profile": {
            "name": name,
            "email": email,
            "createdAt": DateTime.now().toIso8601String(),
          },
          "personas": {
            // 1. 세종대왕 (앱의 메인 튜터 - 고정)
            "persona_sejong": {
              "id": "persona_sejong",
              "name": "세종대왕",
              "desc": "조선의 4대 국왕, 훈민정음 창제",
              "prompt": "너는 조선의 세종대왕이다. 백성을 사랑하는 마음으로 '하오체'(~하오, ~이오)를 써라. 답변은 짧게 하라.",
              "image": "assets/images/kingsaejong/sejong_character.png",
              "voiceSettings": {"pitch": 0.8, "rate": 0.4}
            }
            // 이순신 장군은 여기서 삭제됨! (AI 소환으로 만남)
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

  // ... build 함수 및 UI 코드는 기존과 동일 ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, iconTheme: IconThemeData(color: Colors.black)),
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
                    _buildInput(Icons.email_outlined, "이메일 (로그인 ID)", _emailController),
                    const SizedBox(height: 12),
                    _buildInput(Icons.badge_outlined, "이름", _nameController),
                    const SizedBox(height: 12),
                    _buildInput(Icons.lock_outline, "비밀번호", _passwordController, isPw: true),
                    const SizedBox(height: 12),
                    _buildInput(Icons.lock_outline, "비밀번호 확인", _passwordConfirmController, isPw: true),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF333330),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("계정 생성하기", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('이미 계정이 있으신가요? 로그인', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, TextEditingController ctrl, {bool isPw = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPw,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
      style: const TextStyle(color: Colors.black87),
      cursorColor: Colors.blueAccent,
    );
  }
}