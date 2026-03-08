import 'package:flutter/material.dart';

import '../data/subscription_service.dart';

/// Paywall — vises når prøveperioden er utløpt.
class PaywallScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;
  final VoidCallback onSubscribed;

  const PaywallScreen({
    super.key,
    required this.subscriptionService,
    required this.onSubscribed,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _subscribe() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final started = await widget.subscriptionService.purchase();
      if (!started) {
        setState(() => _error = 'Kunne ikke starte kjøp. Prøv igjen senere.');
      }
    } catch (e) {
      setState(() => _error = 'Noe gikk galt: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.subscriptionService.restore();
      // Vent litt på at purchaseStream oppdaterer status
      await Future.delayed(const Duration(seconds: 2));
      if (widget.subscriptionService.status.value ==
          SubscriptionStatus.active) {
        widget.onSubscribed();
      } else {
        setState(
            () => _error = 'Ingen tidligere abonnement funnet.');
      }
    } catch (e) {
      setState(() => _error = 'Kunne ikke gjenopprette: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Alle med',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Prøveperioden er utløpt',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Årsabonnement',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '29 kr / år',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 16),
                    _Feature(text: 'Ubegrenset antall grupper og elever'),
                    _Feature(text: 'Klasseroms- og turmodus'),
                    _Feature(text: 'Rapporter og eksport'),
                    _Feature(text: 'Kryptert lokal lagring'),
                    _Feature(text: 'Biometrisk lås'),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _subscribe,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Abonner — 29 kr/år',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _restore,
                child: const Text('Gjenopprett tidligere kjøp'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String text;
  const _Feature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
