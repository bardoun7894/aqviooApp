import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/credits_provider.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../services/payment/tap_payment_service.dart';
import '../../../../services/payment/transaction_service.dart';

// Balance packages in SAR
class BalancePackage {
  final double amount;  // SAR to add to balance
  final double price;   // Price in SAR
  final String? badge;
  final bool isPopular;
  final int videosCount;  // How many videos this can generate
  final int imagesCount;  // How many images this can generate

  const BalancePackage({
    required this.amount,
    required this.price,
    this.badge,
    this.isPopular = false,
    required this.videosCount,
    required this.imagesCount,
  });
}

// Video: 2.99 SAR, Image: 1.99 SAR
const List<BalancePackage> balancePackages = [
  BalancePackage(amount: 15, price: 15.0, videosCount: 5, imagesCount: 7),
  BalancePackage(amount: 30, price: 30.0, isPopular: true, badge: 'Popular', videosCount: 10, imagesCount: 15),
  BalancePackage(amount: 50, price: 50.0, badge: 'Best Value', videosCount: 16, imagesCount: 25),
  BalancePackage(amount: 100, price: 100.0, videosCount: 33, imagesCount: 50),
];

// Legacy alias for backward compatibility
typedef CreditPackage = BalancePackage;
const List<BalancePackage> creditPackages = balancePackages;

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
                      '${creditsState.balance.toStringAsFixed(2)} ${Pricing.currency}',
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
                                    '${package.amount.toStringAsFixed(0)} ${Pricing.currency}',
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
                                  '${package.videosCount}',
                                  '${package.imagesCount}',
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
                          '${package.price.toStringAsFixed(0)} ${Pricing.currency}',
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
                        backgroundColor: const Color(0xFF2ACE82), // Tap green color
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
                                const Icon(Icons.credit_card, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.payWithTap} - ${creditPackages[_selectedPackageIndex].price.toStringAsFixed(0)} SAR',
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
                        l10n.securePaymentTap,
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

      // Show Tap payment info dialog
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
                  color: const Color(0xFF2ACE82),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.payWithTap,
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
                l10n.tapPaymentInfo,
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
                          l10n.balanceToAdd,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${package.amount.toStringAsFixed(0)} ${Pricing.currency}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF2ACE82),
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
                l10n.tapPaymentMethods,
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
                backgroundColor: const Color(0xFF2ACE82),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.continueToPayment,
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

      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // Create transaction record in Firestore (pending status)
      final transactionId = await TransactionService().createTransaction(
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? 'N/A',
        amount: package.price,
        currency: 'SAR',
        credits: package.amount.toInt(),  // Store balance amount as credits for compatibility
        orderId: orderId,
        paymentMethod: 'Tap',
        metadata: {
          'balanceAmount': package.amount,
          'packagePrice': package.price,
          'videosCount': package.videosCount,
          'imagesCount': package.imagesCount,
        },
      );

      // Get user name parts
      final nameParts = (user.displayName ?? 'User').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Configure SDK with current language
      final lang = Localizations.localeOf(context).languageCode;
      TapPaymentService().configureApp(lang: lang);

      // Start Tap Payment (Official SDK)
      final result = await TapPaymentService().startPayment(
        amount: package.price,
        currency: 'SAR',
        customerEmail: user.email ?? 'user@aqvioo.com',
        customerPhone: user.phoneNumber ?? '+966500000001',
        customerFirstName: firstName,
        customerLastName: lastName,
        orderId: orderId,
        itemName: '${package.amount.toStringAsFixed(0)} SAR Balance',
        itemDescription: 'Aqvioo AI Video/Image Generation Balance',
      );

      // Parse result
      final paymentResult = TapPaymentService().parseResult(result);

      if (!mounted) return;

      if (paymentResult.success) {
        // Update transaction status to completed
        await TransactionService().updateTransactionStatus(
          transactionId: transactionId,
          status: TransactionStatus.authorized,
        );

        // Add balance in SAR
        await ref
            .read(creditsControllerProvider.notifier)
            .addBalance(package.amount);

        if (!mounted) return;
        _showSuccessDialog(package);
      } else {
        // Update transaction status to failed
        await TransactionService().updateTransactionStatus(
          transactionId: transactionId,
          status: TransactionStatus.failed,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentResult.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Tap Payment Error: $e');
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
              '${package.amount.toStringAsFixed(0)} ${Pricing.currency} ${l10n.addedToBalance}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
