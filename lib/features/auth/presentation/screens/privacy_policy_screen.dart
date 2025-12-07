import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Background gradient orbs
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

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, l10n),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Privacy Icon
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
                          child: const Icon(
                            Icons.privacy_tip_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          l10n.privacyPolicyTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // App Name
                        Text(
                          'Aqvioo',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Privacy Policy Content
                        Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Introduction
                              _buildPolicySection(
                                icon: Icons.info_outline_rounded,
                                iconColor: const Color(0xFF06B6D4),
                                title: l10n.privacyIntro,
                                content: l10n.privacyIntroContent,
                              ),

                              _buildDivider(),

                              // Section 1: Information We Collect
                              _buildPolicySection(
                                icon: Icons.data_usage_rounded,
                                iconColor: const Color(0xFF8B5CF6),
                                title: l10n.privacySection1Title,
                                content: l10n.privacySection1Content,
                              ),

                              _buildDivider(),

                              // Section 2: Use of Information
                              _buildPolicySection(
                                icon: Icons.settings_applications_rounded,
                                iconColor: const Color(0xFF10B981),
                                title: l10n.privacySection2Title,
                                content: l10n.privacySection2Content,
                              ),

                              _buildDivider(),

                              // Section 3: Data Sharing
                              _buildPolicySection(
                                icon: Icons.share_rounded,
                                iconColor: const Color(0xFFF59E0B),
                                title: l10n.privacySection3Title,
                                content: l10n.privacySection3Content,
                              ),

                              _buildDivider(),

                              // Section 4: Data Security
                              _buildPolicySection(
                                icon: Icons.security_rounded,
                                iconColor: const Color(0xFFEF4444),
                                title: l10n.privacySection4Title,
                                content: l10n.privacySection4Content,
                              ),

                              _buildDivider(),

                              // Section 5: Payments
                              _buildPolicySection(
                                icon: Icons.payment_rounded,
                                iconColor: const Color(0xFF3B82F6),
                                title: l10n.privacySection5Title,
                                content: l10n.privacySection5Content,
                              ),

                              _buildDivider(),

                              // Section 6: User Rights
                              _buildPolicySection(
                                icon: Icons.person_outline_rounded,
                                iconColor: const Color(0xFF6366F1),
                                title: l10n.privacySection6Title,
                                content: l10n.privacySection6Content,
                              ),

                              _buildDivider(),

                              // Section 7: Policy Changes
                              _buildPolicySection(
                                icon: Icons.update_rounded,
                                iconColor: const Color(0xFF14B8A6),
                                title: l10n.privacySection7Title,
                                content: l10n.privacySection7Content,
                              ),

                              _buildDivider(),

                              // Section 8: Contact Us
                              _buildPolicySection(
                                icon: Icons.email_outlined,
                                iconColor: const Color(0xFFEC4899),
                                title: l10n.privacySection8Title,
                                content: l10n.privacySection8Content,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
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
                  l10n.settings.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ).copyWith(height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.privacyPolicy,
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

  Widget _buildPolicySection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 48),
          child: Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.lightGray,
      ),
    );
  }
}
