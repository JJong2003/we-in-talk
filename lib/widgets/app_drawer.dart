// app_drawer.dart
import 'package:flutter/material.dart';
import '../screens/saejong_chat_screen.dart';
// lib/widgets/app_drawer.dart

// 1. ⭐️ (필수) StatefulWidget
class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // 2. ⭐️ 대화 목록 '상태' 관리
  final List<Map<String, dynamic>> _chatList = [
    {'title': '세종대왕과 대화', 'isEditing': false},
    {'title': '이순신과 대화', 'isEditing': false},
    {'title': '장영실과 대화', 'isEditing': false},
    {'title': '문익점과 대화', 'isEditing': false},
    {'title': '유관순과 대화', 'isEditing': false},
    {'title': '안중근과 대화', 'isEditing': false},
    {'title': '방정환과 대화', 'isEditing': false},
  ];

  // 3. ⭐️ 편집용 컨트롤러와 포커스 노드
  late TextEditingController _editingController;
  late FocusNode _editingFocusNode;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _editingFocusNode = FocusNode();

    // 4. ⭐️ 포커스 해제 시 저장 리스너
    _editingFocusNode.addListener(() {
      if (!_editingFocusNode.hasFocus) {
        final editingIndex = _chatList.indexWhere((item) => item['isEditing']);
        if (editingIndex != -1 && mounted) {
          setState(() {
            _saveChatTitle(editingIndex);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    _editingFocusNode.dispose();
    super.dispose();
  }

  // 5. ⭐️ (핵심) 새 대화 추가 및 Drawer 닫기
  void _addNewChat() {
    // 편집 중일 때는 새 대화 추가 방지
    if (_chatList.any((item) => item['isEditing'])) return;

    setState(() {
      // '새 채팅' 항목을 '일반 모드'로 맨 위에 추가
      _chatList.insert(0, {
        'title': '새 채팅', // 기본 제목
        'isEditing': false,
      });
    });

    // 항목 추가 후, 'HomeScreen'으로 돌아가기 (Drawer 닫기)
    // Navigator.pop(context);
  }

  // 6. ⭐️ (수정/삭제 기능) 편집 모드 시작
  void _startEditing(int index) {
    if (_chatList.any((item) => item['isEditing'])) return;

    setState(() {
      _chatList[index]['isEditing'] = true;
      _editingController.text = _chatList[index]['title'];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editingFocusNode.requestFocus();
    });
  }

  // 7. ⭐️ (수정/삭제 기능) 편집 저장
  void _saveChatTitle(int index) {
    String newTitle = _editingController.text.trim().isEmpty
        ? '새 채팅'
        : _editingController.text.trim();

    _chatList[index]['title'] = newTitle;
    _chatList[index]['isEditing'] = false;
    _editingFocusNode.unfocus();
  }

  // 8. ⭐️ (수정/삭제 기능) 항목 삭제
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text("'${_chatList[index]['title']}' 대화를 정말 삭제하시겠습니까?"),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _chatList.removeAt(index); // 리스트에서 제거
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            // (고정) 헤더 (Container 사용 버전 - 동일)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: statusBarHeight + 16.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                '이전 대화 목록',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // (고정) 새 대화 버튼
            ListTile(
              leading:
              const Icon(Icons.add_circle_outline, color: Colors.black87),
              title: const Text(
                '새 대화 시작하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _addNewChat, // 👈 _addNewChat 함수 연결
            ),

            // 구분선
            const Divider(height: 1, thickness: 1),

            // (스크롤) 나머지 대화 목록
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  final chat = _chatList[index];

                  // 9. ⭐️ 'isEditing'에 따라 분기
                  if (chat['isEditing']) {
                    // --- 편집 중일 때 (TextField) ---
                    return Container(
                      color: Colors.blue.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ListTile(
                        title: TextField(
                          controller: _editingController,
                          focusNode: _editingFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '대화 제목 입력...',
                          ),
                          onSubmitted: (value) {
                            setState(() => _saveChatTitle(index));
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() => _saveChatTitle(index));
                          },
                        ),
                      ),
                    );
                  } else {
                    // --- 일반 상태일 때 (Text) ---
                    return ListTile(
                      title: Text(chat['title']),
                      // (보너스) 길게 눌러서 수정하기
                      onLongPress: () {
                        _startEditing(index);
                      },
                      onTap: () {
                        // (세종대왕만 이동하는 로직)
                        if (chat['title'] == '세종대왕과 대화') {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SaejongChatScreen(),
                            ),
                          );
                        } else {
                          // '새 채팅' 등 나머지는 그냥 닫기
                          Navigator.pop(context);
                        }
                      },
                      // 10. ⭐️ (수정/삭제 기능) 더보기(...) 버튼
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _startEditing(index);
                          } else if (value == 'delete') {
                            _deleteItem(index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('수정'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
/*
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
}*/