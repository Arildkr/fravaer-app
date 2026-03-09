import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

import '../../../core/providers/app_providers.dart';
import '../data/group_repository.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/presentation/classroom_screen.dart';
import '../../attendance/presentation/trip_screen.dart';
import '../../reports/presentation/report_screen.dart';
import '../../reports/presentation/semester_export_screen.dart';
import 'import_students_dialog.dart';

class GroupDetailScreen extends ConsumerWidget {
  final GrupperData group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupRepo = ref.watch(groupRepositoryProvider);

    return StreamBuilder<List<EleverData>>(
      stream: groupRepo.watchGroupMembers(group.id),
      builder: (context, snapshot) {
        final members = snapshot.data ?? [];
        final hasMembers = members.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(group.navn),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Eksporter semester',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SemesterExportScreen(group: group),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Økthistorikk',
                onPressed: () => _showSessionHistory(context, ref),
              ),
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
          body: !hasMembers
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Ingen elever i gruppen',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Legg til elever manuelt eller importer fra fil.',
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
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      child: Text(
                        '${members.length} elever',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.length + 1,
                        itemBuilder: (context, index) {
                          if (index < members.length) {
                            final elev = members[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(elev.navn,
                                  style: const TextStyle(fontSize: 18)),
                              subtitle: elev.elevId != null
                                  ? Text('ID: ${elev.elevId}')
                                  : null,
                              onTap: () =>
                                  _showRenameStudentDialog(context, ref, elev),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    _confirmRemoveStudent(context, ref, elev),
                              ),
                            );
                          }
                          // Historikk-knapp nederst i listen
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showSessionHistory(context, ref),
                              icon: const Icon(Icons.history),
                              label: const Text('Vis avsluttede økter'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: hasMembers
                          ? () => _startSession(
                              context, ref, SessionType.klasseromsOkt)
                          : null,
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
                      onPressed: hasMembers
                          ? () => _startSession(
                              context, ref, SessionType.turregistrering)
                          : null,
                      icon: const Icon(Icons.hiking),
                      label: const Text('Tur'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSessionHistory(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SessionHistoryScreen(group: group),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddStudentsDialog(
        gruppeId: group.id,
        groupRepo: ref.read(groupRepositoryProvider),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImportStudentsDialog(gruppeId: group.id),
    );
  }

  void _showRenameStudentDialog(
      BuildContext context, WidgetRef ref, EleverData elev) {
    final controller = TextEditingController(text: elev.navn);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endre elevnavn'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nytt navn',
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
              await ref
                  .read(groupRepositoryProvider)
                  .renameStudent(elev.id, navn);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Lagre'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveStudent(
      BuildContext context, WidgetRef ref, EleverData elev) {
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

    final session =
        await ref.read(attendanceRepositoryProvider).createSession(
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

/// Dialog for å legge til flere elever etter hverandre.
/// Feltet tømmes og forblir åpent etter hver elev.
class _AddStudentsDialog extends StatefulWidget {
  final String gruppeId;
  final GroupRepository groupRepo;

  const _AddStudentsDialog({
    required this.gruppeId,
    required this.groupRepo,
  });

  @override
  State<_AddStudentsDialog> createState() => _AddStudentsDialogState();
}

class _AddStudentsDialogState extends State<_AddStudentsDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _addedCount = 0;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    final navn = _controller.text.trim();
    if (navn.isEmpty) return;

    // Blokker duplikatnavn i samme gruppe
    final duplicate =
        await widget.groupRepo.hasStudentWithName(navn, widget.gruppeId);
    if (duplicate) {
      setState(() {
        _error = '«$navn» finnes allerede i gruppen.';
      });
      return;
    }

    await widget.groupRepo.addStudentToGroup(
      elevNavn: navn,
      gruppeId: widget.gruppeId,
    );

    setState(() {
      _addedCount++;
      _error = null;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Legg til elever'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Elevnavn',
              hintText: 'Skriv navn og trykk Legg til',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _addStudent(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          if (_addedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '$_addedCount elev${_addedCount == 1 ? '' : 'er'} lagt til',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_addedCount > 0 ? 'Ferdig' : 'Avbryt'),
        ),
        FilledButton(
          onPressed: _addStudent,
          child: const Text('Legg til'),
        ),
      ],
    );
  }
}

/// Skjerm som viser historikk over avsluttede økter for en gruppe.
class _SessionHistoryScreen extends ConsumerWidget {
  final GrupperData group;

  const _SessionHistoryScreen({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'nb');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historikk — ${group.navn}'),
      ),
      body: StreamBuilder<List<FravaersOkterData>>(
        stream: attendanceRepo.watchSessionHistory(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingen avsluttede økter',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Avsluttede økter vises her slik at du kan se rapport eller redigere fravær i ettertid.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isClassroom =
                  session.type == SessionType.klasseromsOkt;

              return ListTile(
                leading: Icon(
                  isClassroom ? Icons.school : Icons.hiking,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  isClassroom ? 'Klasserom' : 'Tur',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(dateFormat.format(session.dato)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.description),
                      tooltip: 'Rapport',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportScreen(oktId: session.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Rediger fravær',
                      onPressed: () =>
                          _reopenSession(context, ref, session),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _reopenSession(
    BuildContext context,
    WidgetRef ref,
    FravaersOkterData session,
  ) async {
    final repo = ref.read(attendanceRepositoryProvider);
    await repo.reopenSession(session.id);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => session.type == SessionType.klasseromsOkt
            ? ClassroomScreen(session: session, group: group)
            : TripScreen(session: session, group: group),
      ),
    );
  }
}
