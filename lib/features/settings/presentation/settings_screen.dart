import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/app_providers.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../subscription/data/subscription_service.dart';

/// Innstillingsside — abonnement, biometrisk lås, backup, om appen.
class SettingsScreen extends ConsumerWidget {
  final SubscriptionService? subscriptionService;

  const SettingsScreen({super.key, this.subscriptionService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laererId = ref.watch(activeLaererIdProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Innstillinger'),
      ),
      body: ListView(
        children: [
          // Abonnementsstatus
          if (subscriptionService != null)
            ValueListenableBuilder<SubscriptionStatus>(
              valueListenable: subscriptionService!.status,
              builder: (context, status, _) {
                return _SubscriptionTile(
                  status: status,
                  service: subscriptionService!,
                );
              },
            ),
          const Divider(),
          if (laererId != null)
            StreamBuilder(
              stream: (db.select(db.laerere)
                    ..where((l) => l.id.equals(laererId)))
                  .watchSingle(),
              builder: (context, snapshot) {
                final laerer = snapshot.data;
                if (laerer == null) return const SizedBox.shrink();

                return SwitchListTile(
                  title: const Text('Biometrisk lås'),
                  subtitle: const Text(
                    'Krev fingeravtrykk eller ansikt ved oppstart',
                  ),
                  secondary: const Icon(Icons.fingerprint),
                  value: laerer.biometriskLaasAktiv,
                  onChanged: (value) async {
                    await (db.update(db.laerere)
                          ..where((l) => l.id.equals(laererId)))
                        .write(LaerereCompanion(
                      biometriskLaasAktiv: Value(value),
                    ));
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Backup'),
            subtitle: const Text('Sikkerhetskopi til Google Drive'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final dir = await getApplicationDocumentsDirectory();
              final dbPath = p.join(dir.path, 'fravaer.db');
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BackupScreen(dbPath: dbPath),
                  ),
                );
              }
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Om Alle med'),
            subtitle: Text('Versjon 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Personvern'),
            subtitle: Text(
              'All data lagres kryptert lokalt på din enhet. '
              'Ingen data sendes til noen server.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final SubscriptionStatus status;
  final SubscriptionService service;

  const _SubscriptionTile({required this.status, required this.service});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    final IconData icon;
    final Color iconColor;

    switch (status) {
      case SubscriptionStatus.active:
        title = 'Abonnement aktivt';
        subtitle = 'Årsabonnement — 29 kr/år';
        icon = Icons.verified;
        iconColor = Colors.green;
      case SubscriptionStatus.trial:
        title = 'Prøveperiode';
        subtitle = 'Gratis i 30 dager';
        icon = Icons.schedule;
        iconColor = Colors.orange;
      case SubscriptionStatus.expired:
        title = 'Abonnement utløpt';
        subtitle = 'Abonner for å fortsette å bruke appen';
        icon = Icons.warning;
        iconColor = Colors.red;
      case SubscriptionStatus.loading:
        title = 'Laster...';
        subtitle = '';
        icon = Icons.hourglass_empty;
        iconColor = Colors.grey;
    }

    return FutureBuilder<int>(
      future: service.trialDaysRemaining,
      builder: (context, snapshot) {
        final daysLeft = snapshot.data;
        final displaySubtitle = status == SubscriptionStatus.trial && daysLeft != null
            ? '$daysLeft dager igjen av prøveperioden'
            : subtitle;

        return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          subtitle: Text(displaySubtitle),
        );
      },
    );
  }
}
