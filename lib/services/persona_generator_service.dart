// lib/services/persona_generator_service.dart

import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PersonaGeneratorService {
  Future<Map<String, String>?> generatePersonaFromQuestion(String question) async {

    // 1. .env에서 키를 가져와서 '변수'에 담습니다.
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";

    // 2. 변수 자체가 비어있는지 확인합니다. (OpenAI.apiKey를 직접 확인하지 않음)
    if (apiKey.isEmpty) {
      print("❌ 오류: .env 파일에 OPENAI_API_KEY가 없거나 비어있습니다.");
      return null;
    }

    // 3. 키가 정상이면 패키지에 설정합니다.
    OpenAI.apiKey = apiKey;

    // --- 이하 로직 동일 ---
    const systemPrompt = """
    사용자의 역사 질문을 분석하여, 그 질문에 답해줄 가장 적절한 역사적 인물 1명을 선정해라.
    반드시 아래 JSON 포맷으로만 응답해라. (다른 말 금지)
    
    {
      "name": "인물 이름 (예: 장영실)",
      "desc": "인물에 대한 짧은 설명 (예: 조선 최고의 과학자)",
      "prompt": "이 인물이 되어 대화하기 위한 지시문 (말투, 성격, 배경 등 상세히)",
      "gender": "male 또는 female"
    }
    """;

    try {
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text("질문: $question")
        ],
      );

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)
        ],
      );

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [systemMessage, userMessage],
      );

      final content = response.choices.first.message.content?.first.text;
      if (content != null) {
        final Map<String, dynamic> data = jsonDecode(content);
        return {
          "name": data['name'],
          "desc": data['desc'],
          "prompt": data['prompt'],
          "gender": data['gender'],
        };
      }
    } catch (e) {
      print("인물 생성 실패: $e");
    }
    return null;
  }
}