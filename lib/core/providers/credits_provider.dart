import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/creation/domain/models/creation_config.dart';

class CreditsState {
  final int credits;
  final bool hasGeneratedFirstVideo;
  final bool isLoading;

  const CreditsState({
    required this.credits,
    required this.hasGeneratedFirstVideo,
    this.isLoading = false,
  });

  CreditsState copyWith({
    int? credits,
    bool? hasGeneratedFirstVideo,
    bool? isLoading,
  }) {
    return CreditsState(
      credits: credits ?? this.credits,
      hasGeneratedFirstVideo: hasGeneratedFirstVideo ?? this.hasGeneratedFirstVideo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CreditsController extends StateNotifier<CreditsState> {
  final Ref ref;
  static const String _creditsKey = 'user_credits';
  static const String _firstVideoKey = 'has_generated_first_video';
  static const int _initialCredits = 10;
  static const int _creditCostPerVideo = 10;
  static const int _creditCostPerImage = 5;

  CreditsController(this.ref)
      : super(const CreditsState(
          credits: _initialCredits,
          hasGeneratedFirstVideo: false,
        )) {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final credits = prefs.getInt(_creditsKey) ?? _initialCredits;
      final hasGeneratedFirstVideo = prefs.getBool(_firstVideoKey) ?? false;

      state = CreditsState(
        credits: credits,
        hasGeneratedFirstVideo: hasGeneratedFirstVideo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  int getCreditCost(OutputType outputType) {
    return outputType == OutputType.video
        ? _creditCostPerVideo
        : _creditCostPerImage;
  }

  Future<bool> canGenerate(OutputType outputType) async {
    // Check if user has enough credits based on output type
    final cost = getCreditCost(outputType);
    return state.credits >= cost;
  }

  Future<void> deductCreditsForGeneration(OutputType outputType) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Deduct credits based on output type
      final cost = getCreditCost(outputType);
      final newCredits = state.credits - cost;
      await prefs.setInt(_creditsKey, newCredits);

      // Mark first video as generated if not already
      if (!state.hasGeneratedFirstVideo) {
        await prefs.setBool(_firstVideoKey, true);
        state = state.copyWith(credits: newCredits, hasGeneratedFirstVideo: true);
      } else {
        state = state.copyWith(credits: newCredits);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCredits(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newCredits = state.credits + amount;
      await prefs.setInt(_creditsKey, newCredits);
      state = state.copyWith(credits: newCredits);
    } catch (e) {
      rethrow;
    }
  }

  int get creditCost => _creditCostPerVideo;
}

final creditsControllerProvider =
    StateNotifierProvider<CreditsController, CreditsState>((ref) {
  return CreditsController(ref);
});
