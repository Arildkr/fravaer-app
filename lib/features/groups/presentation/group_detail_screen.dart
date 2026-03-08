import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

import '../../../core/providers/app_providers.dart';
import '../../attendance/presentation/classroom_screen.dart';
import '../../attendance/presentation/trip_screen.dart';
import 'import_students_dialog.dart';

class GroupDetailScreen extends ConsumerWidget {
  final GrupperData group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupRepo = ref.watch(groupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.navn),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Legg til elev',
            onPressed: () => _showAddStudentDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importer elever',
            onPressed: () => _showImportDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<EleverData>>(
        stream: groupRepo.watchGroupMembers(group.id),
        builder: (context, snapshot) {
          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingen elever i gruppen',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Legg til elever manuelt eller importer fra CSV.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showImportDialog(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Importer elever'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Teller-banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  '${members.length} elever',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              // Elevliste
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final elev = members[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        elev.navn,
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: elev.elevId != null
                          ? Text('ID: ${elev.elevId}')
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _confirmRemoveStudent(context, ref, elev),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Handlingsknapper for å starte økt
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _startSession(context, ref, SessionType.klasseromsOkt),
                  icon: const Icon(Icons.school),
                  label: const Text('Klasserom'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _startSession(context, ref, SessionType.turregistrering),
                  icon: const Icon(Icons.hiking),
                  label: const Text('Tur'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Legg til elev'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Elevnavn',
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
              if (navn.isNotEmpty) {
                await ref.read(groupRepositoryProvider).addStudentToGroup(
                      elevNavn: navn,
                      gruppeId: group.id,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Legg til'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImportStudentsDialog(gruppeId: group.id),
    );
  }

  void _confirmRemoveStudent(BuildContext context, WidgetRef ref, EleverData elev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fjern elev fra gruppen?'),
        content: Text(
          '${elev.navn} fjernes fra denne gruppen. '
          'Elevens data og historikk beholdes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(groupRepositoryProvider).removeStudentFromGroup(
                    elevId: elev.id,
                    gruppeId: group.id,
                  );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Fjern'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(
    BuildContext context,
    WidgetRef ref,
    SessionType type,
  ) async {
    final laererId = ref.read(activeLaererIdProvider);
    if (laererId == null) return;

    final session = await ref.read(attendanceRepositoryProvider).createSession(
          gruppeId: group.id,
          laererId: laererId,
          type: type,
        );

    ref.read(activeSessionIdProvider.notifier).state = session.id;

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => type == SessionType.klasseromsOkt
            ? ClassroomScreen(session: session, group: group)
            : TripScreen(session: session, group: group),
      ),
    );
  }
}
