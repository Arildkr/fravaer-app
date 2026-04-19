import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';

/// Vises når eier har delt en økt.
/// Viser invitasjonskoden og lar eieren stoppe delingen.
class ShareSessionDialog extends StatelessWidget {
  final String inviteCode;
  final VoidCallback onStopSharing;

  const ShareSessionDialog({
    super.key,
    required this.inviteCode,
    required this.onStopSharing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedCode =
        '${inviteCode.substring(0, 3)}-${inviteCode.substring(3)}';

    return AlertDialog(
      title: Text(l10n.shareSessionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.shareSessionInstructions),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _copyCode(context, l10n, formattedCode),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedCode,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.copy,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToCopy,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onStopSharing();
          },
          icon: const Icon(Icons.cloud_off, size: 18),
          label: Text(l10n.stopSharing),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  void _copyCode(BuildContext context, AppLocalizations l10n, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.codeCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
