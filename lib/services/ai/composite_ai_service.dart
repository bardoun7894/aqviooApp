import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import 'openai_service.dart';
import 'eleven_labs_service.dart';
import 'kie_service.dart';

class CompositeAIService implements AIService {
  final OpenAIService _openAI;
  final ElevenLabsService _elevenLabs;
  final KieService _kie;

  CompositeAIService(this._openAI, this._elevenLabs, this._kie);

  @override
  Future<String> generateScript(String prompt) {
    return _openAI.generateScript(prompt);
  }

  @override
  Future<String> generateAudio(String script) {
    return _elevenLabs.generateAudio(script);
  }

  @override
  Future<String> generateVideo({required String script, required String audioUrl, String? imageUrl}) {
    return _kie.generateVideo(script: script, audioUrl: audioUrl, imageUrl: imageUrl);
  }
}

final aiServiceProvider = Provider<AIService>((ref) {
  final openAI = ref.watch(openAIServiceProvider);
  final elevenLabs = ref.watch(elevenLabsServiceProvider);
  final kie = ref.watch(kieServiceProvider);
  
  return CompositeAIService(openAI, elevenLabs, kie);
});
