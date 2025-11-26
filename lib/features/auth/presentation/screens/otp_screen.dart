import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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
                    const Color(0xFFA882F7).withOpacity(0.3),
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
                    const Color(0xFF82C8F7).withOpacity(0.3),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Welcome text
                            const Text(
                              'Welcome to Aqvioo',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF18181B),
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to unlock your creative potential',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF71717A).withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 48),

                            // Login Card
                            _AmbientLightCard(
                              child: Column(
                                children: [
                                  // Phone Number Input
                                  _buildGlassInput(
                                    controller: _phoneController,
                                    icon: Icons.call,
                                    hint: 'Your phone number',
                                    keyboardType: TextInputType.phone,
                                  ),

                                  const SizedBox(height: 24),

                                  // OTP Code Input
                                  _buildGlassInput(
                                    controller: _otpController,
                                    icon: Icons.dialpad,
                                    hint: 'OTP Code',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Submit Button
                            _SubmitOrb(
                              onPressed: () {
                                // TODO: Implement OTP verification
                                context.go('/home');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Continue as Guest Button
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/home'),
                            borderRadius: BorderRadius.circular(24),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF52525B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                child: Icon(
                  icon,
                  color: const Color(0xFF71717A),
                  size: 24,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF18181B),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: const Color(0xFF71717A).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientLightCard extends StatelessWidget {
  final Widget child;

  const _AmbientLightCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 448),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
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
          child: Stack(
            children: [
              // Ambient light effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: RadialGradient(
                      center: const Alignment(0.2, 0.2),
                      radius: 1.5,
                      colors: [
                        const Color(0xFFA855F7).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: RadialGradient(
                      center: const Alignment(0.8, 0.7),
                      radius: 1.5,
                      colors: [
                        const Color(0xFF60A5FA).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(32),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitOrb extends StatefulWidget {
  final VoidCallback onPressed;

  const _SubmitOrb({required this.onPressed});

  @override
  State<_SubmitOrb> createState() => _SubmitOrbState();
}

class _SubmitOrbState extends State<_SubmitOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3BED)
                    .withOpacity(0.25 + (_controller.value * 0.1)),
                blurRadius: 40 + (_controller.value * 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4C5F9),
                      Color(0xFFC2EAFF),
                      Color(0xFFFFDAEC),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 36,
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
