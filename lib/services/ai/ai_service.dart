
abstract class AIService {
  /// Generates a video script based on the user's prompt.
  Future<String> generateScript(String prompt);

  /// Generates audio from the provided script.
  /// Returns the URL or local path to the audio file.
  Future<String> generateAudio(String script);

  /// Generates a video based on the script and audio.
  /// Returns the URL or local path to the video file.
  Future<String> generateVideo({required String script, required String audioUrl, String? imageUrl});
}
