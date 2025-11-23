import 'package:flutter_riverpod/flutter_riverpod.dart';

class ElevenLabsService {
  Future<String> generateAudio(String script) async {
    // TODO: Implement ElevenLabs API call
    await Future.delayed(const Duration(seconds: 2));
    return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; // Mock Audio URL
  }
}

final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  return ElevenLabsService();
});
