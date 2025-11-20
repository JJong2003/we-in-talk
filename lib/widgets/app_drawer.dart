// lib/widgets/app_drawer.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../screens/saejong_chat_screen.dart';
import '../screens/universal_chat_screen.dart';
import '../services/persona_generator_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<Map<String, dynamic>> _chatList = [];
  StreamSubscription<DatabaseEvent>? _personaSubscription;
  late TextEditingController _editingController;
  late FocusNode _editingFocusNode;
  final PersonaGeneratorService _personaGenerator = PersonaGeneratorService();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _editingFocusNode = FocusNode();
    _loadPersonasFromDB();

    _editingFocusNode.addListener(() {
      if (!_editingFocusNode.hasFocus) {
        final editingIndex = _chatList.indexWhere((item) => item['isEditing'] == true);
        if (editingIndex != -1) {
          _saveChatTitle(editingIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _personaSubscription?.cancel();
    _editingController.dispose();
    _editingFocusNode.dispose();
    super.dispose();
  }

  void _loadPersonasFromDB() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("users/${user.uid}/personas");

    _personaSubscription = ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        setState(() => _chatList = []);
        return;
      }

      final Map<dynamic, dynamic> personasMap = data as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> loadedList = [];

      personasMap.forEach((key, value) {
        loadedList.add({
          "key": key,
          "title": value['name'] ?? '이름 없음',
          "desc": value['desc'] ?? '',
          "prompt": value['prompt'],
          "image": value['image'],
          "voiceSettings": value['voiceSettings'],
          "isEditing": false,
        });
      });

      if (mounted) {
        setState(() {
          _chatList = loadedList;
        });
      }
    });
  }

  // AI 소환 기능 (외부 연동 로직 유지)
  void _addNewChat() {
    final textController = TextEditingController();
    bool isGenerating = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // [디자인 수정] AlertDialog의 기본 스타일은 Theme을 따르지만, 텍스트 필드의 border를 Theme에 맞게 수정
            return AlertDialog(
              title: const Text("새로운 역사 친구 소환"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("궁금한 역사 사건이나 인물을 물어보세요.\nAI가 적절한 위인을 찾아줍니다!"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "예: 거북선은 누가 만들었어?",
                      // border: OutlineInputBorder(), <-- Theme에서 설정되므로 제거
                    ),
                  ),
                  if (isGenerating) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text("역사 기록을 찾는 중..."),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: isGenerating ? null : () async {
                    final question = textController.text.trim();
                    if (question.isEmpty) return;

                    setStateDialog(() => isGenerating = true);

                    // [외부 연동] PersonaGeneratorService 호출 (로직 유지)
                    final personaData = await _personaGenerator.generatePersonaFromQuestion(question);

                    if (personaData != null) {
                      String imagePath = "assets/images/general_male.png";
                      if (personaData['gender'] == 'female') {
                        imagePath = "assets/images/general_female.png";
                      }

                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final newRef = FirebaseDatabase.instance
                            .ref("users/${user.uid}/personas")
                            .push();

                        // [외부 연동] Firebase DB 저장 (로직 유지)
                        await newRef.set({
                          "name": personaData['name'],
                          "desc": personaData['desc'],
                          "prompt": personaData['prompt'],
                          "image": imagePath,
                          "createdAt": DateTime.now().toIso8601String(),
                          "voiceSettings": {"pitch": 1.0, "rate": 0.5}
                        });
                      }
                      Navigator.pop(ctx);
                    } else {
                      setStateDialog(() => isGenerating = false);
                    }
                  },
                  child: const Text("소환하기"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startEditing(int index) {
    setState(() {
      _chatList[index]['isEditing'] = true;
      _editingController.text = _chatList[index]['title'];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editingFocusNode.requestFocus();
    });
  }

  void _saveChatTitle(int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String newTitle = _editingController.text.trim();
    if (newTitle.isEmpty) newTitle = "이름 없음";

    final key = _chatList[index]['key'];

    // [외부 연동] Firebase DB 저장 (로직 유지)
    FirebaseDatabase.instance.ref("users/${user.uid}/personas/$key").update({
      "name": newTitle
    });

    setState(() {
      _chatList[index]['isEditing'] = false;
    });
    _editingFocusNode.unfocus();
  }

  void _deleteItem(int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final key = _chatList[index]['key'];
    final title = _chatList[index]['title'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text("'$title' 님과 작별하시겠습니까?"),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              // [외부 연동] Firebase DB 삭제 (로직 유지)
              FirebaseDatabase.instance.ref("users/${user.uid}/personas/$key").remove();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [디자인 상수] 네이비 색상 정의
    const Color primaryNavy = Color(0xFF1A237E);

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            // [디자인 변경] 1. 헤더 배경색 변경
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: statusBarHeight + 16.0, left: 16.0, right: 16.0, bottom: 16.0,
              ),
              decoration: const BoxDecoration(color: primaryNavy), // 네이비색 적용
              child: const Text(
                '나의 역사 튜터들',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.black87),
              title: const Text('새로운 위인 소환하기', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: _addNewChat,
            ),

            const Divider(height: 1, thickness: 1),

            Expanded(
              child: _chatList.isEmpty
                  ? const Center(child: Text("등록된 가상인물이 없습니다."))
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  final chat = _chatList[index];

                  // (A) 편집 모드
                  if (chat['isEditing'] == true) {
                    // 편집 모드의 입력창은 Theme의 InputDecorationTheme를 따름
                    return ListTile(
                      title: TextField(
                        controller: _editingController,
                        focusNode: _editingFocusNode,
                        onSubmitted: (_) => _saveChatTitle(index),
                      ),
                      // [디자인 변경] 체크 아이콘 색상을 네이비로
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: primaryNavy),
                        onPressed: () => _saveChatTitle(index),
                      ),
                    );
                  }
                  // (B) 일반 모드
                  else {
                    return ListTile(
                      title: Text(chat['title'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(chat['desc'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),

                      onTap: () {
                        if (chat['title'].toString().contains('세종')) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SaejongChatScreen()),
                          );
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UniversalChatScreen(
                                personaKey: chat['key'],
                                personaData: Map<String, dynamic>.from(chat),
                              ),
                            ),
                          );
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                            onPressed: () => _startEditing(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                            onPressed: () => _deleteItem(index),
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