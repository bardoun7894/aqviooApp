import 'dart:io';
import 'dart:ui';

import 'package:akvioo/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../../generated/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';

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
  final _openAIService = OpenAIService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  File? _selectedImage;
  bool _isEnhancing = false;
  bool _isListening = false;
  bool _speechAvailable = false;

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
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      final enhancedText = await _openAIService.enhancePrompt(currentText);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to enhance prompt: ${e.toString()}'),
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

  Future<void> _applyQuickSuggestion(String suggestion) async {
    // Don't show the prompt to user - directly generate
    ref.read(creationControllerProvider.notifier).updatePrompt(suggestion);

    // Get output type from config
    final config = ref.read(creationControllerProvider).config;
    final outputType = config.outputType;

    // Check if user can generate
    final creditsController = ref.read(creditsControllerProvider.notifier);
    final canGenerate = await creditsController.canGenerate(outputType);
    final creditsState = ref.read(creditsControllerProvider);

    if (!canGenerate) {
      // Show payment dialog
      final creditCost = creditsController.getCreditCost(outputType);
      final contentType = outputType == OutputType.video ? 'video' : 'image';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Insufficient Credits',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You need $creditCost credits to generate a $contentType.',
                style: GoogleFonts.outfit(),
              ),
              const SizedBox(height: 8),
              Text(
                'Your balance: ${creditsState.credits} credits',
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
                'Cancel',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
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
                'Buy Credits',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Deduct credits
    await creditsController.deductCreditsForGeneration(outputType);

    // Start video generation
    ref.read(creationControllerProvider.notifier).generateVideo();

    // Navigate to magic loading screen
    context.push('/magic-loading');
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
          content: Text('Speech recognition not available'),
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
          content: Text('Microphone permission is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
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
      // Show payment dialog
      final creditCost = creditsController.getCreditCost(outputType);
      final contentType = outputType == OutputType.video ? 'video' : 'image';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Insufficient Credits',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You need $creditCost credits to generate a $contentType.',
                style: GoogleFonts.outfit(),
              ),
              const SizedBox(height: 8),
              Text(
                'Your balance: ${creditsState.credits} credits',
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
                'Cancel',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
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
                'Buy Credits',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Deduct credits
    await creditsController.deductCreditsForGeneration(outputType);

    // Update prompt in config
    ref.read(creationControllerProvider.notifier).updatePrompt(prompt);

    // Start video generation
    ref.read(creationControllerProvider.notifier).generateVideo();

    // Navigate to magic loading screen
    context.push('/magic-loading');
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(creationControllerProvider);

    // Listen for state changes
    ref.listen<CreationState>(
      creationControllerProvider,
      (previous, next) {
        if (next.status == CreationWizardStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorMessage(next.errorMessage ?? '')),
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
                    'Creator',
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
                  '${creditsState.credits}',
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
                                          ? 'Enhancing...'
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
                          // Image Upload
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.15),
                                ),
                              ),
                              child: Icon(
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
                                    ? AppColors.primaryPurple.withOpacity(0.2)
                                    : AppColors.primaryPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isListening
                                      ? AppColors.primaryPurple.withOpacity(0.5)
                                      : AppColors.primaryPurple
                                          .withOpacity(0.15),
                                ),
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_outlined,
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
                              color: AppColors.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              ref
                                          .watch(creationControllerProvider)
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
                                color:
                                    AppColors.primaryPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.15),
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),

                          const Spacer(),

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
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: Colors.white,
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
    final suggestions = [
      {
        'label': AppLocalizations.of(context)!.productAd,
        'icon': Icons.shopping_bag_outlined,
        'prompt':
            'A premium product advertisement showcasing a luxury item with cinematic lighting and elegant presentation',
        'color': const Color(0xFFFF9800),
      },
      {
        'label': AppLocalizations.of(context)!.socialReel,
        'icon': Icons.movie_filter_outlined,
        'prompt':
            'An engaging social media reel with dynamic transitions and trendy visual effects',
        'color': const Color(0xFF00BCD4),
      },
      {
        'label': AppLocalizations.of(context)!.render3D,
        'icon': Icons.view_in_ar_outlined,
        'prompt':
            'A stunning 3D rendered animation with realistic materials, lighting, and camera movement',
        'color': AppColors.primaryPurple,
      },
      {
        'label': AppLocalizations.of(context)!.avatar,
        'icon': Icons.person_outline,
        'prompt':
            'A professional avatar video with AI-generated character speaking directly to camera',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _applyQuickSuggestion(suggestion['prompt'] as String),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          suggestion['icon'] as IconData,
                          size: 14,
                          color: suggestion['color'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          suggestion['label'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
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
    final recentCreations = creationState.creations
        .where((item) => item.status == CreationStatus.success)
        .take(6)
        .toList();

    if (recentCreations.isEmpty) {
      return const SizedBox.shrink();
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
              return _buildProjectCard(recentCreations[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(CreationItem item) {
    final isVideo = item.type == CreationType.video;

    return GestureDetector(
      onTap: () {
        if (item.url != null) {
          if (isVideo) {
            context.push(
              '/preview',
              extra: {
                'videoUrl': item.url,
                'thumbnailUrl': item.thumbnailUrl,
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(item.url!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.7),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
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
                  image:
                      item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: Stack(
                  children: [
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
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
                    // Play Icon
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
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
                          isVideo ? "Video" : "Image",
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
                    context.push('/payment', extra: 199.0);
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
        color: Color(0xFF0F0F11),
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
                      color: Colors.grey.shade800,
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
                    color: Colors.white,
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
                              style.displayName,
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
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.5),
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
                                    'More Styles',
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
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade800,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Show Less',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade400,
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

                  const SizedBox(height: 20),

                  // Voice Settings
                  _buildSection(
                    context,
                    ref,
                    AppLocalizations.of(context)!.voice,
                    Row(
                      children: [
                        _buildChoiceChip(
                          context,
                          ref,
                          AppLocalizations.of(context)!.female,
                          config.voiceGender == VoiceGender.female,
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVoiceSettings(gender: VoiceGender.female),
                        ),
                        const SizedBox(width: 8),
                        _buildChoiceChip(
                          context,
                          ref,
                          AppLocalizations.of(context)!.male,
                          config.voiceGender == VoiceGender.male,
                          () => ref
                              .read(creationControllerProvider.notifier)
                              .updateVoiceSettings(gender: VoiceGender.male),
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
            color: Colors.grey.shade400,
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
          color: isSelected ? AppColors.primaryPurple : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
