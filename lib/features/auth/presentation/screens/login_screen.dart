import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/auth_provider.dart';

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

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyPhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    ref.read(authControllerProvider.notifier).verifyPhoneNumber(
          phoneNumber: phone,
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

    ref.read(authControllerProvider.notifier).verifyOTP(
          verificationId: _verificationId!,
          smsCode: otp,
        );
  }

  void _guestLogin() {
    ref.read(authControllerProvider.notifier).signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightGray,
                  Color(0xFFE0E7FF), // Very light purple
                ],
              ),
            ),
          ),
          
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  Text(
                    'Aqvioo',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create Magic with AI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darkGray,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Login Card
                  GlassCard(
                    opacity: 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_codeSent) ...[
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _phoneController,
                            hint: 'Phone Number (e.g. +1234567890)',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Continue',
                            onPressed: _verifyPhone,
                            isLoading: isLoading,
                          ),
                        ] else ...[
                          Text(
                            'Verify Code',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sent to ${_phoneController.text}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.darkGray.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _otpController,
                            hint: 'Enter SMS Code',
                            icon: Icons.lock_clock,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Verify',
                            onPressed: _verifyOTP,
                            isLoading: isLoading,
                          ),
                          TextButton(
                            onPressed: () => setState(() => _codeSent = false),
                            child: const Text('Change Number'),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Guest Mode
                  if (!_codeSent)
                    TextButton(
                      onPressed: isLoading ? null : _guestLogin,
                      child: Text(
                        'Continue as Guest',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.darkPurple,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.darkGray),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.darkGray.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
