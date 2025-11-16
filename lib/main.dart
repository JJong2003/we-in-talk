// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // 기존 import

// 1. Firebase Core와 Options import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI가 생성한 파일

// 2. main 함수를 'async' 비동기 함수로 변경
Future<void> main() async {
  // 3. Flutter 엔진이 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-in Talk', // 기존 title
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(), // 로그인 화면으로 시작
    );
  }
}