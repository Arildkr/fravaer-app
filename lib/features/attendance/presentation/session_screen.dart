import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../core/utils/status_helpers.dart';
import '../../../core/utils/widget_updater.dart';
import '../data/attendance_repository.dart';
import '../../reports/presentation/report_screen.dart';
import 'attendance_tile.dart';
import 'count_banner.dart';
import 'status_picker_dialog.dart';

/// Universell registreringsskjerm for innsjekk/utsjekk.
/// Erstatter tidligere Klasseromsmodus og Turmodus.
class SessionScreen extends ConsumerStatefulWidget {
  final FravaersOkterData session;
  final GrupperData group;

  const SessionScreen({
    super.key,
    required this.session,
    required this.group,
  });

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _searchActive = false;
  bool _allRegisteredNotified = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _activateSearch() => setState(() => _searchActive = true);

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchActive = false;
    });
  }

  String _buildTitle(AppLocalizations l10n) {
    if (widget.session.navn != null && widget.session.navn!.isNotEmpty) {
      return widget.session.navn!;
    }
    final dato = DateFormat('dd.MM.yyyy').format(widget.session.dato);
    return '${widget.group.navn} — $dato';
  }

  @override
  Widget build(BuildContext context) {
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endSession(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searchActive
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: l10n.searchStudent,
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  textInputAction: TextInputAction.search,
                )
              : Text(_buildTitle(l10n)),
          actions: _searchActive
              ? [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.cancel,
                    onPressed: _clearSearch,
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: l10n.searchStudent,
                    onPressed: _activateSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.description),
                    tooltip: l10n.report,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportScreen(oktId: widget.session.id),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    tooltip: l10n.endSession,
                    onPressed: () => _endSession(context),
                  ),
                ],
        ),
        body: StreamBuilder<List<AttendanceRecord>>(
          stream: attendanceRepo.watchSessionRecords(widget.session.id),
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];

            // Oppdater home screen widget
            if (records.isNotEmpty) {
              final tilStede = records
                  .where((r) => r.post.status == AttendanceStatus.tilStede)
                  .length;
              WidgetUpdater.updateActiveSession(
                gruppeNavn: widget.group.navn,
                tilStede: tilStede,
                totalt: records.length,
              );
            }

            // Haptisk feedback kun én gang når alle er registrert
            if (records.isNotEmpty &&
                records
                    .every((r) => r.post.status != AttendanceStatus.ukjent)) {
              if (!_allRegisteredNotified) {
                _allRegisteredNotified = true;
                HapticService.onAllRegistered();
              }
            } else {
              _allRegisteredNotified = false;
            }

            final filtered = _searchQuery.isNotEmpty
                ? records
                    .where((r) => r.elev.navn
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList()
                : records;

            return Column(
              children: [
                CountBanner(records: records),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, index) => index == 0
                        ? const SizedBox.shrink()
                        : const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Text(
                            l10n.tapChangeStatusHint,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF888888)),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final record = filtered[index - 1];
                      return AttendanceTile(
                        record: record,
                        onTap: () => _quickRegister(record),
                        onLongPress: () =>
                            _showStatusPicker(context, record),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Tap-syklus: ikke møtt → innsjekket → utsjekket → ikke møtt
  Future<void> _quickRegister(AttendanceRecord record) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final next = record.post.status.nextStatus;

    await repo.updateStatus(
      postId: record.post.id,
      status: next,
      merknad: record.post.merknad, // behold eksisterende merknad
    );

    if (next == AttendanceStatus.tilStede) {
      await HapticService.onPresent();
    } else if (next == AttendanceStatus.fravaer) {
      await HapticService.onAbsent();
    }

    if (_searchQuery.isNotEmpty) _clearSearch();
  }

  Future<void> _showStatusPicker(
    BuildContext context,
    AttendanceRecord record,
  ) async {
    final result = await showDialog<StatusResult>(
      context: context,
      builder: (_) => StatusPickerDialog(
        elevNavn: record.elev.navn,
        currentMerknad: record.post.merknad,
      ),
    );

    if (result != null) {
      await ref.read(attendanceRepositoryProvider).updateStatus(
            postId: record.post.id,
            status: result.status,
            forsinkelsesMinutter: result.forsinkelsesMinutter,
            merknad: result.merknad,
          );

      if (result.status == AttendanceStatus.tilStede) {
        await HapticService.onPresent();
      } else if (result.status == AttendanceStatus.fravaer) {
        await HapticService.onAbsent();
      }
    }
  }

  Future<void> _endSession(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.endSessionTitle),
        content: Text(l10n.reportStillAvailable),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.end),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(attendanceRepositoryProvider)
          .endSession(widget.session.id);
      await WidgetUpdater.clearSession();
      ref.read(activeSessionIdProvider.notifier).state = null;
      if (context.mounted) Navigator.pop(context);
    }
  }
}
