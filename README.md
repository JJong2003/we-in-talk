# 2025 2학기 기초프로젝트랩 - we in talk : 역사 인물 대화 앱

Flutter를 이용한 역사 인물 AI 대화 및 퀴즈 앱 개발 프로젝트입니다.

## 🚀 프로젝트 개요

본 프로젝트는 사용자가 역사 인물(세종대왕, 이순신 등)을 선택하여 가상의 대화를 나누고, 대화 도중 관련 역사 퀴즈를 풀며 학습하는 에듀테인먼트 앱입니다.

## 📁 디렉토리 구조

프로젝트의 주요 디렉토리 구조와 용도는 다음과 같습니다.
```
basicproj/ 
    ├── android/ # Android 네이티브 코드 
    ├── ios/ # iOS 네이티브 코드
    ├── lib/ # (중요) 모든 Dart 코드가 위치하는 메인 폴더
    │   ├── screens/ # 각 화면(페이지)을 구성하는 파일 
    │   ├── widgets/ # 여러 화면에서 공통으로 사용되는 위젯 
    │   └── main.dart # (중요) 앱의 시작점 
    ├── assets/ # (중요) 모든 정적 리소스(이미지, 오디오 등) 
    │   ├── gifImages/ 
    │   ├── images/ 
    │   ├── logo/ 
    │   └── mp3/ 
    ├── test/ # Dart 테스트 코드 
    └── pubspec.yaml # (매우 중요) 프로젝트 의존성 및 assets 경로 관리
```


### 1. `lib/` (Dart 코드)

모든 Flutter 앱 로직은 `lib` 폴더 내에 작성합니다. 협업을 위해 기능별로 폴더를 분리합니다.

* `lib/screens/`: 앱의 각 '페이지' 또는 '전체 화면'에 해당하는 Dart 파일이 위치합니다. (예: 로그인 화면, 홈 화면)
* `lib/widgets/`: 여러 화면에서 재사용되는 '공통 부품' 위젯이 위치합니다. (예: 커스텀 버튼, 채팅 말풍선)

### 2. `assets/` (리소스 관리)

모든 정적 리소스(이미지, 폰트, 오디오)는 `assets` 폴더 내에 관리합니다.

* `assets/logo/`: 앱 로고, 스플래시 이미지 등
* `assets/images/`: 캐릭터 이미지, 배경 이미지 등 정적 PNG/JPG
* `assets/gifImages/`: 캐릭터의 움직임 등 GIF 파일
* `assets/mp3/`: 효과음, 배경음악 등 오디오 파일

**⚠️ 중요:** `assets` 폴더에 새 파일을 추가한 후에는 **반드시 `pubspec.yaml` 파일을 열어** 해당 파일을 `flutter:` 섹션의 `assets:` 목록에 추가해야 합니다.

```yaml
flutter:
  assets:
    - assets/logo/
    - assets/images/
    - assets/gifImages/
    - assets/mp3/
```

## 💻 `lib` 폴더 파일 설계 및 설명
팀원 간의 원활한 분업을 위해 `lib` 폴더 내 파일을 다음과 같이 설계합니다.

`main.dart`
* **담당**: 공통 (또는 리더)
* **설명**:
  - 앱의 진입점(`main` 함수)입니다.
  - `MaterialApp` 위젯을 정의하고, 앱의 전체 테마(글꼴, 색상)를 설정합니다.
  - 앱의 초기 라우팅(Routing)을 관리합니다. (예: 사용자가 로그인 상태인지 확인하여 `LoginScreen` 또는 `HomeScreen`으로 보냄)

`screens/login_screen.dart`
* **담당**: (팀원 A)
* **설명**:
  - 사용자가 보게 될 첫 로그인 화면 UI를 구현합니다.
  - ID/PW `TextField`, '로그인' 버튼, '계정 생성하기', '회원가입' 버튼을 포함합니다.
  - '로그인' 버튼 클릭 시 `HomeScreen`으로 이동하는 로직을 작성합니다.
  - '회원가입' 버튼 클릭 시 `SignupScreen`으로 이동하는 로직을 작성합니다.

