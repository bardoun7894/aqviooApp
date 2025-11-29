import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/composite_ai_service.dart';
import '../../../../services/ai/kie_ai_service.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../domain/models/creation_config.dart';
import '../../domain/models/creation_item.dart';
import '../../data/repositories/creation_repository.dart';

enum CreationWizardStatus {
  idle,
  generatingScript,
  generatingAudio,
  generatingVideo,
  success,
  error,
}

class CreationState {
  final CreationWizardStatus status;
  final String? videoUrl;
  final String? errorMessage;
  final String? currentStepMessage;
  final int wizardStep; // 0 = Idea, 1 = Style, 2 = Review
  final CreationConfig config;
  final List<CreationItem> creations;
  final String?
      currentTaskId; // ID of the task currently being watched in the wizard

  CreationState({
    this.status = CreationWizardStatus.idle,
    this.videoUrl,
    this.errorMessage,
    this.currentStepMessage,
    this.wizardStep = 0,
    CreationConfig? config,
    this.creations = const [],
    this.currentTaskId,
  }) : config = config ?? CreationConfig.empty();

  CreationState copyWith({
    CreationWizardStatus? status,
    String? videoUrl,
    String? errorMessage,
    String? currentStepMessage,
    int? wizardStep,
    CreationConfig? config,
    List<CreationItem>? creations,
    String? currentTaskId,
  }) {
    return CreationState(
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStepMessage: currentStepMessage ?? this.currentStepMessage,
      wizardStep: wizardStep ?? this.wizardStep,
      config: config ?? this.config,
      creations: creations ?? this.creations,
      currentTaskId: currentTaskId ?? this.currentTaskId,
    );
  }
}

class CreationController extends Notifier<CreationState> {
  AIService get _aiService => ref.read(aiServiceProvider);
  KieAIService get _kieAI => ref.read(kieAIServiceProvider);
  final CreationRepository _repository = CreationRepository();
  final _uuid = const Uuid();

  @override
  CreationState build() {
    // Watch auth state to reload creations when user logs in/out
    ref.watch(authStateProvider);

    // Load saved creations
    // Use microtask to avoid updating state during build
    Future.microtask(() => _loadCreations());

    return CreationState();
  }

  Future<void> _loadCreations() async {
    final items = await _repository.getCreations();
    state = state.copyWith(creations: items);

    // Resume polling for any processing tasks
    for (final item in items) {
      if (item.status == CreationStatus.processing && item.taskId != null) {
        _pollTask(item);
      }
    }
  }

  // Wizard navigation methods
  void goToNextStep() {
    if (state.wizardStep < 2) {
      state = state.copyWith(wizardStep: state.wizardStep + 1);
    }
  }

