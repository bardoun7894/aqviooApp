import 'package:flutter_riverpod/flutter_riverpod.dart';

class KieService {
  Future<String> generateVideo({required String script, required String audioUrl, String? imageUrl}) async {
    // TODO: Implement Kie.ai / Nano Banana API call
    await Future.delayed(const Duration(seconds: 3));
    return "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"; // Mock Video URL
  }
}

final kieServiceProvider = Provider<KieService>((ref) {
  return KieService();
});
