import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryPurple.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryPurple,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Language Selection
              ListTile(
                leading:
                    const Icon(Icons.language, color: AppColors.primaryPurple),
                title: Text(
                  l10n.language,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    locale.languageCode.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  _showLanguageDialog(context, ref, l10n);
                },
              ),

              const Divider(),

              // Account Settings
              ListTile(
                leading: const Icon(Icons.account_circle,
                    color: AppColors.primaryPurple),
                title: const Text('Account Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/account-settings');
                },
              ),

              // About (placeholder)
              ListTile(
                leading: const Icon(Icons.info_outline,
                    color: AppColors.primaryPurple),
                title: Text(l10n.about),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show about dialog
                },
              ),

              const Spacer(),

              // Version info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${l10n.version} 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final locale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: locale.languageCode,
              activeColor: AppColors.primaryPurple,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
                Navigator.pop(context); // Close drawer
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.arabic),
              value: 'ar',
              groupValue: locale.languageCode,
              activeColor: AppColors.primaryPurple,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                Navigator.pop(context);
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
