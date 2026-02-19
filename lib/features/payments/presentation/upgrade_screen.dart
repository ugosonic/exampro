import 'package:citizentest/features/admin/data/admin_repository.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:url_launcher/url_launcher.dart';
import 'package:citizentest/features/payments/presentation/payment_status_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:dio/dio.dart' show DioException;
import 'package:flutter_stripe/flutter_stripe.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});
  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  String currency = 'GBP';
  bool loading = false;

  Future<void> _pay() async {
    setState(() => loading = true);
    // Mark payment flow active, so /pay/success and /pay/cancel are accessible
    ref.read(paymentFlowActiveProvider.notifier).state = true;
    // Create a PaymentIntent via our server (PaymentSheet)
    String? clientSecret;
    try {
      final amountMinor = await _priceMinor(currency) ?? (currency == 'GBP' ? 1999 : 1999);
      final dio = ref.read(dioProvider);
      final res = await dio.post('/payments/intent', data: {
        'currency': currency,
        'amount_minor': amountMinor,
      });
      clientSecret = (res.data['client_secret'] as String?);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? ((e.response!.data['error'] ?? e.message).toString())
          : e.message ?? 'network_error';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment error: $msg')));
      }
      clientSecret = null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment error: $e')));
      }
      clientSecret = null;
    }
    if (clientSecret == null || clientSecret.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start payment')));
      }
      setState(() => loading = false);
      return;
    }
    // Init and present PaymentSheet
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Citizen Test',
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'GB', testEnv: false),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'GB'),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException {
      if (mounted) context.go('/pay/cancel');
      setState(() => loading = false);
      return;
    }

    // Success path
    if (mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final repo = ref.read(adminRepositoryProvider);
        final amountMinor = await _priceMinor(currency) ?? (currency == 'GBP' ? 1999 : 1999);
        String? piFromSecret(String s) {
          final i = s.indexOf('_secret_');
          if (i > 0) return s.substring(0, i);
          return null;
        }
        final piId = (piFromSecret(clientSecret) ?? '');
        await repo.addPayment(email: user.email, amountMinor: amountMinor, currency: currency, intentId: piId, status: 'paid');
        try {
          // Also record on server so admins can see online payment history
          final dio = ref.read(dioProvider);
          await dio.post('/payments/record', data: {
            'amount_minor': amountMinor,
            'currency': currency,
            'payment_intent_id': piId,
          });
        } catch (_) {}
        await repo.setUserPro(user.email, true);
        if (mounted) context.go('/pay/success');
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Future<int?> _priceMinor(String cur) async {
    final repo = ref.read(adminRepositoryProvider);
    final key = cur == 'GBP' ? 'price_gbp_minor' : 'price_usd_minor';
    final v = await repo.getSetting(key);
    return int.tryParse(v ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: FutureBuilder(
        future: Future.wait([_priceMinor('GBP'), _priceMinor('USD')]),
        builder: (context, snap) {
          final prices = snap.data ?? const [1999, 1999];
          final gbp = prices[0] ?? 1999;
          final usd = prices[1] ?? 1999;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Lifetime access unlocks all locked content.'),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: currency,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => currency = value);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'GBP',
                      title: Text('\u00A3${(gbp / 100).toStringAsFixed(2)} GBP'),
                    ),
                    RadioListTile<String>(
                      value: 'USD',
                      title: Text('\$${(usd / 100).toStringAsFixed(2)} USD'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: loading ? null : _pay, child: loading ? const CircularProgressIndicator() : const Text('Pay')),
              )
            ]),
          );
        },
      ),
    );
  }
}
