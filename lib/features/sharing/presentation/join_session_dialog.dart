import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/providers/app_providers.dart';
import '../../attendance/presentation/session_screen.dart';
import '../data/session_sharing_service.dart';
import '../sharing_providers.dart';
import 'sharing_consent_dialog.dart';

/// Viser join-dialog og navigerer til SessionScreen ved suksess.
Future<void> showJoinSessionDialog(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<JoinedSessionResult>(
    context: context,
    builder: (_) => const JoinSessionDialog(),
  );
  if (result == null || !context.mounted) return;

  final db = ref.read(databaseProvider);
  final session = await (db.select(db.fravaersOkter)
        ..where((s) => s.id.equals(result.localSessionId)))
      .getSingleOrNull();
  final group = await (db.select(db.grupper)
        ..where((g) => g.id.equals(result.localGroupId)))
      .getSingleOrNull();

  if (session == null || group == null || !context.mounted) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => SessionScreen(session: session, group: group),
    ),
  );
}

/// Dialog for medlærer som vil bli med i en aktiv delt økt.
class JoinSessionDialog extends ConsumerStatefulWidget {
  const JoinSessionDialog({super.key});

  @override
  ConsumerState<JoinSessionDialog> createState() => _JoinSessionDialogState();
}

class _JoinSessionDialogState extends ConsumerState<JoinSessionDialog> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeController.text.replaceAll('-', '').trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = l10n.invalidCode);
      return;
    }

    // Vis samtykke-dialog før vi kontakter Firebase
    final consent = await showSharingConsentDialog(context);
    if (!consent || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ref.read(sessionSharingServiceProvider);
      final info = await service.lookupCode(code);

      if (!mounted) return;

      if (info == null) {
        setState(() {
          _loading = false;
          _error = l10n.codeNotFound;
        });
        return;
      }

      // Vis bekreftelse
      final confirmed = await _showConfirmation(context, l10n, info);
      if (!mounted || confirmed != true) {
        setState(() => _loading = false);
        return;
      }

      final laererId = ref.read(activeLaererIdProvider);
      if (laererId == null) {
        setState(() {
          _loading = false;
          _error = 'Ingen aktiv lærer';
        });
        return;
      }

      final result = await service.joinSession(
        shareId: info['shareId'] as String,
        laererId: laererId,
      );

      // Start lytter
      service.startListening(shareId: info['shareId'] as String);

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = l10n.sharingError;
        });
      }
    }
  }

  Future<bool?> _showConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> info,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.joinSessionTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.joinSessionConfirmGroup(info['groupName'] as String)),
            const SizedBox(height: 4),
            Text(
              l10n.joinSessionStudentCount(info['studentCount'] as int),
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.joinSessionGroupKept,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.joinSessionAccept),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.joinSessionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.joinSessionCodeHint),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 4),
            maxLength: 7, // 6 tegn + mulig bindestrek
            decoration: InputDecoration(
              hintText: 'ABC-123',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _lookup(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _lookup,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.next),
        ),
      ],
    );
  }
}
