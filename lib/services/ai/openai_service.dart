import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String _apiKey;

  OpenAIService({required String apiKey}) : _apiKey = apiKey;

  Future<String> generateScript(String prompt) async {
    // TODO: Implement OpenAI API call using _apiKey
    await Future.delayed(const Duration(seconds: 2));
    return "This is a generated script based on: $prompt. It is a placeholder for the actual OpenAI response.";
  }
}

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  return OpenAIService(apiKey: apiKey);
});
