import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
    setState(() => _loading = true);
    try {
      final ok = await _backupService.signIn();
      if (ok) {
        _signedIn = true;
        _lastBackup = await _backupService.getLastBackupDate();
        setState(() => _statusMessage = 'Logget inn');
      } else {
        setState(() => _statusMessage = 'Innlogging avbrutt');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Feil ved innlogging: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _backup() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      await _backupService.uploadBackup(widget.dbPath);
      _lastBackup = DateTime.now();
      setState(() => _statusMessage = 'Backup fullført');
    } catch (e) {
      setState(() => _statusMessage = 'Feil ved backup: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gjenopprett fra backup?'),
        content: const Text(
          'All nåværende data erstattes med dataen fra backup. '
          'Appen vil starte på nytt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Gjenopprett'),
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
        setState(() => _statusMessage = 'Ingen backup funnet på Google Drive');
        return;
      }

      // Kopier over eksisterende database
      final restoredFile = File(restoredPath);
      await restoredFile.copy(widget.dbPath);

      setState(() =>
          _statusMessage = 'Gjenopprettet. Start appen på nytt for å ta i bruk.');
    } catch (e) {
      setState(() => _statusMessage = 'Feil ved gjenoppretting: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'nb');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Google Drive Backup',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lagre en kryptert kopi av databasen din på Google Drive. '
              'Kun du har tilgang til backupen.',
            ),
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
                        'Siste backup: ${dateFormat.format(_lastBackup!)}',
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
                  label: const Text('Logg inn med Google'),
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
                  label: const Text('Ta backup nå'),
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
                  label: const Text('Gjenopprett fra backup'),
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
