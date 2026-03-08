import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/app_providers.dart';

/// Innstillingsside — biometrisk lås, om appen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
