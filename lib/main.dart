// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // 기존 import

// 1. Firebase Core와 Options import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI가 생성한 파일
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 2. main 함수를 'async' 비동기 함수로 변경
Future<void> main() async {
  // 3. Flutter 엔진이 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env 파일 로드 성공");
  } catch (e) {
    print("❌ .env 파일 로드 실패: $e");
  }

  // 4. Firebase 앱 초기화 (가장 중요)
  // DefaultFirebaseOptions.currentPlatform을 사용하여 플랫폼에 맞는 설정 로드
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. Firebase 초기화가 완료된 후 앱 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A237E); // 쪽빛
    const Color backgroundCream = Color(0xFFFDFBF7); // 한지색
    const Color textDark = Color(0xFF333333); // 먹색
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-in Talk', // 기존 title
      theme: ThemeData(
        primaryColor: primaryNavy,
        scaffoldBackgroundColor: backgroundCream, // 전체 배경 크림색

        // 앱바 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textDark),
          titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // 버튼 테마 (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // ColorScheme 설정
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryNavy,
          secondary: Colors.orange,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(), // 로그인 화면으로 시작
    );
  }
}