import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA882F7).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF82C8F7).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                        color: const Color(0xFF18181B),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18181B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Settings card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Profile Picture
                                const SizedBox(height: 16),
                                Stack(
                                  children: [
                                    Container(
                                      width: 112,
                                      height: 112,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const CircleAvatar(
                                        radius: 56,
                                        backgroundColor: Color(0xFFA855F7),
                                        child: Icon(
                                          Icons.person,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Color(0xFF18181B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Name Input
                                _buildInputField(
                                  label: 'Full Name',
                                  hint: 'Enter your name',
                                ),

                                const SizedBox(height: 20),

                                // Phone Input
                                _buildInputField(
                                  label: 'Phone Number',
                                  hint: '+1 (555) 123-4567',
                                  keyboardType: TextInputType.phone,
                                ),

                                const SizedBox(height: 32),

                                // Settings Tiles
                                _buildSettingsTile(
                                  icon: Icons.language,
                                  title: 'Language',
                                  iconColor: const Color(0xFFA855F7),
                                ),

                                const SizedBox(height: 12),

                                _buildSettingsTile(
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Privacy',
                                  iconColor: const Color(0xFFA855F7),
                                ),

                                const SizedBox(height: 12),

                                _buildSettingsTile(
                                  icon: Icons.delete_forever,
                                  title: 'Delete Account',
                                  iconColor: Colors.red,
                                  titleColor: Colors.red,
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Save Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _IridescentSaveButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF71717A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                keyboardType: keyboardType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF18181B),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: const Color(0xFF71717A).withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    Color? titleColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? const Color(0xFF18181B),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: const Color(0xFF71717A).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IridescentSaveButton extends StatefulWidget {
  @override
  State<_IridescentSaveButton> createState() => _IridescentSaveButtonState();
}

class _IridescentSaveButtonState extends State<_IridescentSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7)
                    .withOpacity(0.3 + (_controller.value * 0.1)),
                blurRadius: 30 + (_controller.value * 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(32),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD9C7FF),
                      const Color(0xFFC2EAFF),
                      const Color(0xFFFFDAEC),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: const Icon(
                        Icons.check,
                        size: 32,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
