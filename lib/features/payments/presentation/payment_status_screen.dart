import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Flag to allow navigating to payment status pages only during an active payment flow
final paymentFlowActiveProvider = StateProvider<bool>((_) => false);

class PaymentStatusScreen extends ConsumerWidget {
  final bool success;
  const PaymentStatusScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Once we've shown the screen, clear the guard so users can't deep-link here later
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final active = ref.read(paymentFlowActiveProvider);
      if (active) ref.read(paymentFlowActiveProvider.notifier).state = false;
    });
    final icon = success ? Icons.check_circle : Icons.error_outline;
    final color = success ? Colors.green : Colors.red;
    final title = success ? 'Payment Successful' : 'Payment Canceled';
    final desc = success
        ? 'Your account has been upgraded to Pro.'
        : 'Your payment was not completed.';
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 88, color: color),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(desc, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Continue'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

