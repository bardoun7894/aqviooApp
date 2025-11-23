import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/composite_ai_service.dart';

enum CreationStatus {
  idle,
  generatingScript,
  generatingAudio,
  generatingVideo,
  success,
  error,
}

class CreationState {
  final CreationStatus status;
  final String? videoUrl;
  final String? errorMessage;
  final String? currentStepMessage;

  CreationState({
    this.status = CreationStatus.idle,
    this.videoUrl,
    this.errorMessage,
    this.currentStepMessage,
  });

  CreationState copyWith({
    CreationStatus? status,
    String? videoUrl,
    String? errorMessage,
    String? currentStepMessage,
  }) {
    return CreationState(
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStepMessage: currentStepMessage ?? this.currentStepMessage,
    );
  }
}

class CreationController extends Notifier<CreationState> {
  late final AIService _aiService;

  @override
  CreationState build() {
    _aiService = ref.watch(aiServiceProvider);
    return CreationState();
  }

  Future<void> generateVideo({
    required String prompt,
    String? imagePath,
  }) async {
    try {
      state = state.copyWith(
        status: CreationStatus.generatingScript,
        currentStepMessage: "Dreaming up a story...",
        errorMessage: null,
      );

      final script = await _aiService.generateScript(prompt);

      state = state.copyWith(
        status: CreationStatus.generatingAudio,
        currentStepMessage: "Finding the right voice...",
      );

      final audioUrl = await _aiService.generateAudio(script);

      state = state.copyWith(
        status: CreationStatus.generatingVideo,
        currentStepMessage: "Painting the pixels...",
      );

      final videoUrl = await _aiService.generateVideo(
        script: script,
        audioUrl: audioUrl,
        imageUrl: imagePath,
      );

      state = state.copyWith(
        status: CreationStatus.success,
        videoUrl: videoUrl,
        currentStepMessage: "Magic Complete!",
      );
    } catch (e) {
      state = state.copyWith(
        status: CreationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = CreationState();
  }
}

final creationControllerProvider =
    NotifierProvider<CreationController, CreationState>(CreationController.new);
