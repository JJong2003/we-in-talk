// app_drawer.dart
import 'package:flutter/material.dart';
import '../screens/saejong_chat_screen.dart';

class AppDrawer extends StatelessWidget { // (클래스 이름은 MyDrawer -> AppDrawer로 가정)
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
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
        ],
      ),
    );
  }
}