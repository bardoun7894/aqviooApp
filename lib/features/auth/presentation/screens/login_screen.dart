import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../providers/auth_provider.dart';
import '../../../../generated/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;
  String? _verificationId;
  String _selectedCountryCode = '+966';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyPhone() {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phone.isEmpty) return;

    ref
        .read(authControllerProvider.notifier)
        .verifyPhoneNumber(
          phoneNumber: '$_selectedCountryCode$phone',
          codeSent: (verificationId, resendToken) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
            });
          },
        );
  }

  void _verifyOTP() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _verificationId == null) return;

    ref
        .read(authControllerProvider.notifier)
        .verifyOTP(verificationId: _verificationId!, smsCode: otp);
  }

  Future<void> _guestLogin() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();
    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (!state.hasError && !state.isLoading) {
        context.go('/home');
      }
    }
  }

  final List<Map<String, String>> _countries = [
    {'code': '+966', 'flag': '🇸🇦'},
    {'code': '+20', 'flag': '🇪🇬'},
    {'code': '+971', 'flag': '🇦🇪'},
    {'code': '+965', 'flag': '🇰🇼'},
    {'code': '+974', 'flag': '🇶🇦'},
    {'code': '+973', 'flag': '🇧🇭'},
    {'code': '+968', 'flag': '🇴🇲'},
    {'code': '+962', 'flag': '🇯🇴'},
    {'code': '+961', 'flag': '🇱🇧'},
    {'code': '+964', 'flag': '🇮🇶'},
    {'code': '+963', 'flag': '🇸🇾'},
    {'code': '+970', 'flag': '🇵🇸'},
    {'code': '+967', 'flag': '🇾🇪'},
    {'code': '+249', 'flag': '🇸🇩'},
    {'code': '+218', 'flag': '🇱🇾'},
    {'code': '+212', 'flag': '🇲🇦'},
    {'code': '+216', 'flag': '🇹🇳'},
    {'code': '+213', 'flag': '🇩🇿'},
    {'code': '+222', 'flag': '🇲🇷'},
    {'code': '+252', 'flag': '🇸🇴'},
    {'code': '+253', 'flag': '🇩🇯'},
    {'code': '+269', 'flag': '🇰🇲'},
  ];

  @override
  Widget build(BuildContext context) {
    // Safety check: Ensure selected code exists in the list
    if (!_countries.any((c) => c['code'] == _selectedCountryCode)) {
      _selectedCountryCode = _countries.first['code']!;
    }

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        String errorMessage = 'Error: ${next.error}';
        if (next.error is FirebaseAuthException) {
          final e = next.error as FirebaseAuthException;
          if (e.code == 'admin-restricted-operation' ||
              e.code == 'operation-not-allowed') {
            errorMessage =
                'Guest login is disabled. Please enable Anonymous Auth in Firebase Console.';
          } else {
            errorMessage = e.message ?? errorMessage;
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Animated Background
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedGradientBlob(
              size: 400,
              colors: [
                AppColors.gradientBlobPurple.withOpacity(0.4),
                AppColors.gradientBlobPink.withOpacity(0.3),
              ],
              duration: const Duration(seconds: 8),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: AnimatedGradientBlob(
              size: 350,
              colors: [
                AppColors.gradientBlobBlue.withOpacity(0.4),
                AppColors.gradientBlobPurple.withOpacity(0.2),
              ],
              duration: const Duration(seconds: 10),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NeumorphicContainer(
                          width: 60,
                          height: 60,
                          borderRadius: 16,
                          depth: 3,
                          intensity: 0.6,
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 32,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.appTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Glassmorphic Card
                    GlassContainer(
                      borderRadius: 32,
                      blurIntensity: 15,
                      opacity: 0.6,
                      borderColor: AppColors.white.withOpacity(0.8),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Text(
                            _codeSent ? l10n.verifyCode : l10n.welcome,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _codeSent
                                ? l10n.enterCodeSentTo(
                                    '$_selectedCountryCode${_phoneController.text}',
                                  )
                                : l10n.enterPhoneToContinue,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          if (!_codeSent) ...[
                            // Phone Input
                            NeumorphicContainer(
                              borderRadius: 20,
                              depth: -3, // Concave for input
                              intensity: 0.6,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  // Country Code
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCountryCode,
                                      items: _countries.map((country) {
                                        return DropdownMenuItem(
                                          value: country['code'],
                                          child: Text(
                                            '${country['flag']} ${country['code']}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(
                                            () => _selectedCountryCode = value,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                      ),
                                      menuMaxHeight: 300,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: AppColors.mediumGray.withOpacity(
                                      0.3,
                                    ),
                                    margin:
                                        const EdgeInsetsDirectional.symmetric(
                                          horizontal: 12,
                                        ),
                                  ),
                                  // Phone Number
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '000 000 0000',
                                        hintStyle: GoogleFonts.outfit(
                                          color: AppColors.textHint,
                                          fontSize: 18,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action Button (Circle Arrow)
                            Center(
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _verifyPhone,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: AppColors.primaryPurple
                                        .withOpacity(0.4),
                                    shape: const CircleBorder(),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 32,
                                        ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // OTP Input
                            NeumorphicContainer(
                              borderRadius: 20,
                              depth: -3, // Concave
                              intensity: 0.6,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 12,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••',
                                  hintStyle: GoogleFonts.outfit(
                                    color: AppColors.textHint,
                                    fontSize: 28,
                                    letterSpacing: 12,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Verify Button (Circle Check)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _codeSent = false),
                                  child: Text(
                                    l10n.back,
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _verifyOTP,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: AppColors.primaryPurple
                                          .withOpacity(0.4),
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_rounded,
                                            size: 32,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Guest Mode
                    if (!_codeSent) ...[
                      TextButton(
                        onPressed: isLoading ? null : _guestLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.continueAsGuest,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
