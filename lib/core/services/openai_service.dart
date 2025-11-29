import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> enhancePrompt(String userPrompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in environment variables');
    }

    final systemPrompt = '''You are a professional video prompt engineer for an AI video generation app called Aqvioo.
Your task is to enhance user prompts to create better, more detailed prompts for AI video generation.

Guidelines:
- Keep the core idea of the user's prompt
- Add cinematic details (camera angles, lighting, mood)
- Include visual style descriptions (realistic, animated, artistic style)
- Specify movement and action details
- Add atmospheric elements (time of day, weather, environment)
- Keep it concise but vivid (2-3 sentences max)
- Make it professional and production-ready
- Focus on visual elements that work well in video

Example:
User: "A cat playing with a ball"
Enhanced: "A fluffy orange tabby cat playfully batting a red yarn ball across a sunlit hardwood floor, shot with a dynamic low-angle camera that follows the ball's movement. Warm afternoon light streams through nearby windows, creating soft shadows and highlighting the cat's whiskers in slow motion."

Now enhance this prompt:''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',  // Using GPT-4 Optimized (latest and best)
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.8,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final enhancedPrompt = data['choices'][0]['message']['content'] as String;
        return enhancedPrompt.trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to enhance prompt: $e');
    }
  }
}
