import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';

/// Biometrisk låseskjerm — obligatorisk ved oppstart.
/// På web hoppes biometri over (for testing).
class LockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LockScreen({super.key, required this.onAuthenticated});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Vent til etter første frame for å unngå setState under build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (kIsWeb) {
      widget.onAuthenticated();
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      final canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuth) {
        widget.onAuthenticated();
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: l10n.biometricReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        widget.onAuthenticated();
      } else {
        setState(() => _error = l10n.authFailed);
      }
    } catch (_) {
      // Biometri/PIN ikke konfigurert eller ikke tilgjengelig — slipp gjennom
      widget.onAuthenticated();
      return;
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Alle med',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authenticateToOpen,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              if (!_isAuthenticating)
                FilledButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockApp),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 56),
                  ),
                ),
              if (_isAuthenticating)
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
