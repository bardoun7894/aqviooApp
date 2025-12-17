import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../../generated/app_localizations.dart';

/// Compact 2025 Material 3 Signup Screen
/// Features: Single form, email/phone toggle, matching login design
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  // State
  bool _usePhone = false; // false = email, true = phone
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _verificationId;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  void _handleSignup() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }

    if (_usePhone) {
      _signupWithPhone();
    } else {
      _signupWithEmail();
    }
  }

  void _signupWithEmail() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    // Call Firebase signup
    ref.read(authControllerProvider.notifier).signUpWithEmailPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  void _signupWithPhone() {
    final phone = _phoneController.text.trim();

    if (!_isValidPhone(phone)) {
      _showSnackBar('Please enter a valid phone number', isError: true);
      return;
    }

    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    ref.read(authControllerProvider.notifier).verifyPhoneNumber(
          phoneNumber: '+$digits',
          codeSent: (verificationId, resendToken) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
            });
            _showSnackBar('Verification code sent!');
          },
        );
  }

  void _verifyOTP() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showSnackBar('Please enter a valid 6-digit code', isError: true);
      return;
    }

    if (_verificationId == null) {
      _showSnackBar('Session expired. Please try again', isError: true);
      setState(() => _codeSent = false);
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .verifyOTP(verificationId: _verificationId!, smsCode: otp);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        String errorMessage = 'Signup failed';
        if (next.error is FirebaseAuthException) {
          final e = next.error as FirebaseAuthException;
          errorMessage = _getErrorMessage(e.code);
        }
        _showSnackBar(errorMessage, isError: true);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Logo
                  _buildCompactHeader(context, l10n, isDark),

                  const SizedBox(height: 32),

                  // Main Card
                  _buildCompactCard(context, isLoading, l10n, isDark),

                  const SizedBox(height: 16),

                  // Already have account
                  if (!_codeSent) _buildLoginLink(context, isDark),

                  const SizedBox(height: 24),

                  // Footer
                  _buildCompactFooter(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'This signup method is not enabled';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Signup failed. Please try again';
    }
  }

  Widget _buildCompactHeader(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        // Compact Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : AppColors.neuShadowDark.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.video_library_rounded,
                size: 32,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          l10n.createAccount,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          l10n.joinAndStartCreating,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context, bool isLoading, AppLocalizations l10n, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : AppColors.neuShadowDark.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: _codeSent
          ? _buildOTPForm(context, isLoading, isDark)
          : _buildSignupForm(context, isLoading, isDark),
    );
  }

  Widget _buildSignupForm(BuildContext context, bool isLoading, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Method Toggle
        _buildMethodToggle(isDark),
        const SizedBox(height: 16),

        // Name Field
        _buildCompactTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: l10n.fullName,
          icon: Icons.person_outline,
          isDark: isDark,
          onSubmitted: (_) {
            if (_usePhone) {
              _phoneFocusNode.requestFocus();
            } else {
              _emailFocusNode.requestFocus();
            }
          },
        ),
        const SizedBox(height: 12),

        // Email or Phone
        if (_usePhone)
          _buildCompactTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            hintText: l10n.phoneNumber,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isDark: isDark,
            onSubmitted: (_) => _handleSignup(),
          )
        else ...[
          _buildCompactTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hintText: l10n.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 12),

          // Password
          _buildCompactTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hintText: l10n.password,
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                size: 18,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 12),

          // Confirm Password
          _buildCompactTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            hintText: l10n.confirmPassword,
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            onSubmitted: (_) => _handleSignup(),
          ),
        ],

        const SizedBox(height: 20),

        // Signup Button
        _buildCompactButton(
          label: l10n.signUp,
          icon: Icons.arrow_forward,
          onPressed: isLoading ? null : _handleSignup,
          isLoading: isLoading,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMethodToggle(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhone = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_usePhone
                      ? (isDark ? AppColors.white.withOpacity(0.1) : AppColors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_usePhone
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : AppColors.neuShadowDark.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: !_usePhone
                          ? AppColors.primaryPurple
                          : (isDark ? AppColors.mediumGray : AppColors.textHint),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.email,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: !_usePhone ? FontWeight.w600 : FontWeight.w500,
                        color: !_usePhone
                            ? (isDark ? AppColors.white : AppColors.textPrimary)
                            : (isDark ? AppColors.mediumGray : AppColors.textHint),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePhone = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _usePhone
                      ? (isDark ? AppColors.white.withOpacity(0.1) : AppColors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _usePhone
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : AppColors.neuShadowDark.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: _usePhone
                          ? AppColors.primaryPurple
                          : (isDark ? AppColors.mediumGray : AppColors.textHint),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.phone,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: _usePhone ? FontWeight.w600 : FontWeight.w500,
                        color: _usePhone
                            ? (isDark ? AppColors.white : AppColors.textPrimary)
                            : (isDark ? AppColors.mediumGray : AppColors.textHint),
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

  Widget _buildOTPForm(BuildContext context, bool isLoading, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.otpVerification,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '${l10n.enterOtp}\n${_phoneController.text}',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // OTP Input
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray : AppColors.lightGray,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _otpController.text.isEmpty
                  ? (isDark ? Colors.white.withOpacity(0.1) : AppColors.neuShadowDark.withOpacity(0.2))
                  : AppColors.primaryPurple,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textPrimary,
              letterSpacing: 10,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              hintText: l10n.otpInputHint,
              hintStyle: GoogleFonts.outfit(
                color: isDark ? AppColors.darkGray : AppColors.textHint,
                fontSize: 24,
                letterSpacing: 10,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onSubmitted: (_) => _verifyOTP(),
          ),
        ),
        const SizedBox(height: 20),

        // Verify Button
        _buildCompactButton(
          label: l10n.verify,
          icon: Icons.check_circle_outline,
          onPressed: isLoading ? null : _verifyOTP,
          isLoading: isLoading,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Back Button
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _codeSent = false),
            icon: Icon(
              Icons.arrow_back,
              size: 16,
              color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            ),
            label: Text(
              l10n.changeNumber,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.neuShadowDark.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            color: isDark ? AppColors.mediumGray : AppColors.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    bool isLoading = false,
  }) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: isDisabled
                ? (isDark ? AppColors.darkGray : AppColors.lightGray)
                : AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? (isDark ? Colors.white24 : Colors.black26)
                              : Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        icon,
                        color: isDisabled
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
          child: Text(
            l10n.login,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFooter(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          'By continuing, you agree to our',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: isDark ? AppColors.mediumGray : AppColors.textHint,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.termsOfService,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          'and',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: isDark ? AppColors.mediumGray : AppColors.textHint,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.privacyPolicy,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
