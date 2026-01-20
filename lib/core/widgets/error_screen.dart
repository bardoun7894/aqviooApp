import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../../../generated/app_localizations.dart';
import '../../../features/creation/presentation/providers/creation_provider.dart';

/// Screen displayed when a global error occurs
class ErrorScreen extends ConsumerWidget {
  final String? errorDetails;

  const ErrorScreen({super.key, this.errorDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can't rely on AppLocalizations if the error happened before localization loaded
    // So we use hardcoded fallbacks if l10n is null, or just simple english
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  l10n?.errorMessage('Oops!') ?? 'Oops! Something went wrong',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'We encountered an unexpected error.\nPlease try creating a new magic or contact support if the issue persists.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color:
                        isDark ? AppColors.mediumGray : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Restart Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Clear cached creation state to break the error loop
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('current_task_id');
                          await prefs.remove('creation_state');
                          // Reset creation provider state
                          ref.invalidate(creationControllerProvider);
                        } catch (e) {
                          debugPrint('Error clearing state: $e');
                        }
                        // Navigate to home instead of splash to avoid re-triggering init errors
                        if (context.mounted) {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'Restart App',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Support Button
                    OutlinedButton.icon(
                      onPressed: () => _launchSupportEmail(),
                      icon: Icon(
                        Icons.email_outlined,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      label: Text(
                        'Contact Support',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.neuShadowDark.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
    );
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@aqvioo.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Aqvioo App Error Report',
        'body':
            'I encountered an error in the app.\n\nError Details:\n${errorDetails ?? "Unknown Error"}\n\n'
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Could not launch support email: $e');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
