import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../auth/providers/admin_auth_provider.dart';
import '../../dashboard/screens/admin_scaffold.dart';

/// Admin Settings Screen - Manage API keys and app configuration
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for API key fields
  final _kieApiKeyController = TextEditingController();
  final _openaiApiKeyController = TextEditingController();
  final _tapSecretKeyController = TextEditingController();
  final _tapPublicKeyController = TextEditingController();
  final _tapMerchantIdController = TextEditingController();

  bool _tapTestMode = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Toggle visibility for each key
  bool _showKieKey = false;
  bool _showOpenaiKey = false;
  bool _showTapSecretKey = false;
  bool _showTapPublicKey = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentKeys();
  }

  @override
  void dispose() {
    _kieApiKeyController.dispose();
    _openaiApiKeyController.dispose();
    _tapSecretKeyController.dispose();
    _tapPublicKeyController.dispose();
    _tapMerchantIdController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentKeys() async {
    setState(() => _isLoading = true);
    try {
      final config = RemoteConfigService();
      // Reload from Firestore to get latest
      await config.reload();

      _kieApiKeyController.text = config.kieApiKey;
      _openaiApiKeyController.text = config.openaiApiKey;
      _tapSecretKeyController.text = config.tapSecretKey;
      _tapPublicKeyController.text = config.tapPublicKey;
      _tapMerchantIdController.text = config.tapMerchantId;
      _tapTestMode = config.tapTestMode;
    } catch (e) {
      debugPrint('Error loading keys: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveKeys() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final config = RemoteConfigService();
      await config.saveKeys(
        kieApiKey: _kieApiKeyController.text.trim(),
        openaiApiKey: _openaiApiKeyController.text.trim(),
        tapSecretKey: _tapSecretKeyController.text.trim(),
        tapPublicKey: _tapPublicKeyController.text.trim(),
        tapMerchantId: _tapMerchantIdController.text.trim(),
        tapTestMode: _tapTestMode,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'API keys saved successfully. Changes take effect on next app restart.',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving keys: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving keys: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminAuthControllerProvider);
    final canConfigure =
        adminState.adminUser?.permissions.canConfigureSettings ?? false;

    return AdminScaffold(
      currentRoute: '/admin/settings',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !canConfigure
              ? _buildNoPermission()
              : _buildSettingsForm(),
    );
  }

  Widget _buildNoPermission() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Access Denied',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You do not have permission to configure settings.\nOnly Super Admins can manage API keys.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage API keys and app configuration',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // AI Services Section
            _buildSectionHeader(
              'AI Services',
              Icons.auto_awesome_rounded,
              'API keys for content generation services',
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              label: 'Kie AI API Key',
              controller: _kieApiKeyController,
              hint: 'Enter Kie AI API key for video/image generation',
              isVisible: _showKieKey,
              onToggleVisibility: () =>
                  setState(() => _showKieKey = !_showKieKey),
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              label: 'OpenAI API Key',
              controller: _openaiApiKeyController,
              hint: 'Enter OpenAI API key for prompt enhancement',
              isVisible: _showOpenaiKey,
              onToggleVisibility: () =>
                  setState(() => _showOpenaiKey = !_showOpenaiKey),
            ),
            const SizedBox(height: 32),

            // Payment Services Section
            _buildSectionHeader(
              'Payment Services',
              Icons.payment_rounded,
              'Tap Payments gateway configuration (Android/Web)',
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              label: 'Tap Secret Key',
              controller: _tapSecretKeyController,
              hint: 'sk_live_... or sk_test_...',
              isVisible: _showTapSecretKey,
              onToggleVisibility: () =>
                  setState(() => _showTapSecretKey = !_showTapSecretKey),
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              label: 'Tap Public Key',
              controller: _tapPublicKeyController,
              hint: 'pk_live_... or pk_test_...',
              isVisible: _showTapPublicKey,
              onToggleVisibility: () =>
                  setState(() => _showTapPublicKey = !_showTapPublicKey),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Tap Merchant ID',
              controller: _tapMerchantIdController,
              hint: 'Enter merchant ID',
            ),
            const SizedBox(height: 16),
            _buildToggle(
              label: 'Tap Test Mode',
              description:
                  'Enable to use sandbox/test keys. Disable for production.',
              value: _tapTestMode,
              onChanged: (val) => setState(() => _tapTestMode = val),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveKeys,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Configuration',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Changes to API keys take effect immediately for new requests. '
                      'Users currently generating content will continue with the previous keys until their request completes.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildApiKeyField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: GoogleFonts.sourceCodePro(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.sourceCodePro(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryPurple, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryPurple;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}
