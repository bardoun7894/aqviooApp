import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenAIService {
  Future<String> generateScript(String prompt) async {
    // TODO: Implement OpenAI API call
    await Future.delayed(const Duration(seconds: 2));
    return "This is a generated script based on: $prompt. It is a placeholder for the actual OpenAI response.";
  }
}

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});
