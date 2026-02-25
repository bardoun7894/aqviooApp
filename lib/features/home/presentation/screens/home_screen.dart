import 'dart:io';
import 'dart:ui';

import 'package:akvioo/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../../../generated/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/guest_upgrade_sheet.dart';
import '../../../../core/utils/style_utils.dart';
import '../../../../core/widgets/generating_skeleton_card.dart';

import '../../../creation/presentation/providers/creation_provider.dart';
import '../../../creation/domain/models/creation_item.dart';
import '../../../creation/domain/models/creation_config.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../core/providers/credits_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _picker = ImagePicker();
  // OpenAI service accessed via Riverpod provider in _enhancePrompt()
  final stt.SpeechToText _speech = stt.SpeechToText();
  File? _selectedImage;
  bool _isEnhancing = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  int? _selectedSuggestionIndex; // Track selected quick suggestion

  String _sanitizeErrorMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Something went wrong. Please try again later.';
    }
    final cleaned = raw
        .replaceFirst(
            RegExp(r'^(Exception|KieAIException|ApiException):\s*'), '')
        .trim();
    if (cleaned.isEmpty ||
        cleaned.contains('HTTP') ||
        cleaned.contains('Trace')) {
      return 'Something went wrong. Please try again later.';
    }
    return cleaned;
  }

  @override
  void initState() {
    super.initState();

    // Initialize speech recognition
    _initSpeech();

    // Initialize prompt from config if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(creationControllerProvider).config;
      if (config.prompt.isNotEmpty) {
        _promptController.text = config.prompt;
      }
    });
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          if (mounted) {
            setState(() => _speechAvailable = false);
          }
        },
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      // Explicitly mark as unavailable on any initialization error
      _speechAvailable = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // SAFEGUARD: Prevent image picking for Video type (Image-to-Video not supported yet)
    final outputType = ref.read(creationControllerProvider).config.outputType;
    if (outputType == OutputType.video) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Image-to-Video is coming soon! Please use text prompt only."),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      ref
          .read(creationControllerProvider.notifier)
          .updateImagePath(pickedFile.path);
    }
  }

  Future<void> _enhancePrompt() async {
    final currentText = _promptController.text.trim();
    if (currentText.isEmpty) return;
    if (_isEnhancing) return;

    setState(() => _isEnhancing = true);

    try {
      final locale = AppLocalizations.of(context)?.localeName ?? 'en';
      final languageCode = locale.split('_').first;
      final openAIService = ref.read(openAIServiceProvider);
      final enhancedText = await openAIService.enhancePrompt(
        currentText,
        languageCode: languageCode,
      );
      if (!mounted) return;

      _promptController.text = enhancedText;
      ref.read(creationControllerProvider.notifier).updatePrompt(enhancedText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.promptEnhanced),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Extract clean error message without "Exception: " prefix
      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.failedToEnhancePrompt(errorMsg)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isEnhancing = false);
      }
    }
  }

  Future<void> _applyQuickSuggestion(
      String suggestion, int index, String label, VideoStyle? style) async {
    // Set the suggestion as hidden context (will be combined with user's prompt at generation time)
    final notifier = ref.read(creationControllerProvider.notifier);
    notifier.setHiddenContext(suggestion);

    // Set style if provided
    if (style != null) {
      notifier.updateVideoStyle(style);
    }

    // Update selected state
    setState(() {
      _selectedSuggestionIndex = index;
    });

    // Show a subtle visual indicator that context was added
    if (mounted) {
      final message = AppLocalizations.of(context)!.youWillGenerate(label);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AdvancedSettingsSheet(),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.speechRecognitionNotAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Request microphone permission
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.microphonePermissionRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _promptController.text = result.recognizedWords;
          ref
              .read(creationControllerProvider.notifier)
              .updatePrompt(result.recognizedWords);
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _handleGenerate() async {
    // SAFEGUARD: Check if already generating to prevent accidental duplicates
    final currentStatus = ref.read(creationControllerProvider).status;
    if (currentStatus == CreationWizardStatus.generatingScript ||
        currentStatus == CreationWizardStatus.generatingAudio ||
        currentStatus == CreationWizardStatus.generatingVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.alreadyGenerating),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      // Navigate to loading screen to show progress
      context.push('/magic-loading');
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.promptRequired),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      return;
    }

    // Get output type from config
    final config = ref.read(creationControllerProvider).config;
    final outputType = config.outputType;

    // Check if user can generate
    final creditsController = ref.read(creditsControllerProvider.notifier);
    final canGenerate = await creditsController.canGenerate(outputType);
    final creditsState = ref.read(creditsControllerProvider);

    if (!canGenerate) {
      if (!mounted) return;
      // Show payment dialog
      final cost = creditsController.getCost(outputType);
      final contentType = outputType == OutputType.video
          ? AppLocalizations.of(context)!.video
          : AppLocalizations.of(context)!.image;
      showDialog(
        context: context,
        builder: (context) {
          final isAnonymous = ref.read(authRepositoryProvider).isAnonymous;

          if (isAnonymous) {
            return GuestUpgradeSheet(
              title: AppLocalizations.of(context)!.insufficientCredits,
              subtitle:
                  '${AppLocalizations.of(context)!.guestCreditsUsed}\n${AppLocalizations.of(context)!.guestUpgradePrompt}',
              onSignUp: () {
                Navigator.pop(context);
                context.push('/signup');
              },
              onLogIn: () {
                Navigator.pop(context);
                context.push('/login');
              },
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.of(context)!.insufficientCredits,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${contentType} costs ${cost.toStringAsFixed(2)} ${Pricing.currency}',
                  style: GoogleFonts.outfit(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your balance: ${creditsState.balance.toStringAsFixed(2)} ${Pricing.currency}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/payment', extra: 199.0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.buyCredits,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        },
      );
      return;
    }

    // Update prompt in config before starting generation
    ref.read(creationControllerProvider.notifier).updatePrompt(prompt);

    // Navigate to loading screen first - it handles all state changes including errors
    if (!mounted) return;
    context.push('/magic-loading');

    // Deduct credits then start generation
    try {
      await creditsController.deductCreditsForGeneration(outputType);
    } catch (e) {
      debugPrint('Error deducting credits: $e');
      ref.read(creationControllerProvider.notifier).setError(
            'Unable to process credits. Please try again.',
          );
      return;
    }

    // Start generation and check result
    // Note: generateVideo() catches all errors internally and sets state to error,
    // so it will not throw. We check the state after it completes.
    await ref.read(creationControllerProvider.notifier).generateVideo();

    // Check if generation failed immediately (before polling starts)
    // If so, refund the credits since the API call itself failed
    final postGenState = ref.read(creationControllerProvider);
    if (postGenState.status == CreationWizardStatus.error) {
      debugPrint('Generation failed immediately, refunding credits...');
      try {
        await creditsController.addBalance(
          outputType == OutputType.video
              ? Pricing.videoCost
              : Pricing.imageCost,
        );
        debugPrint('Credits refunded after generation failure');
      } catch (refundError) {
        debugPrint('Error refunding credits: $refundError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final creationState = ref.watch(creationControllerProvider);

    // Listen for state changes - only show errors that did NOT originate
    // from an active generation (the magic loading screen handles those)
    ref.listen<CreationState>(
      creationControllerProvider,
      (previous, next) {
        if (next.status == CreationWizardStatus.error &&
            previous?.status != CreationWizardStatus.generatingScript &&
            previous?.status != CreationWizardStatus.generatingVideo &&
            previous?.status != CreationWizardStatus.generatingAudio) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorMessage(_sanitizeErrorMessage(next.errorMessage))),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B9DFF).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: _buildHeader(),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildPromptSection(),
                      const SizedBox(height: 24),
                      _buildQuickSuggestions(),
                      const SizedBox(height: 32),
                      _buildRecentProjects(),
                      const SizedBox(height: 120), // Space for bottom nav + FAB
                    ],
                  ),
                ),
              ),

              // Bottom Navigation with FAB
              _buildBottomNavigation(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final creditsState = ref.watch(creditsControllerProvider);
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    final userName = currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Profile Section
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple,
                      const Color(0xFF9D6BFF),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.creator,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ).copyWith(height: 1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ).copyWith(height: 1),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Credits Badge
          Container(
            padding:
                const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bolt,
                    size: 12,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${creditsState.balance.toStringAsFixed(2)} ${Pricing.currency}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Settings Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: () => context.push('/account-settings'),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.createMagic,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.modelVersion,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Prompt Input Card with Glassmorphism
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.03),
                        Colors.transparent,
                        const Color(0xFF6B9DFF).withOpacity(0.03),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhance Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isEnhancing ? null : _enhancePrompt,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _isEnhancing
                                      ? AppColors.mediumGray.withOpacity(0.1)
                                      : AppColors.primaryPurple
                                          .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isEnhancing
                                        ? AppColors.mediumGray.withOpacity(0.2)
                                        : AppColors.primaryPurple
                                            .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isEnhancing)
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryPurple,
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: AppColors.primaryPurple,
                                      ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isEnhancing
                                          ? AppLocalizations.of(context)!
                                              .enhancing
                                          : AppLocalizations.of(context)!
                                              .enhance,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _isEnhancing
                                            ? AppColors.textSecondary
                                            : AppColors.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Text Input
                      TextField(
                        controller: _promptController,
                        maxLines: 4,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.ideaStepPlaceholder,
                          hintStyle: GoogleFonts.outfit(
                            color: AppColors.textHint,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),

                      const SizedBox(height: 16),

                      // Bottom Row: Image Upload, Settings, Generate
                      Row(
                        children: [
                          // Left side controls - expanded and scrollable to prevent overflow
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Image Upload
                                  // Image Upload / Preview
                                  GestureDetector(
                                    onTap: _selectedImage != null
                                        ? () {
                                            context.push(
                                              '/preview',
                                              extra: {
                                                'videoUrl':
                                                    _selectedImage!.path,
                                                'thumbnailUrl': null,
                                                'prompt':
                                                    _promptController.text,
                                                'isImage': true,
                                              },
                                            );
                                          }
                                        : _pickImage,
                                    onLongPress:
                                        _pickImage, // Allow changing image
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      padding: _selectedImage != null
                                          ? EdgeInsets.zero
                                          : const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primaryPurple
                                              .withOpacity(0.15),
                                        ),
                                        image: _selectedImage != null
                                            ? DecorationImage(
                                                image:
                                                    FileImage(_selectedImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _selectedImage != null
                                          ? Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.fullscreen_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.image_outlined,
                                              size: 18,
                                              color: AppColors.primaryPurple,
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Speech-to-Text Button
                                  GestureDetector(
                                    onTap: _toggleListening,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _isListening
                                            ? AppColors.primaryPurple
                                                .withOpacity(0.2)
                                            : AppColors.primaryPurple
                                                .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isListening
                                              ? AppColors.primaryPurple
                                                  .withOpacity(0.5)
                                              : AppColors.primaryPurple
                                                  .withOpacity(0.15),
                                        ),
                                      ),
                                      child: Icon(
                                        _isListening
                                            ? Icons.mic
                                            : Icons.mic_outlined,
                                        size: 18,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Current Aspect Ratio Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      ref
                                                  .watch(
                                                      creationControllerProvider)
                                                  .config
                                                  .videoAspectRatio ==
                                              'landscape'
                                          ? '16:9'
                                          : '9:16',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Settings Icon Button
                                  GestureDetector(
                                    onTap: _showAdvancedSettings,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primaryPurple
                                              .withOpacity(0.15),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.tune_rounded,
                                        size: 16,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Generate Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleGenerate,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.generate,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ref
                                                    .watch(
                                                        creationControllerProvider)
                                                    .config
                                                    .outputType ==
                                                OutputType.video
                                            ? '${Pricing.videoCost} ${Pricing.currency}'
                                            : '${Pricing.imageCost} ${Pricing.currency}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final currentConfig = ref.watch(creationControllerProvider).config;

    final suggestions = [
      {
        'label': AppLocalizations.of(context)!.productAd,
        'icon': Icons.shopping_bag_outlined,
        'prompt':
            'A premium product advertisement showcasing a luxury item with cinematic lighting and elegant presentation',
        'color': const Color(0xFFFF9800),
        'style': VideoStyle.modern,
      },
      {
        'label': AppLocalizations.of(context)!.socialReel,
        'icon': Icons.movie_filter_outlined,
        'prompt':
            'An engaging social media reel with dynamic transitions and trendy visual effects',
        'color': const Color(0xFF00BCD4),
        'style': VideoStyle.socialMedia,
      },
      {
        'label': AppLocalizations.of(context)!.cinematic,
        'icon': Icons.movie_creation_outlined,
        'prompt':
            'A high-end cinematic video with dramatic lighting, 4k resolution, and professional color grading',
        'color': const Color(0xFFE91E63),
        'style': VideoStyle.cinematic,
      },
      {
        'label': AppLocalizations.of(context)!.realEstate,
        'icon': Icons.home_work_outlined,
        'prompt':
            'A luxury real estate showcase featuring modern architecture, spacious interiors, and natural lighting',
        'color': const Color(0xFF4CAF50),
        'style': VideoStyle.minimal,
      },
      {
        'label': AppLocalizations.of(context)!.render3D,
        'icon': Icons.view_in_ar_outlined,
        'prompt':
            'A stunning 3D rendered animation with realistic materials, lighting, and camera movement',
        'color': AppColors.primaryPurple,
        'style': VideoStyle.animation,
      },
      {
        'label': AppLocalizations.of(context)!.educational,
        'icon': Icons.school_outlined,
        'prompt':
            'An engaging educational video with clear visuals, explanatory graphics, and professional narration',
        'color': const Color(0xFF2196F3),
        'style': VideoStyle.documentary,
      },
      {
        'label': AppLocalizations.of(context)!.corporate,
        'icon': Icons.business_center_outlined,
        'prompt':
            'A professional corporate presentation with clean graphics, modern typography, and business context',
        'color': const Color(0xFF607D8B),
        'style': VideoStyle.corporate,
      },
      {
        'label': AppLocalizations.of(context)!.avatar,
        'icon': Icons.person_outline,
        'prompt':
            'A professional avatar video with AI-generated character speaking directly to camera',
        'color': const Color(0xFF9C27B0),
        'style': null,
      },
      {
        'label': AppLocalizations.of(context)!.gaming,
        'icon': Icons.sports_esports_outlined,
        'prompt':
            'A dynamic gaming highlight with intense action, neon effects, and high energy atmosphere',
        'color': const Color(0xFF673AB7),
        'style': VideoStyle.sciFi,
      },
      {
        'label': AppLocalizations.of(context)!.documentary,
        'icon': Icons.camera_alt_outlined,
        'prompt':
            'A compelling documentary style video with realistic footage, interviews, and narrative depth',
        'color': const Color(0xFF795548),
        'style': VideoStyle.documentary,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final style = suggestion['style'] as VideoStyle?;

            bool isSelected;
            if (style != null) {
              isSelected = currentConfig.videoStyle == style;
            } else {
              isSelected = _selectedSuggestionIndex == index;
            }

            final color = suggestion['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _applyQuickSuggestion(
                      suggestion['prompt'] as String,
                      index,
                      suggestion['label'] as String,
                      style),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? color : Colors.white.withOpacity(0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: isSelected ? 12 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          suggestion['icon'] as IconData,
                          size: 14,
                          color: isSelected ? color : color.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          suggestion['label'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentProjects() {
    final creationState = ref.watch(creationControllerProvider);

    // Get processing items first (show at top)
    final processingCreations = creationState.creations
        .where((item) => item.status == CreationStatus.processing)
        .toList();

    // Get successful items
    final successCreations = creationState.creations
        .where((item) => item.status == CreationStatus.success)
        .toList();

    // Combine: processing first, then success, limit to 6 total
    final recentCreations = [
      ...processingCreations,
      ...successCreations,
    ].take(6).toList();

    if (recentCreations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.video_library_outlined,
                  size: 32,
                  color: AppColors.primaryPurple.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No creations yet',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your first magic video now!',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.recentProjects,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/my-creations'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewLibrary,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2-Column Grid
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: recentCreations.length,
            itemBuilder: (context, index) {
              final item = recentCreations[index];
              // Show skeleton card for processing items
              if (item.status == CreationStatus.processing) {
                return GeneratingSkeletonCard(
                  isVideo: item.type == CreationType.video,
                  isCompact: true,
                  prompt: item.prompt,
                );
              }
              return HomeProjectCard(item: item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Nav Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, true, () {}),
                  _buildNavItem(Icons.video_library_rounded, false, () {
                    context.push('/my-creations');
                  }),
                  const SizedBox(width: 70), // Space for FAB
                  _buildNavItem(Icons.credit_card_rounded, false, () {
                    if (kIsWeb) {
                      // Show message that payments are only on mobile
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.paymentMobileOnly,
                          ),
                          backgroundColor: AppColors.primaryPurple,
                        ),
                      );
                    } else {
                      context.push('/payment', extra: 199.0);
                    }
                  }),
                  _buildNavItem(Icons.person_rounded, false, () {
                    context.push('/account-settings');
                  }),
                ],
              ),

              // Floating Action Button
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _handleGenerate,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryPurple,
                            const Color(0xFF9D6BFF),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.5),
                            blurRadius: 24,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive
                  ? AppColors.primaryPurple
                  : AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primaryPurple : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Advanced Settings Bottom Sheet
class _AdvancedSettingsSheet extends ConsumerStatefulWidget {
  const _AdvancedSettingsSheet();

  @override
  ConsumerState<_AdvancedSettingsSheet> createState() =>
      _AdvancedSettingsSheetState();
}

class _AdvancedSettingsSheetState
    extends ConsumerState<_AdvancedSettingsSheet> {
  bool _showAllStyles = false;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(creationControllerProvider).config;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  AppLocalizations.of(context)!.advancedSettings,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // Output Type
                _buildSection(
                  context,
                  ref,
                  AppLocalizations.of(context)!.outputType,
                  Row(
                    children: [
                      _buildChoiceChip(
                        context,
                        ref,
                        AppLocalizations.of(context)!.video,
                        config.outputType == OutputType.video,
                        () => ref
                            .read(creationControllerProvider.notifier)
                            .updateOutputType(OutputType.video),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceChip(
                        context,
                        ref,
                        AppLocalizations.of(context)!.image,
                        config.outputType == OutputType.image,
                        () => ref
                            .read(creationControllerProvider.notifier)
                            .updateOutputType(OutputType.image),
                      ),
                    ],
                  ),
                ),

                if (config.outputType == OutputType.video) ...[
                  const SizedBox(height: 20),

                  // Video Style
                  _buildSection(
                    context,
                    ref,
                    AppLocalizations.of(context)!.style,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (_showAllStyles
                                  ? VideoStyle.values
                                  : VideoStyle.values.take(6).toList())
                              .map((style) {
                            final isSelected = config.videoStyle == style;
                            return _buildChoiceChip(
                              context,
                              ref,
                              StyleUtils.getLocalizedStyleName(context, style),
                              isSelected,
                              () => ref
                                  .read(creationControllerProvider.notifier)
                                  .updateVideoStyle(style),
                            );
                          }).toList(),
                        ),
                        if (!_showAllStyles &&
                            VideoStyle.values.length > 6) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() => _showAllStyles = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                    color: AppColors.primaryPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.moreStyles,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (_showAllStyles) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() => _showAllStyles = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.showLess,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Duration
                  _buildSection(
                    context,
                    ref,
                    AppLocalizations.of(context)!.duration,
                    Row(
                      children: [
                        _buildChoiceChip(
                          context,
                          ref,
                          '10s',
                          config.videoDurationSeconds == 10,
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVideoDuration(10),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceChip(
                          context,
                          ref,
                          '15s',
                          config.videoDurationSeconds == 15,
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVideoDuration(15),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Aspect Ratio
                  _buildSection(
                    context,
                    ref,
                    AppLocalizations.of(context)!.aspectRatio,
                    Row(
                      children: [
                        _buildChoiceChip(
                          context,
                          ref,
                          '16:9',
                          config.videoAspectRatio == 'landscape',
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVideoAspectRatio('landscape'),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceChip(
                          context,
                          ref,
                          '9:16',
                          config.videoAspectRatio == 'portrait',
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVideoAspectRatio('portrait'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    Widget child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildChoiceChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class HomeProjectCard extends StatefulWidget {
  final CreationItem item;

  const HomeProjectCard({super.key, required this.item});

  @override
  State<HomeProjectCard> createState() => _HomeProjectCardState();
}

class _HomeProjectCardState extends State<HomeProjectCard> {
  VideoPlayerController? _videoController;
  VoidCallback? _videoErrorListener;
  bool _isPlayerInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == CreationType.video &&
        widget.item.status == CreationStatus.success &&
        widget.item.url != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Add a small staggered delay to prevent all videos from loading at once
      // which causes main thread lag (skipped frames) on some devices
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url!),
      );

      // Add error listener for async playback errors (like 404)
      _videoErrorListener = () {
        if (mounted && _videoController!.value.hasError) {
          setState(() {
            _hasError = true;
            _isPlayerInitialized = false;
          });
        }
      };
      _videoController!.addListener(_videoErrorListener!);

      await _videoController!.initialize();
      await _videoController!.setVolume(0); // Mute for background play
      await _videoController!.setLooping(true);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video preview: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_videoErrorListener != null && _videoController != null) {
      _videoController!.removeListener(_videoErrorListener!);
    }
    _videoController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Check if item is older than 14 days
    final isExpired =
        DateTime.now().difference(widget.item.createdAt).inDays >= 14;
    if (isExpired) {
      // Don't allow clicking on expired files
      debugPrint('🚫 Creation is expired (> 14 days), ignoring tap');
      return;
    }

    if (widget.item.status == CreationStatus.success &&
        widget.item.url != null) {
      // Navigate to full preview screen for both video and image
      context.push(
        '/preview',
        extra: {
          'videoUrl': widget.item.url,
          'thumbnailUrl': widget.item.thumbnailUrl,
          'prompt': widget.item.prompt,
          'isImage': widget.item.type == CreationType.image,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isVideo = item.type == CreationType.video;
    final isImage = item.type == CreationType.image;
    final hasImageUrl = isImage && item.url != null && item.url!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Video / Image Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isVideo
                        ? [const Color(0xFF6B9DFF), const Color(0xFF9D6BFF)]
                        : [const Color(0xFFFF6B9D), const Color(0xFFFFA06B)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Show image directly for image type
                      if (hasImageUrl)
                        Image.network(
                          item.url!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black.withOpacity(0.1),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 24,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'File deleted',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    DateTime.now()
                                                .difference(item.createdAt)
                                                .inDays >
                                            60
                                        ? '(Expired > 2 months)'
                                        : DateTime.now()
                                                    .difference(item.createdAt)
                                                    .inDays >
                                                14
                                            ? '(Expired > 14 days)'
                                            : '(File deleted)',
                                    style: GoogleFonts.outfit(
                                      fontSize: 8,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      // Show thumbnail for video if available (before video loads)
                      if (isVideo &&
                          !_isPlayerInitialized &&
                          item.thumbnailUrl != null &&
                          item.thumbnailUrl!.isNotEmpty)
                        Image.network(
                          item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),

                      // Video Player (if ready)
                      if (_isPlayerInitialized && _videoController != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),

                      // Error state for video
                      if (isVideo && _hasError)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library_outlined,
                                size: 24,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'File deleted',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                DateTime.now()
                                            .difference(item.createdAt)
                                            .inDays >
                                        60
                                    ? '(Expired > 2 months)'
                                    : DateTime.now()
                                                .difference(item.createdAt)
                                                .inDays >
                                            14
                                        ? '(Expired > 14 days)'
                                        : '(File deleted)',
                                style: GoogleFonts.outfit(
                                  fontSize: 8,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),

                      // Play icon for video
                      if (isVideo)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Expand icon for image
                      if (isImage)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.prompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : Icons.image_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVideo
                              ? AppLocalizations.of(context)!.video
                              : AppLocalizations.of(context)!.image,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isVideo && item.duration != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.duration!,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
