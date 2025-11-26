import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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

    ref.read(authControllerProvider.notifier).verifyPhoneNumber(
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6E6FA), // Lavender
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
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
                      Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appTitle,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: const Color(0xFF333333),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Glassmorphic Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.white.withOpacity(0.7),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                _codeSent ? l10n.verifyCode : l10n.welcome,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: const Color(0xFF1F2937),
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _codeSent
                                    ? l10n.enterCodeSentTo(
                                        '$_selectedCountryCode${_phoneController.text}')
                                    : l10n.enterPhoneToContinue,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xFF6B7280)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              if (!_codeSent) ...[
                                // Phone Input
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
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
                                                    '${country['flag']} ${country['code']}'),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() =>
                                                    _selectedCountryCode =
                                                        value);
                                              }
                                            },
                                            style: const TextStyle(
                                              color: Color(0xFF374151),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            icon: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: 20),
                                            menuMaxHeight: 300,
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: const Color(0xFFE5E7EB),
                                          margin: const EdgeInsetsDirectional
                                              .symmetric(horizontal: 12),
                                        ),
                                        // Phone Number
                                        Expanded(
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: TextField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              style: const TextStyle(
                                                color: Color(0xFF1F2937),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: '000 000 0000',
                                                hintStyle: TextStyle(
                                                  color:
                                                      const Color(0xFF9CA3AF),
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Action Button (Circle Arrow)
                                Center(
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : _verifyPhone,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryPurple,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
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
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 32),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // OTP Input
                                Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: TextField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF1F2937),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 12,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '••••••',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFFD1D5DB),
                                        letterSpacing: 12,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
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
                                        style: const TextStyle(
                                            color: Color(0xFF6B7280)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : _verifyOTP,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryPurple,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: AppColors.primaryPurple
                                              .withOpacity(0.4),
                                          shape: const CircleBorder(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.check_rounded,
                                                size: 32),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Guest Mode
                  if (!_codeSent) ...[
                    TextButton(
                      onPressed: isLoading ? null : _guestLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.continueAsGuest,
                            style: const TextStyle(
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
      ),
    );
  }
}
