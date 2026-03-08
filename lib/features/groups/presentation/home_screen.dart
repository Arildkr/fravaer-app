import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/app_providers.dart';
import 'create_group_dialog.dart';
import 'group_detail_screen.dart';
import 'split_group_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laererId = ref.watch(activeLaererIdProvider);

    if (laererId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final groupRepo = ref.watch(groupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mine grupper'),
      ),
      body: StreamBuilder<List<GrupperData>>(
        stream: groupRepo.watchActiveGroups(laererId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_add, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingen grupper ennå',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Opprett din første gruppe for å komme i gang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _GroupCard(group: group);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ny gruppe'),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  final GrupperData group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupRepo = ref.watch(groupRepositoryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: StreamBuilder<List<EleverData>>(
        stream: groupRepo.watchGroupMembers(group.id),
        builder: (context, snapshot) {
          final memberCount = snapshot.data?.length ?? 0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                group.navn.isNotEmpty ? group.navn[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              group.navn,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('$memberCount elever'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(group: group),
                ),
              );
            },
            onLongPress: () => _showGroupOptions(context, ref),
          );
        },
      ),
    );
  }

  void _showGroupOptions(BuildContext context, WidgetRef ref) {
    final laererId = ref.read(activeLaererIdProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Kopier gruppe'),
              subtitle: const Text('Ny gruppe med samme elever'),
              onTap: () {
                Navigator.pop(ctx);
                _showCopyGroupDialog(context, ref, laererId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: const Text('Del gruppe'),
              subtitle: const Text('Velg elever for ny undergruppe'),
              onTap: () {
                Navigator.pop(ctx);
                _showSplitGroupDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.orange),
              title: const Text('Arkiver gruppe'),
              onTap: () {
                ref.read(groupRepositoryProvider).archiveGroup(group.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${group.navn} arkivert'),
                    action: SnackBarAction(
                      label: 'Angre',
                      onPressed: () {
                        ref.read(groupRepositoryProvider).restoreGroup(group.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCopyGroupDialog(BuildContext context, WidgetRef ref, String? laererId) {
    if (laererId == null) return;
    final controller = TextEditingController(text: '${group.navn} (kopi)');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kopier gruppe'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Navn på ny gruppe',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () async {
              final navn = controller.text.trim();
              if (navn.isEmpty) return;
              await ref.read(groupRepositoryProvider).copyGroup(
                    sourceGruppeId: group.id,
                    nyttNavn: navn,
                    laererId: laererId,
                  );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$navn opprettet')),
                );
              }
            },
            child: const Text('Kopier'),
          ),
        ],
      ),
    );
  }

  void _showSplitGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SplitGroupDialog(group: group),
    );
  }
}
