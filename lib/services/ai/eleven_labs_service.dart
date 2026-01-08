import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/safe_api_caller.dart';

/// Mocked ElevenLabs service for text-to-speech
/// Currently returns sample audio - can be implemented later if needed
class ElevenLabsService with SafeApiCaller {
  ElevenLabsService();

  Future<String> generateAudio(String script) async {
    // Mocked implementation - returns sample audio
    await Future.delayed(const Duration(seconds: 1));
    return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
  }
}

final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  return ElevenLabsService();
});
