import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElevenLabsService {
  ElevenLabsService({required String apiKey});

  Future<String> generateAudio(String script) async {
    // TODO: Implement ElevenLabs API call using _apiKey
    await Future.delayed(const Duration(seconds: 2));
    return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; // Mock Audio URL
  }
}

final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  final apiKey = dotenv.env['ELEVEN_LABS_API_KEY'] ?? '';
  return ElevenLabsService(apiKey: apiKey);
});
