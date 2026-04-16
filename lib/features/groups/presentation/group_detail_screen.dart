import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';

import '../../../core/providers/app_providers.dart';
import '../data/group_repository.dart';
import '../../attendance/presentation/session_screen.dart';
import '../../reports/presentation/report_screen.dart';
import '../../reports/presentation/semester_export_screen.dart';
import 'import_students_dialog.dart';

enum _StudentSort { fornavn, etternavn, lagtTil }

class GroupDetailScreen extends ConsumerStatefulWidget {
  final GrupperData group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  _StudentSort _sort = _StudentSort.fornavn;

  List<EleverData> _applySort(
      List<({EleverData elev, DateTime innmeldtDato})> raw) {
    final sorted = List.of(raw);
    switch (_sort) {
      case _StudentSort.fornavn:
        sorted.sort((a, b) =>
            a.elev.navn.toLowerCase().compareTo(b.elev.navn.toLowerCase()));
      case _StudentSort.etternavn:
        sorted.sort((a, b) {
          final aLast = a.elev.navn.trim().split(' ').last.toLowerCase();
          final bLast = b.elev.navn.trim().split(' ').last.toLowerCase();
          return aLast.compareTo(bLast);
        });
      case _StudentSort.lagtTil:
        sorted.sort((a, b) => a.innmeldtDato.compareTo(b.innmeldtDato));
    }
    return sorted.map((m) => m.elev).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupRepo = ref.watch(groupRepositoryProvider);

    return StreamBuilder<List<({EleverData elev, DateTime innmeldtDato})>>(
      stream: groupRepo.watchGroupMembersWithDate(widget.group.id),
      builder: (context, snapshot) {
        final members = _applySort(snapshot.data ?? []);
        final hasMembers = members.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.group.navn),
            actions: [
              PopupMenuButton<_StudentSort>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sorter',
                initialValue: _sort,
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _StudentSort.fornavn,  child: Text('Fornavn')),
                  PopupMenuItem(value: _StudentSort.etternavn, child: Text('Etternavn')),
                  PopupMenuItem(value: _StudentSort.lagtTil,  child: Text('Rekkefølge lagt til')),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: l10n.exportSemester,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SemesterExportScreen(group: widget.group),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: l10n.sessionHistory,
                onPressed: () => _showSessionHistory(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: l10n.addStudent,
                onPressed: () => _showAddStudentDialog(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.upload_file),
                tooltip: l10n.importStudents,
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
                        Text(
                          l10n.noStudentsInGroup,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addStudentsManuallyOrImport,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => _showImportDialog(context),
                          icon: const Icon(Icons.upload_file),
                          label: Text(l10n.importStudents),
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
                        l10n.studentCount(members.length),
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
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<FravaersOkterData?>(
                future: hasMembers
                    ? ref
                        .read(attendanceRepositoryProvider)
                        .getActiveSessionForGroup(widget.group.id)
                    : Future.value(null),
                builder: (context, snapshot) {
                  final hasActive = snapshot.data != null;
                  return FilledButton.icon(
                    onPressed: hasMembers
                        ? () => _startSession(context, ref)
                        : null,
                    icon: Icon(
                        hasActive ? Icons.play_arrow : Icons.how_to_reg),
                    label: Text(hasActive
                        ? l10n.continueSession
                        : l10n.startSession),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: hasActive
                          ? Colors.green[700]
                          : null,
                    ),
                  );
                },
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
        builder: (_) => _SessionHistoryScreen(group: widget.group),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddStudentsDialog(
        gruppeId: widget.group.id,
        groupRepo: ref.read(groupRepositoryProvider),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImportStudentsDialog(gruppeId: widget.group.id),
    );
  }

  void _showRenameStudentDialog(
      BuildContext context, WidgetRef ref, EleverData elev) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: elev.navn);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameStudentTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.newNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
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
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveStudent(
      BuildContext context, WidgetRef ref, EleverData elev) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeStudentTitle),
        content: Text(l10n.removeStudentContent(elev.navn)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(groupRepositoryProvider).removeStudentFromGroup(
                    elevId: elev.id,
                    gruppeId: widget.group.id,
                  );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final laererId = ref.read(activeLaererIdProvider);
    if (laererId == null) return;

    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    // Gå direkte til aktiv økt hvis den finnes – ingen unødvendig dialog
    final existing = await attendanceRepo.getActiveSessionForGroup(widget.group.id);
    if (existing != null) {
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SessionScreen(session: existing, group: widget.group),
      ));
      return;
    }

    if (!context.mounted) return;

    // Be om valgfritt navn på registreringen
    final sessionName = await _askSessionName(context);
    if (!context.mounted) return;
    if (sessionName == null) return; // avbrutt

    final session = await attendanceRepo.createSession(
      gruppeId: widget.group.id,
      laererId: laererId,
      navn: sessionName.isEmpty ? null : sessionName,
    );

    ref.read(activeSessionIdProvider.notifier).state = session.id;

    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SessionScreen(session: session, group: widget.group),
    ));
  }

  /// Viser dialog for å gi navn til registreringen.
  /// Returnerer null hvis bruker trykker Avbryt, ellers streng (tom = ingen navn).
  Future<String?> _askSessionName(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.startSession),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.sessionName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.startSession),
          ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addStudent),
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
          child: Text(_addedCount > 0 ? 'Ferdig' : l10n.cancel),
        ),
        FilledButton(
          onPressed: _addStudent,
          child: Text(l10n.addStudent),
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
    final l10n = AppLocalizations.of(context)!;
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle(group.navn)),
      ),
      body: StreamBuilder<List<FravaersOkterData>>(
        stream: attendanceRepo.watchSessionHistory(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
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
                    Text(
                      l10n.noFinishedSessions,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.finishedSessionsDescription,
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
              final displayName = (session.navn != null && session.navn!.isNotEmpty)
                  ? session.navn!
                  : l10n.startSession;

              return ListTile(
                leading: Icon(
                  Icons.how_to_reg,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(dateFormat.format(session.dato)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.description),
                      tooltip: l10n.report,
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
                      tooltip: l10n.editAbsence,
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
        builder: (_) => SessionScreen(session: session, group: group),
      ),
    );
  }
}
