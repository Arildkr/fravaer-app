import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/app_providers.dart';

/// Visning av arkiverte grupper med mulighet for gjenoppretting.
class ArchivedGroupsScreen extends ConsumerWidget {
  const ArchivedGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laererId = ref.watch(activeLaererIdProvider);
    if (laererId == null) return const SizedBox.shrink();

    final groupRepo = ref.watch(groupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkiverte grupper'),
      ),
      body: StreamBuilder<List<GrupperData>>(
        stream: groupRepo.watchArchivedGroups(laererId),
        builder: (context, snapshot) {
          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.archive, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingen arkiverte grupper',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    group.navn.isNotEmpty ? group.navn[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(group.navn),
                trailing: TextButton(
                  onPressed: () {
                    ref.read(groupRepositoryProvider).restoreGroup(group.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${group.navn} gjenopprettet')),
                    );
                  },
                  child: const Text('Gjenopprett'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
