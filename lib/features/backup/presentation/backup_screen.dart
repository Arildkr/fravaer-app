import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/backup_service.dart';

/// Backup-skjerm — Google Drive backup og gjenoppretting.
class BackupScreen extends ConsumerStatefulWidget {
  final String dbPath;

  const BackupScreen({super.key, required this.dbPath});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _backupService = BackupService();
  bool _loading = false;
  String? _statusMessage;
  DateTime? _lastBackup;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    setState(() => _loading = true);
    try {
      final signedIn = await _backupService.trySignInSilently();
      if (signedIn) {
        _signedIn = true;
        _lastBackup = await _backupService.getLastBackupDate();
      }
    } catch (_) {
      // Stille — bruker kan logge inn manuelt
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final ok = await _backupService.signIn();
      if (ok) {
        _signedIn = true;
        _lastBackup = await _backupService.getLastBackupDate();
        setState(() => _statusMessage = l10n.signedIn);
      } else {
        setState(() => _statusMessage = l10n.signInCancelled);
      }
    } catch (e) {
      setState(() => _statusMessage = '${l10n.signInError} $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      await _backupService.uploadBackup(widget.dbPath);
      _lastBackup = DateTime.now();
      setState(() => _statusMessage = l10n.backupDone);
    } catch (e) {
      setState(() => _statusMessage = '${l10n.backupError} $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final restoredPath = await _backupService.downloadBackup();
      if (restoredPath == null) {
        setState(() => _statusMessage = l10n.noBackupFound);
        return;
      }

      // Kopier over eksisterende database
      final restoredFile = File(restoredPath);
      await restoredFile.copy(widget.dbPath);

      setState(() => _statusMessage = l10n.restoreSuccess);
    } catch (e) {
      setState(() => _statusMessage = '${l10n.restoreError} $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backup),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              l10n.googleDriveBackup,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.backupDescription),
            const SizedBox(height: 24),
            if (_lastBackup != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.lastBackup(dateFormat.format(_lastBackup!)),
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Feil')
                      ? Colors.red
                      : Colors.green[700],
                ),
              ),
            ],
            const Spacer(),
            if (!_signedIn) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _signIn,
                  icon: const Icon(Icons.login),
                  label: Text(l10n.signInWithGoogle),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _backup,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(l10n.takeBackupNow),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _restore,
                  icon: const Icon(Icons.cloud_download),
                  label: Text(l10n.restoreFromBackup),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
