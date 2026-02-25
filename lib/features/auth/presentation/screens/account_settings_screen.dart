import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/auth/providers/admin_auth_provider.dart';
import '../../../../generated/app_localizations.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;
  String _initialName = '';
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _initialName = user.displayName ?? '';
      _nameController.text = _initialName;

      // Fallback 1: Extract from dummy email if applicable
      String phoneBase = '';
      if (user.email != null && user.email!.endsWith('@phone.aqvioo.com')) {
        phoneBase = user.email!.split('@').first;
      } else {
        phoneBase = user.phoneNumber ?? '';
      }
      _initialPhone = phoneBase;
      _phoneController.text = phoneBase;

      // Final Source of Truth: Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted && userDoc.exists) {
          final data = userDoc.data();
          final firestorePhone = data?['phoneNumber'] as String?;
          if (firestorePhone != null && firestorePhone.isNotEmpty) {
            _initialPhone = firestorePhone;
            _phoneController.text = firestorePhone;
          }
          final firestoreName = data?['displayName'] as String?;
          if (firestoreName != null && firestoreName.isNotEmpty) {
            _initialName = firestoreName;
            _nameController.text = firestoreName;
          }
        }
      } catch (e) {
        debugPrint('⚠️ AccountSettings: Error loading Firestore data: $e');
      }
    }

    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasNameChanged = _nameController.text.trim() != _initialName;
    final hasPhoneChanged = _phoneController.text.trim() != _initialPhone;

    if (_hasChanges != (hasNameChanged || hasPhoneChanged)) {
      setState(() {
        _hasChanges = hasNameChanged || hasPhoneChanged;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_hasChanges || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newName = _nameController.text.trim();
        final newPhone = _phoneController.text.trim();

        // 1. Update Firebase Auth Profile
        await user.updateDisplayName(newName);

        // 2. Update Firestore Document (Primary source for phone)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': newName,
          'phoneNumber': newPhone,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update local baseline
        _initialName = newName;
        _initialPhone = newPhone;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.profileUpdatedSuccess,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(12),
            ),
          );
          setState(() => _hasChanges = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.profileUpdateFailed,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Background gradient orbs - responsive for iPad
          Positioned(
            top: -100,
            left: -100,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size =
                    MediaQuery.of(context).size.width > 600 ? 600.0 : 400.0;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size =
                    MediaQuery.of(context).size.width > 600 ? 450.0 : 300.0;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6B9DFF).withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Settings content
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Profile Card
                            // Profile Card
                            _buildProfileCard(context, user),

                            const SizedBox(height: 24),

                            // Settings Section
                            _buildSettingsSection(context, ref),

                            const SizedBox(height: 24),

                            // Danger Zone
                            _buildDangerZone(context, ref),

                            if (kDebugMode) ...[
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _buildSettingsTile(
                                  icon: Icons.bug_report_rounded,
                                  title: 'Simulate Crash (Debug)',
                                  subtitle: 'Throw test exception',
                                  iconColor: Colors.purple,
                                  onTap: () {
                                    throw Exception(
                                        'Manual Test Crash from AccountSettings');
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button - Fixed at bottom
          if (_hasChanges)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSaveButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
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
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settings.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ).copyWith(height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.accountSettingsTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ).copyWith(height: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, User? user) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: user?.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          user!.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
              ),
              // Camera button removed - profile picture editing not supported
            ],
          ),

          const SizedBox(height: 16),

          // Email display
          if (user?.email != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user!.email!,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Name Input
          _buildInputField(
            controller: _nameController,
            label: l10n.fullName,
            hint: l10n.enterName,
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 16),

          // Phone Input
          _buildInputField(
            controller: _phoneController,
            label: l10n.phoneNumber,
            hint: '+966 5XX XXX XXXX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.neuShadowDark.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    // Safely watch admin auth provider with error handling for iPad compatibility
    bool isAdmin = false;
    try {
      final adminAuthState = ref.watch(adminAuthControllerProvider);
      isAdmin = adminAuthState.isAuthenticated;
    } catch (e) {
      debugPrint('⚠️ Settings: Error watching adminAuthControllerProvider: $e');
    }

    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin Dashboard Switch - Only show for admin users
          if (isAdmin) ...[
            _buildSettingsTile(
              icon: Icons.admin_panel_settings_rounded,
              title: l10n.adminDashboard,
              subtitle: 'Switch to admin view',
              iconColor: const Color(0xFF8B5CF6),
              onTap: () {
                context.go('/admin/dashboard');
              },
            ),
            _buildDivider(),
          ],
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: l10n.language,
            subtitle: isArabic ? l10n.arabic : l10n.english,
            iconColor: AppColors.primaryPurple,
            onTap: () => _showLanguageDialog(context, ref, l10n, locale),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: 'Enabled',
            iconColor: const Color(0xFFF59E0B),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            iconColor: const Color(0xFF06B6D4),
            onTap: () => context.push('/privacy-policy'),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: l10n.helpSupport,
            iconColor: const Color(0xFF10B981),
            onTap: () => context.push('/support'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.selectLanguage,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: l10n.english,
              subtitle: 'English',
              languageCode: 'en',
              isSelected: currentLocale.languageCode == 'en',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: l10n.arabic,
              subtitle: 'العربية',
              languageCode: 'ar',
              isSelected: currentLocale.languageCode == 'ar',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withOpacity(0.1)
                : AppColors.lightGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primaryPurple, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.logout,
            iconColor: Colors.orange,
            titleColor: Colors.orange,
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    l10n.logoutConfirmationTitle,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                  content: Text(
                    l10n.logoutConfirmationMessage,
                    style: GoogleFonts.outfit(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        l10n.logout,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.deleteAccountTitle,
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    l10n.deleteAccountTitle,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700, color: Colors.red),
                  ),
                  content: Text(
                    l10n.deleteAccountMessage,
                    style: GoogleFonts.outfit(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        l10n.delete,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.lightGray,
      indent: 60,
      endIndent: 16,
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSaving ? null : _saveProfile,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _isSaving ? null : AppColors.primaryGradient,
                  color: _isSaving ? AppColors.lightGray : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isSaving
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.saveChanges,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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
}
