import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_blob.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../providers/auth_provider.dart';
import '../../../../generated/app_localizations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;

    ref
        .read(authControllerProvider.notifier)
        .verifyOTP(verificationId: widget.verificationId, smsCode: otp);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      } else if (!next.isLoading && !next.hasError) {
        // Auth action succeeded
        context.go('/home');
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
                            Icons.lock_outline_rounded,
                            size: 32,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.verifyCode,
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
                          Text(
                            l10n.enterCodeSentTo(widget.phoneNumber),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // OTP Input
                          NeumorphicContainer(
                            borderRadius: 20,
                            depth: -3, // Concave
                            intensity: 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          const SizedBox(height: 32),

                          // Verify Button (Circle Check)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => context.pop(),
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
                      ),
                    ),
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
