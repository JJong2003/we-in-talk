// app_drawer.dart
import 'package:flutter/material.dart';
import '../screens/saejong_chat_screen.dart';

class AppDrawer extends StatelessWidget { // (클래스 이름은 MyDrawer -> AppDrawer로 가정)
  const AppDrawer({Key? key}) : super(key: key);

  // 스크롤 기능 추가
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Drawer(
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
        child: Column(
          // Column으로 레이아웃을 분리
          children: [
            // 1. (고정) 헤더
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: statusBarHeight + 16.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '이전 대화 목록',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 2. (고정) 새 대화 버튼
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.black87),
              title: const Text(
                '새 대화 시작하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // TODO: 새 대화 시작 로직 구현 (예: 채팅방 초기화)
                Navigator.pop(context); // Drawer 닫기
              },
            ),

            // 구분선
            const Divider(height: 1, thickness: 1),

            Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // 2. "세종대왕과 대화" ListTile 수정
                    ListTile(
                      title: const Text('세종대왕과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        // 3. Drawer를 닫고
                        Navigator.pop(context);
                        // 4. SejongChatScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SaejongChatScreen(),
                          ),
                        );
                      },
                    ),
                    // --- 나머지 ListTile들 ---
                    ListTile(
                      title: const Text('이순신과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context); // 일단 Drawer만 닫기
                      },
                    ),
                    ListTile(
                      title: const Text('장영실과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('문익점과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('유관순과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('안중근과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('방정환과 대화'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    // 리스트 추가 부분
                  ],
                )
            )
          ],
        ),)
    );
  }
}