import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_extensions.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../providers/auth_provider.dart';
import '../../../../generated/app_localizations.dart';

/// Compact 2025 Material 3 Login Screen
/// Features: Single unified form, no scrolling, clean design
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _identifierController = TextEditingController(); // Email or Phone
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _identifierFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State
  bool _codeSent = false;
  bool _obscurePassword = true;
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
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool _isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  bool _isPhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  void _handleSignIn() {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      _showSnackBar('Please enter your email or phone', isError: true);
      return;
    }

    if (_isEmail(identifier)) {
      _signInWithEmail(identifier);
    } else if (_isPhone(identifier)) {
      _signInWithPhone(identifier);
    } else {
      _showSnackBar('Please enter a valid email or phone number', isError: true);
    }
  }

  void _signInWithEmail(String email) {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      _showSnackBar('Please enter your password', isError: true);
      return;
    }

    // TODO: Implement email/password sign-in with Firebase
    _showSnackBar('Email sign-in coming soon!');
  }

  void _signInWithPhone(String phone) {
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

  Future<void> _guestLogin() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();
    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (!state.hasError && !state.isLoading) {
        context.go('/home');
      }
    }
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
        String errorMessage = 'Authentication failed';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                _buildCompactHeader(context, l10n, isDark),

                const SizedBox(height: 32),

                // Main Card
                _buildCompactCard(context, isLoading, l10n, isDark),

                const SizedBox(height: 16),

                // Guest Login
                if (!_codeSent) _buildCompactGuestLogin(context, isLoading, l10n, isDark),

                const Spacer(),

                // Footer
                _buildCompactFooter(context, isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'Account disabled';
      case 'user-not-found':
        return 'No account found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Authentication failed';
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
          l10n.appTitle,
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
          l10n.appSubtitle,
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
          : _buildUnifiedForm(context, isLoading, isDark),
    );
  }

  Widget _buildUnifiedForm(BuildContext context, bool isLoading, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final identifier = _identifierController.text.trim();
    final showPassword = identifier.isNotEmpty && _isEmail(identifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email or Phone Input
        _buildCompactTextField(
          controller: _identifierController,
          focusNode: _identifierFocusNode,
          hintText: 'Email or Phone',
          icon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (showPassword) {
              _passwordFocusNode.requestFocus();
            } else {
              _handleSignIn();
            }
          },
        ),

        // Password Field (only show for email)
        if (showPassword) ...[
          const SizedBox(height: 12),
          _buildCompactTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hintText: 'Password',
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
            onSubmitted: (_) => _handleSignIn(),
          ),
        ],

        const SizedBox(height: 20),

        // Sign In Button
        _buildCompactButton(
          label: showPassword ? 'Sign In' : 'Continue',
          icon: Icons.arrow_forward,
          onPressed: isLoading ? null : _handleSignIn,
          isLoading: isLoading,
          isDark: isDark,
        ),

        // Forgot Password (only for email)
        if (showPassword) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                _showSnackBar('Forgot password coming soon!');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: Text(
                l10n.forgotPassword,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ],
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
          '${l10n.enterOtp}\n${_identifierController.text}',
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

  Widget _buildCompactGuestLogin(BuildContext context, bool isLoading, AppLocalizations l10n, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? AppColors.mediumGray.withOpacity(0.3)
              : AppColors.neuShadowDark.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _guestLogin,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.continueAsGuest,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
