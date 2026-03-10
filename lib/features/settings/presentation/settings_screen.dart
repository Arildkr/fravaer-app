import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final laererId = ref.watch(activeLaererIdProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                  title: Text(l10n.biometricLock),
                  subtitle: Text(l10n.biometricLockSubtitle),
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
            title: Text(l10n.backup),
            subtitle: Text(l10n.backupSubtitle),
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
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final versionText = snapshot.data != null
                  ? l10n.versionLabel(snapshot.data!.version)
                  : l10n.loadingVersion;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutApp),
                subtitle: Text(versionText),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.privacyTitle),
            subtitle: Text(l10n.privacySubtitle),
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
    final l10n = AppLocalizations.of(context)!;

    final String title;
    final String subtitle;
    final IconData icon;
    final Color iconColor;

    switch (status) {
      case SubscriptionStatus.active:
        title = l10n.subscriptionActive;
        subtitle = l10n.subscriptionActiveSubtitle;
        icon = Icons.verified;
        iconColor = Colors.green;
      case SubscriptionStatus.trial:
        title = l10n.trialStatus;
        subtitle = l10n.trialFree;
        icon = Icons.schedule;
        iconColor = Colors.orange;
      case SubscriptionStatus.expired:
        title = l10n.subscriptionExpired;
        subtitle = l10n.subscriptionExpiredSubtitle;
        icon = Icons.warning;
        iconColor = Colors.red;
      case SubscriptionStatus.loading:
        title = l10n.loadingStatus;
        subtitle = '';
        icon = Icons.hourglass_empty;
        iconColor = Colors.grey;
    }

    return FutureBuilder<int>(
      future: service.trialDaysRemaining,
      builder: (context, snapshot) {
        final daysLeft = snapshot.data;
        final displaySubtitle = status == SubscriptionStatus.trial && daysLeft != null
            ? l10n.trialDaysLeft(daysLeft)
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
