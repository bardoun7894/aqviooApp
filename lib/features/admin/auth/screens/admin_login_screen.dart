import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/admin_auth_provider.dart';

/// Admin Login Screen - Matches mobile app's design theme
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your admin email', isError: true);
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password', isError: true);
      return;
    }

    ref.read(adminAuthControllerProvider.notifier).signInWithEmailPassword(
          email: email,
          password: password,
        );
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
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
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
    final authState = ref.watch(adminAuthControllerProvider);
    final isLoading = authState.isLoading;

    // Listen for auth state changes
    ref.listen(adminAuthControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showSnackBar(next.errorMessage!, isError: true);
      } else if (next.isAuthenticated && next.adminUser != null) {
        context.go('/admin/dashboard');
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 40),
                      _buildLoginCard(isDark, isLoading),
                      const SizedBox(height: 24),
                      _buildFooter(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Admin Logo with gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Admin Dashboard',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.white : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'Sign in to manage Aqvioo',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark, bool isLoading) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Input
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hintText: 'Admin Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),

          const SizedBox(height: 16),

          // Password Input
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            onSubmitted: (_) => _handleSignIn(),
          ),

          const SizedBox(height: 16),

          // Remember Me
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                  activeColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Remember me',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.mediumGray : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sign In Button
          _buildButton(
            label: 'Sign In',
            icon: Icons.arrow_forward,
            onPressed: isLoading ? null : _handleSignIn,
            isLoading: isLoading,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Forgot Password
          Center(
            child: TextButton(
              onPressed: () {
                _showSnackBar('Password reset feature coming soon!');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
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

  Widget _buildButton({
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
          height: 54,
          decoration: BoxDecoration(
            gradient: isDisabled ? null : AppColors.primaryGradient,
            color: isDisabled
                ? (isDark ? AppColors.darkGray : AppColors.lightGray)
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? (isDark ? Colors.white24 : Colors.black26)
                              : Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: isDisabled
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        // Security Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security_rounded,
              size: 16,
              color: isDark ? AppColors.mediumGray : AppColors.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              'Secure Admin Access',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? AppColors.mediumGray : AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Version
        Text(
          'Aqvioo Admin v1.0.0',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: isDark ? AppColors.mediumGray : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
