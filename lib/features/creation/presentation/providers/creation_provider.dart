import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/composite_ai_service.dart';
import '../../../../services/ai/kie_ai_service.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../core/services/notification_service.dart';
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
  final String?
      hiddenContext; // Hidden context added by quick suggestions - not shown to user

  CreationState({
    this.status = CreationWizardStatus.idle,
    this.videoUrl,
    this.errorMessage,
    this.currentStepMessage,
    this.wizardStep = 0,
    CreationConfig? config,
    this.creations = const [],
    this.currentTaskId,
    this.hiddenContext,
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
    String? hiddenContext,
    bool clearHiddenContext = false,
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
      hiddenContext:
          clearHiddenContext ? null : (hiddenContext ?? this.hiddenContext),
    );
  }
}

class CreationController extends Notifier<CreationState> {
  // ignore: unused_element
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

  // Hidden context management for quick suggestions
  void setHiddenContext(String context) {
    state = state.copyWith(hiddenContext: context);
  }

  void clearHiddenContext() {
    state = state.copyWith(clearHiddenContext: true);
  }

  /// Set style-enhanced prompt based on user's prompt language
  /// This should be called before generateVideo() with the localized style prompt
  void setStyleEnhancement(String stylePrompt) {
    if (stylePrompt.isNotEmpty) {
      // Combine with any existing hidden context
      final existingContext = state.hiddenContext ?? '';
      final newContext = existingContext.isEmpty
          ? stylePrompt
          : '$existingContext, $stylePrompt';
      state = state.copyWith(hiddenContext: newContext);
    }
  }

  // Track if generation is in progress to prevent duplicates
  bool _isGenerating = false;