`screens/signup_screen.dart`
* **담당**: (팀원 A 또는 B)
* **설명**:
  - '계정 생성하기' 또는 '회원가입' 버튼을 눌렀을 때 보이는 화면입니다.
  - 이메일, 비밀번호, 닉네임 등을 입력받는 `TextField`와 '가입 완료' 버튼을 구현합니다.

`screens/home_screen.dart`
* **담당**: (팀원 B)
* **설명**:
  - **(핵심)** 로그인 후 보게 될 메인 허브 화면입니다.
  - `Scaffold` 위젯을 사용하여 앱의 기본 구조(AppBar, Drawer, Body)를 잡습니다.
  - `AppBar` (상단 바)와 `Drawer` (사이드 메뉴)를 이곳에서 관리합니다.
  - `Drawer`에는 `widgets/app_drawer.dart`를 불러와 연결합니다.
  - **중요:** '현재 선택된 대화 상대'(`selectedCharacter`) 상태를 관리합니다.
  - `body` 영역은 `selectedCharacter` 상태에 따라 `widgets/initial_view.dart` (초기 화면) 또는 `widgets/chat_view.dart` (대화 화면)를 조건부로 보여줍니다.

`widgets/app_drawer.dart`
* **담당**: (팀원 B 또는 C)
* **설명**:
  - `HomeScreen의` `Scaffold에` 들어갈 사이드 메뉴(`Drawer`) 위젯입니다.
  - '이전 대화 목록' (세종대왕과 대화, 이순신과 대화...)을 ListView와 ListTile로 구현합니다.
  - `ListTile`을 클릭하면, `HomeScreen`의 `selectedCharacter` 상태를 업데이트하도록 콜백 함수를 실행합니다. (이 위젯이 직접 화면을 바꾸는 것이 아님)

`widgets/initial_view.dart`
* **담당**: (팀원 C)
* **설명**:
  - `HomeScreen의` `body에` 표시될 '초기 인물 선택' 화면입니다. (아직 아무도 선택하지 않은 상태)
  - 중앙에 마이크 아이콘(Offline/Recording)을 표시합니다.
  - 마이크 아이콘을 탭하면 상태(이미지)가 변경되는 로직을 `StatefulWidget`으로 구현합니다.

`widgets/chat_view.dart`
* **담당**: (팀원 D - 핵심 기능)
* **설명**:
  - `HomeScreen의` `body에` 표시될 '대화 화면' UI입니다.
  - `HomeScreen`으로부터 '누구와 대화할지' (`selectedCharacter`) 정보를 받아옵니다.
  - 화면을 2분할(`Row` 또는 `Expanded`)하여 왼쪽에는 캐릭터 이미지/GIF를, 오른쪽에는 채팅 UI를 배치합니다.
  - 채팅 UI는 `ListView`.builder를 사용하여 스크롤 가능한 대화 목록을 만듭니다.
  - **중요:** `ListView.builder` 내에서 메시지 타입(일반 대화, 퀴즈, 퀴즈 결과)에 따라 각기 다른 위젯 (`ChatBubble`, `QuizBubble` 등)을 반환해야 합니다.
  - 하단에 텍스트 입력창(`TextField`)과 마이크 버튼(`IconButton`)을 구현합니다.

`widgets/chat_bubble.dart`
* **담당**: (팀원 D)
* **설명**:
  - `chat_view.dart`에서 사용될 일반 텍스트 말풍선 위젯입니다.
  - 보내는 사람(나/상대방)에 따라 배경색과 정렬(왼쪽/오른쪽)이 달라지는 로직을 포함합니다.

`widgets/quiz_bubble.dart`
* **담당**: (팀원 D)
* **설명**:
  - `chat_view.dart`에서 사용될 '퀴즈(O/X)' 전용 말풍선 위젯입니다.
  - 질문 텍스트와 O/X 버튼을 포함합니다.
  - O 또는 X 버튼을 눌렀을 때의 로직(예: 정답/오답 표시)을 처리합니다.
  - '정답입니다!', '오답입니다!' UI도 이 위젯에서 함께 관리하거나 별도 위젯(`quiz_result_bubble.dart`)으로 분리할 수 있습니다.