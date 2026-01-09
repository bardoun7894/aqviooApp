import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class PreviewState {
  final VideoPlayerController? videoController;
  final bool isInitialized;
  final bool isPlaying;
  final bool hasError;
  final int currentStyleIndex;
  final List<String> styles;

  PreviewState({
    this.videoController,
    this.isInitialized = false,
    this.isPlaying = false,
    this.hasError = false,
    this.currentStyleIndex = 0,
    this.styles = const [
      'Original',
      'Cinematic',
      'Cyberpunk',
      'Vintage',
      'Anime',
    ],
  });

  PreviewState copyWith({
    VideoPlayerController? videoController,
    bool? isInitialized,
    bool? isPlaying,
    bool? hasError,
    int? currentStyleIndex,
  }) {
    return PreviewState(
      videoController: videoController ?? this.videoController,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      hasError: hasError ?? this.hasError,
      currentStyleIndex: currentStyleIndex ?? this.currentStyleIndex,
      styles: styles,
    );
  }
}

class PreviewController extends Notifier<PreviewState> {
  @override
  PreviewState build() {
    ref.onDispose(() {
      state.videoController?.dispose();
    });
    return PreviewState();
  }

  Future<void> initializeVideo(String url) async {
    // Dispose previous controller if exists
    state.videoController?.dispose();

    // Reset error state
    state = state.copyWith(hasError: false);

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    // Add error listener for async playback errors (like 404)
    controller.addListener(() {
      if (controller.value.hasError && !state.hasError) {
        debugPrint("⚠️ PreviewController: Async video error detected");
        state = state.copyWith(
          hasError: true,
          isInitialized: false,
          isPlaying: false,
        );
      }
    });

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      state = state.copyWith(
        videoController: controller,
        isInitialized: true,
        isPlaying: true,
      );
    } catch (e) {
      // Handle error - set error state
      debugPrint("Error initializing video: $e");
      state = state.copyWith(hasError: true);
    }
  }

  void togglePlayPause() {
    final controller = state.videoController;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        controller.play();
        state = state.copyWith(isPlaying: true);
      }
    }
  }

  void nextStyle() {
    final nextIndex = (state.currentStyleIndex + 1) % state.styles.length;
    state = state.copyWith(currentStyleIndex: nextIndex);
  }

  void previousStyle() {
    final prevIndex = (state.currentStyleIndex - 1 + state.styles.length) %
        state.styles.length;
    state = state.copyWith(currentStyleIndex: prevIndex);
  }
}

final previewControllerProvider =
    NotifierProvider<PreviewController, PreviewState>(PreviewController.new);
