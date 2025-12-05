import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../services/payment/tabby_service.dart';
import '../../../../services/payment/transaction_service.dart';

// Credit packages
class CreditPackage {
  final int credits;
  final double price;
  final String? badge;
  final bool isPopular;

  const CreditPackage({
    required this.credits,
    required this.price,
    this.badge,
    this.isPopular = false,
  });
}

const List<CreditPackage> creditPackages = [
  CreditPackage(credits: 50, price: 99.0),
  CreditPackage(credits: 100, price: 179.0, isPopular: true, badge: 'Popular'),
  CreditPackage(credits: 200, price: 299.0, badge: 'Best Value'),
  CreditPackage(credits: 500, price: 599.0),
];

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;

  const PaymentScreen({super.key, this.amount = 199.0});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPackageIndex = 1; // Default to popular package
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final creditsState = ref.watch(creditsControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          l10n.buyCredits,
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Current Balance
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple,
                  const Color(0xFF9D6BFF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentBalance,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.creditBalance(creditsState.credits),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          // Credit Packages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: creditPackages.length,
              itemBuilder: (context, index) {
                final package = creditPackages[index];
                final isSelected = _selectedPackageIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPackageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Radio indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Package info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${package.credits} Credits',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (package.badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: package.isPopular
                                            ? AppColors.primaryPurple
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        package.badge == 'Popular'
                                            ? l10n.popularBadge
                                            : l10n.bestValueBadge,
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.videosOrImages(
                                  (package.credits / 10).toStringAsFixed(0),
                                  (package.credits / 5).toStringAsFixed(0),
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          '${package.price.toStringAsFixed(0)} SAR',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Purchase Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.payWithTabby} - ${creditPackages[_selectedPackageIndex].price.toStringAsFixed(0)} SAR',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.securePaymentTabby,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _isProcessing = true;
    });
    final l10n = AppLocalizations.of(context)!;

    try {
      final package = creditPackages[_selectedPackageIndex];

      // Show Tabby payment info dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3ECDCC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.payWithTabby,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tabbyInstallments,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.total,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${package.price.toStringAsFixed(0)} SAR',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.paymentsOf,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(package.price / 4).toStringAsFixed(2)} SAR',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF3ECDCC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tabbyBenefits,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3ECDCC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.continueToTabby,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldProceed != true) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get user information
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get Tabby configuration from environment
      final merchantCode = dotenv.env['TABBY_MERCHANT_CODE'] ?? 'sa';
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // Create transaction record in Firestore (pending status)
      final transactionId = await TransactionService().createTransaction(
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? 'N/A',
        amount: package.price,
        currency: 'SAR',
        credits: package.credits,
        orderId: orderId,
        paymentMethod: 'Tabby',
        metadata: {
          'packageCredits': package.credits,
          'packagePrice': package.price,
        },
      );

      // Create Tabby checkout session
      final session = await TabbyService().createCheckoutSession(
        merchantCode: merchantCode,
        amount: package.price,
        currency: 'SAR',
        userEmail: user.email ?? 'user@aqvioo.com',
        userPhone: user.phoneNumber ?? '+966500000001',
        userName: user.displayName ?? 'User',
        credits: package.credits,
        orderId: orderId,
      );

      if (!mounted) return;

      if (session == null) {
        throw Exception('Failed to create Tabby session');
      }

      // Session status check removed - SDK version doesn't support it
      // Payment will fail gracefully in the WebView if rejected

      // Open Tabby WebView for payment
      if (!mounted) return;
      TabbyWebView.showWebView(
        context: context,
        webUrl: session.availableProducts.installments?.webUrl ?? '',
        onResult: (WebViewResult resultCode) async {
          switch (resultCode) {
            case WebViewResult.authorized:
              // Update transaction status to authorized/completed
              await TransactionService().updateTransactionStatus(
                transactionId: transactionId,
                status: TransactionStatus.authorized,
              );

              // Payment authorized - add credits
              await ref
                  .read(creditsControllerProvider.notifier)
                  .addCredits(package.credits);

              if (!mounted) return;
              _showSuccessDialog(package);
              break;

            case WebViewResult.rejected:
              // Update transaction status to failed
              await TransactionService().updateTransactionStatus(
                transactionId: transactionId,
                status: TransactionStatus.failed,
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.paymentFailedMessage),
                  backgroundColor: Colors.red,
                ),
              );
              break;

            case WebViewResult.expired:
              // Update transaction status to failed
              await TransactionService().updateTransactionStatus(
                transactionId: transactionId,
                status: TransactionStatus.failed,
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.paymentFailedMessage),
                  backgroundColor: Colors.orange,
                ),
              );
              break;

            case WebViewResult.close:
              // User closed the checkout - leave as pending
              break;
          }

          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.paymentFailedTitle,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.paymentFailedMessage,
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.outfit(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(CreditPackage package) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.paymentSuccessTitle,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.creditsAdded(package.credits),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    color: Color(0xFF3ECDCC),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.firstPayment((package.price / 4).toStringAsFixed(2)),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(); // Close payment screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.startCreatingButton,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