  // Main generation method using NEW Kie AI Service
  Future<void> generateVideo({
    String? prompt,
    String? imagePath,
  }) async {
    // SAFEGUARD 1: Prevent duplicate generation if already in progress
    if (_isGenerating) {
      debugPrint(
          '⚠️ Generation already in progress, ignoring duplicate request');
      return;
    }

    // SAFEGUARD 2: Check if already in generating state
    if (state.status == CreationWizardStatus.generatingScript ||
        state.status == CreationWizardStatus.generatingAudio ||
        state.status == CreationWizardStatus.generatingVideo) {
      debugPrint('⚠️ Already generating, ignoring duplicate request');
      return;
    }

    _isGenerating = true;

    try {
      // Store the ORIGINAL user prompt (before enhancement)
      final originalPrompt = prompt ?? state.config.prompt;

      // Combine user prompt with hidden context if exists
      String finalPrompt = originalPrompt;
      if (state.hiddenContext != null && state.hiddenContext!.isNotEmpty) {
        // Add hidden context to enhance the prompt
        finalPrompt = '${state.hiddenContext}\n\n$finalPrompt';
      }

      // Get config from state (use combined prompt for generation)
      final config = state.config.copyWith(
        prompt: finalPrompt,
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
            ? "enhancingIdea"
            : "preparingPrompt",
        errorMessage: null,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // Update status: Generating content
      state = state.copyWith(
        status: CreationWizardStatus.generatingVideo,
        currentStepMessage: config.outputType == OutputType.video
            ? (imageFile != null ? "bringingImageToLife" : "creatingVideo")
            : "generatingImage",
      );

      // Call unified KieAI service
      final result = await _kieAI.generateContent(
        config: config,
        imageFile: imageFile,
      );

      // Create new item - SAVE ORIGINAL PROMPT, not enhanced
      final newItem = CreationItem(
        id: _uuid.v4(),
        taskId: result['taskId'],
        prompt: originalPrompt, // Save original user prompt for Remix feature
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
        // Additional fields for admin dashboard
        style: config.outputType == OutputType.video
            ? config.videoStyle?.name ?? 'default'
            : config.imageStyle?.name ?? 'default',
        aspectRatio: config.outputType == OutputType.video
            ? config.videoAspectRatio
            : config.imageSize,
        outputType: config.outputType == OutputType.video ? 'video' : 'image',
        generationModel:
            result['usedModel'], // Store the model used (e.g. sora2, kling)
      );

      // Check if fallback occurred and notify/update UI context
      // Logic: If we expected Sora2 (default) but got something else
      if (config.outputType == OutputType.video &&
          result['usedModel'] != null &&
          result['usedModel'] != 'sora-2-text-to-video') {
        final fallbackModel = result['usedModel'];
        debugPrint('ℹ️ UI Notice: Using fallback model $fallbackModel');

        // Add a subtle notice to the hidden context or update step message
        // Updating step message is more visible
        state = state.copyWith(
          currentStepMessage:
              "fallbackNotice_$fallbackModel", // Can be handled by localization or UI logic
        );
      }

      // Save to repository
      await _repository.saveCreation(newItem);

      // Update local state list
      final currentList = List<CreationItem>.from(state.creations);
      currentList.insert(0, newItem);
      state = state.copyWith(creations: currentList);

      if (newItem.status == CreationStatus.processing) {
        // Clear hidden context since it's been used
        state = state.copyWith(clearHiddenContext: true);

        // Start polling in background
        _pollTask(newItem);

        // Keep UI in generating state, but allow minimizing
        state = state.copyWith(
          status: CreationWizardStatus.generatingVideo,
          currentTaskId: newItem.id,
          currentStepMessage: "creatingMasterpiece",
        );
      } else {
        // Clear hidden context since it's been used
        state = state.copyWith(clearHiddenContext: true);

        // Immediate success (Image)
        state = state.copyWith(
          status: CreationWizardStatus.success,
          videoUrl: result['url'],
          currentStepMessage: "magicComplete",
        );
      }
    } catch (e) {
      debugPrint('❌ Generation error: $e');
      state = state.copyWith(
        status: CreationWizardStatus.error,
        errorMessage: _friendlyErrorMessage(e),
      );
    } finally {
      // Always reset the generating flag
      _isGenerating = false;
    }
  }

  void retryGeneration() {
    // Reset status to idle so generateVideo doesn't block it
    state =
        state.copyWith(status: CreationWizardStatus.idle, errorMessage: null);
    // Retry with existing config
    generateVideo();
  }

  String _friendlyErrorMessage(Object error) {
    final e = error.toString();
    if (e.contains('SocketException') || e.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network.';
    }
    if (e.contains('TimeoutException')) {
      return 'The connection timed out. Please try again.';
    }
    if (e.contains('insufficient_quota')) {
      return 'You have run out of credits. Please upgrade your plan.';
    }
    if (e.contains('KieAIException')) {
      // Extract message from KieAIException string if possible, or just return it
      // Assuming clean string is better
      return e
          .replaceFirst('Exception: ', '')
          .replaceFirst('KieAIException: ', '');
    }
    return 'Something went wrong. Please try again.\n($e)';
  }

  Future<void> _pollTask(CreationItem item) async {
    if (item.taskId == null) return;

    final notificationService = NotificationService();
    final isVideo = item.type == CreationType.video;
    int consecutiveNetworkErrors = 0;
    const maxConsecutiveNetworkErrors =
        10; // Increased tolerance for background mode
    int consecutiveTimeouts = 0;
    const maxConsecutiveTimeouts = 3; // Track timeouts separately

    // Enable wake lock to keep polling alive even when screen is locked
    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('Failed to enable wake lock: $e');
    }

    try {
      // Poll for 10 minutes max (120 iterations * 5 seconds = 10 minutes)
      // Video generation can take 3-5 minutes
      for (int i = 0; i < 120; i++) {
        await Future.delayed(const Duration(seconds: 5));

        try {
          final status = await _kieAI.checkTaskStatus(item.taskId!);

          // Reset error counters on successful response
          if (status['isNetworkError'] != true) {
            consecutiveNetworkErrors = 0;
            consecutiveTimeouts = 0;
          }

          if (status['state'] == 'success') {
            final url = status['videoUrl'] ?? status['imageUrl'];
            final updatedItem = item.copyWith(
              status: CreationStatus.success,
              url: url,
            );
            await _updateItem(updatedItem);

            // Show notification if app is in background (uses localized strings automatically)
            try {
              if (isVideo) {
                await notificationService.showVideoCompleteNotification(
                  payload: item.id,
                );
              } else {
                await notificationService.showImageCompleteNotification(
                  payload: item.id,
                );
              }
            } catch (notifError) {
              debugPrint('Failed to show notification: $notifError');
            }

            // If this is the currently watched task, update wizard status
            if (state.currentTaskId == item.id) {
              state = state.copyWith(
                status: CreationWizardStatus.success,
                videoUrl: url,
                currentStepMessage: "magicComplete",
              );
            }
            return;
          } else if (status['state'] == 'fail') {
            final errorMessage = status['error'] ?? 'Generation failed';
            final updatedItem = item.copyWith(
              status: CreationStatus.failed,
              errorMessage: errorMessage,
            );
            await _updateItem(updatedItem);

            // Show error notification (uses localized strings automatically)
            try {
              await notificationService.showErrorNotification(
                body: errorMessage,
                payload: item.id,
              );
            } catch (notifError) {
              debugPrint('Failed to show error notification: $notifError');
            }

            if (state.currentTaskId == item.id) {
              state = state.copyWith(
                status: CreationWizardStatus.error,
                errorMessage: errorMessage,
              );
            }
            return;
          } else if (status['isNetworkError'] == true) {
            consecutiveNetworkErrors++;
            debugPrint(
                'Network error $consecutiveNetworkErrors/$maxConsecutiveNetworkErrors');

            // If too many consecutive network errors, fail gracefully
            if (consecutiveNetworkErrors >= maxConsecutiveNetworkErrors) {
              final updatedItem = item.copyWith(
                status: CreationStatus.failed,
                errorMessage:
                    'Network connection lost. Your content may still be generating - check My Creations later.',
              );
              await _updateItem(updatedItem);

              if (state.currentTaskId == item.id) {
                state = state.copyWith(
                  status: CreationWizardStatus.error,
                  errorMessage:
                      'Network connection lost. Check My Creations later.',
                );
              }
              return;
            }
          }
          // Continue polling for 'waiting' state
        } on TimeoutException catch (e) {
          // Handle timeout specifically - common when app is backgrounded
          consecutiveTimeouts++;
          debugPrint(
              'Polling timeout ${consecutiveTimeouts}/$maxConsecutiveTimeouts for ${item.id}: $e');

          if (consecutiveTimeouts >= maxConsecutiveTimeouts) {
            // After multiple timeouts, wait longer before next attempt
            debugPrint(
                'Multiple timeouts detected, waiting 30 seconds before retry...');
            await Future.delayed(const Duration(seconds: 30));
            consecutiveTimeouts = 0; // Reset and try again
          }
          // Continue polling - don't count as network error
        } catch (e) {
          debugPrint('Polling error for ${item.id}: $e');

          // Check if it's a timeout-related error message
          if (e.toString().contains('TimeoutException') ||
              e.toString().contains('timeout')) {
            consecutiveTimeouts++;
            if (consecutiveTimeouts >= maxConsecutiveTimeouts) {
              debugPrint(
                  'Multiple timeouts detected, waiting 30 seconds before retry...');
              await Future.delayed(const Duration(seconds: 30));
              consecutiveTimeouts = 0;
            }
            continue; // Don't count as network error, just retry
          }

          consecutiveNetworkErrors++;

          // If too many consecutive errors, fail gracefully but don't mark as failed
          // since the task might still be processing on the server
          if (consecutiveNetworkErrors >= maxConsecutiveNetworkErrors) {
            debugPrint(
                'Too many polling errors, stopping polling but keeping as processing');
            // Don't mark as failed - user can manually refresh later
            return;
          }
        }
      }

      // Timeout after 10 minutes
      final timeoutItem = item.copyWith(
        status: CreationStatus.failed,
        errorMessage:
            'Generation timed out. This usually means high server load - please try again.',
      );
      await _updateItem(timeoutItem);

      // Show timeout notification (uses localized strings automatically)
      try {
        await notificationService.showTimeoutNotification(
          payload: item.id,
        );
      } catch (notifError) {
        debugPrint('Failed to show timeout notification: $notifError');
      }

      if (state.currentTaskId == item.id) {
        state = state.copyWith(
          status: CreationWizardStatus.error,
          errorMessage: 'Generation timed out. Please try again.',
        );
      }
    } finally {
      // Always disable wake lock when polling completes
      try {
        await WakelockPlus.disable();
      } catch (e) {
        debugPrint('Failed to disable wake lock: $e');
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

  Future<void> deleteCreation(String id) async {
    try {
      await _repository.deleteCreation(id);
      final currentList = List<CreationItem>.from(state.creations);
      currentList.removeWhere((item) => item.id == id);
      state = state.copyWith(creations: currentList);
    } catch (e) {
      print('Error deleting creation: $e');
      rethrow;
    }
  }
}

final creationControllerProvider =
    NotifierProvider<CreationController, CreationState>(CreationController.new);
