import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class PaymentScreen extends ConsumerWidget {
  final double amount;

  const PaymentScreen({super.key, this.amount = 199.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Spacer to push content to bottom
              const Spacer(),

              // Glassmorphic Payment Card
              Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with Close Button
                          Row(
                            children: [
                              const SizedBox(width: 32), // Spacer
                              Expanded(
                                child: Text(
                                  'Complete Your Payment',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF101828),
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(
                                    0.05,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Price Display
                          Column(
                            children: [
                              Text(
                                'Total Amount',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFF475467)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${amount.toStringAsFixed(0)} SAR',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: const Color(0xFF101828),
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Payment Options
                          _buildPaymentOption(
                            context: context,
                            icon: Icons.shopping_bag_outlined,
                            label: 'Pay with Tabby',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            context: context,
                            icon: Icons.apple,
                            label: 'Pay with Apple Pay',
                            backgroundColor: Colors.black,
                            iconColor: Colors.white,
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            context: context,
                            icon: Icons.account_balance_wallet,
                            label: 'Pay with STC Pay',
                            backgroundColor: const Color(0xFF3A2F71),
                            iconColor: Colors.white,
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            context: context,
                            icon: Icons.credit_card,
                            label: 'Pay with Card',
                            onTap: () {},
                          ),

                          const SizedBox(height: 24),

                          // Pay Now Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle payment
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.primaryPurple
                                    .withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Security Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: const Color(0xFF475467),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Secure payment powered by Stripe',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF475467),
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: backgroundColor == null
                    ? Border.all(color: const Color(0xFFE5E7EB))
                    : null,
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF101828),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
