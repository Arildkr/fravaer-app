import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';

/// Vises HVER GANG brukeren starter eller blir med i en delt økt.
/// Informerer om personvern, anbefaler fornavn og tydeliggjør eget ansvar.
Future<bool> showSharingConsentDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.cloud_upload_outlined, size: 36),
      title: Text(l10n.sharingConsentTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.sharingConsentBody),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.sharingFirstNamesHint,
                      style: TextStyle(
                          fontSize: 13, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.sharingResponsibility,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.cloud_upload, size: 18),
          label: Text(l10n.sharingConsentAccept),
        ),
      ],
    ),
  );
  return result == true;
}
