import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy KieService wrapper for backward compatibility
/// Use KieAIService directly for new features
class KieService {
  KieService();

  Future<String> generateVideo({
    required String script,
    required String audioUrl,
    String? imageUrl,
  }) async {
    // Legacy mock implementation
    await Future.delayed(const Duration(seconds: 3));
    return "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";
  }
}

final kieServiceProvider = Provider<KieService>((ref) {
  return KieService();
});
