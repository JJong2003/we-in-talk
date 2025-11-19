import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

class PersonaGeneratorService {
  // 질문을 받아 인물 데이터를 반환하는 함수
  Future<Map<String, String>?> generatePersonaFromQuestion(String question) async {
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
        model: 'gpt-4o-mini', // 혹은 gpt-3.5-turbo
        messages: [systemMessage, userMessage],
      );

      final content = response.choices.first.message.content?.first.text;
      if (content != null) {
        // JSON 파싱
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