  void goToPreviousStep() {
    if (state.wizardStep > 0) {
      state = state.copyWith(wizardStep: state.wizardStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(wizardStep: step);
    }
  }

  // Update configuration
  void updateConfig(CreationConfig newConfig) {
    state = state.copyWith(config: newConfig);
  }

  void updatePrompt(String prompt) {
    state = state.copyWith(
      config: state.config.copyWith(prompt: prompt),
    );
  }

  void updateImagePath(String? imagePath) {
    state = state.copyWith(
      config: state.config.copyWith(imagePath: imagePath),
    );
  }

  void updateOutputType(OutputType outputType) {
    state = state.copyWith(
      config: state.config.copyWith(outputType: outputType),
    );
  }

  void updateVideoStyle(VideoStyle style) {
    state = state.copyWith(
      config: state.config.copyWith(videoStyle: style),
    );
  }

  void updateVideoDuration(int seconds) {
    state = state.copyWith(
      config: state.config.copyWith(videoDurationSeconds: seconds),
    );
  }

  void updateVideoAspectRatio(String aspectRatio) {
    state = state.copyWith(
      config: state.config.copyWith(videoAspectRatio: aspectRatio),
    );
  }

  void updateVoiceSettings({VoiceGender? gender, String? dialect}) {
    state = state.copyWith(
      config: state.config.copyWith(
        voiceGender: gender ?? state.config.voiceGender,
        voiceDialect: dialect ?? state.config.voiceDialect,
      ),
    );
  }

  void updateImageStyle(ImageStyle style) {
    state = state.copyWith(
      config: state.config.copyWith(imageStyle: style),
    );
  }

  void updateImageSize(String size) {
    state = state.copyWith(
      config: state.config.copyWith(imageSize: size),
    );
  }

  // Main generation method using NEW Kie AI Service
  Future<void> generateVideo({
    String? prompt,
    String? imagePath,
  }) async {
    try {
      // Get config from state (use provided prompt or state config prompt)
      final config = state.config.copyWith(
        prompt: prompt ?? state.config.prompt,
        imagePath: imagePath ?? state.config.imagePath,
      );

      // Convert imagePath to File if exists
      File? imageFile;
      if (config.imagePath != null && config.imagePath!.isNotEmpty) {
        imageFile = File(config.imagePath!);
      }

      // Update state with config and status
      state = state.copyWith(
        config: config,
        status: CreationWizardStatus.generatingScript,
        currentStepMessage: config.outputType == OutputType.video
            ? "Enhancing your idea..."
            : "Preparing your prompt...",
        errorMessage: null,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // Update status: Generating content
      state = state.copyWith(
        status: CreationWizardStatus.generatingVideo,
        currentStepMessage: config.outputType == OutputType.video
            ? (imageFile != null
                ? "Bringing your image to life..."
                : "Creating your video...")
            : "Generating your image...",
      );

      // Call unified KieAI service
      final result = await _kieAI.generateContent(
        config: config,
        imageFile: imageFile,
      );

      // Create new item
      final newItem = CreationItem(
        id: _uuid.v4(),
        taskId: result['taskId'],
        prompt: config.prompt,
        type: config.outputType == OutputType.video
            ? CreationType.video
            : CreationType.image,
        status: result['status'] == 'processing'
            ? CreationStatus.processing
            : CreationStatus.success,
        url: result['url'],
        createdAt: DateTime.now(),
        duration: config.outputType == OutputType.video
            ? '${config.videoDurationSeconds}s'
            : config.imageSize,
      );

      // Save to repository
      await _repository.saveCreation(newItem);

      // Update local state list
      final currentList = List<CreationItem>.from(state.creations);
      currentList.insert(0, newItem);
      state = state.copyWith(creations: currentList);

      if (newItem.status == CreationStatus.processing) {
        // Start polling in background
        _pollTask(newItem);

        // Keep UI in generating state, but allow minimizing
        state = state.copyWith(
          status: CreationWizardStatus.generatingVideo,
          currentTaskId: newItem.id,
          currentStepMessage: "Creating your masterpiece...",
        );
      } else {
        // Immediate success (Image)
        state = state.copyWith(
          status: CreationWizardStatus.success,
          videoUrl: result['url'],
          currentStepMessage: "Magic Complete!",
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: CreationWizardStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _pollTask(CreationItem item) async {
    if (item.taskId == null) return;

    // Enable wake lock to keep polling alive even when screen is locked
    try {
      await WakelockPlus.enable();
    } catch (e) {
      print('Failed to enable wake lock: $e');
    }

    try {
      // Poll for 5 minutes max
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 5));

        try {
          final status = await _kieAI.checkTaskStatus(item.taskId!);

          if (status['state'] == 'success') {
            final updatedItem = item.copyWith(
              status: CreationStatus.success,
              url: status['videoUrl'],
            );
            await _updateItem(updatedItem);

            // If this is the currently watched task, update wizard status
            if (state.currentTaskId == item.id) {
              state = state.copyWith(
                status: CreationWizardStatus.success,
                videoUrl: status['videoUrl'],
                currentStepMessage: "Magic Complete!",
              );
            }
            return;
          } else if (status['state'] == 'fail') {
            final updatedItem = item.copyWith(
              status: CreationStatus.failed,
              errorMessage: status['error'],
            );
            await _updateItem(updatedItem);

            if (state.currentTaskId == item.id) {
              state = state.copyWith(
                status: CreationWizardStatus.error,
                errorMessage: status['error'],
              );
            }
            return;
          }
        } catch (e) {
          print('Polling error for ${item.id}: $e');
          // Continue polling on network error
        }
      }

      // Timeout
      final timeoutItem = item.copyWith(
        status: CreationStatus.failed,
        errorMessage: 'Generation timed out',
      );
      await _updateItem(timeoutItem);

      if (state.currentTaskId == item.id) {
        state = state.copyWith(
          status: CreationWizardStatus.error,
          errorMessage: 'Generation timed out',
        );
      }
    } finally {
      // Always disable wake lock when polling completes
      try {
        await WakelockPlus.disable();
      } catch (e) {
        print('Failed to disable wake lock: $e');
      }
    }
  }

  Future<void> _updateItem(CreationItem item) async {
    await _repository.saveCreation(item);

    final currentList = List<CreationItem>.from(state.creations);
    final index = currentList.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      currentList[index] = item;
      state = state.copyWith(creations: currentList);
    }
  }

  void minimizeTask() {
    state = state.copyWith(currentTaskId: null);
  }

  void reset() {
    state = CreationState(creations: state.creations); // Keep creations
  }
}

final creationControllerProvider =
    NotifierProvider<CreationController, CreationState>(CreationController.new);
