import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../core/utils/widget_updater.dart';
import '../data/attendance_repository.dart';
import '../../reports/presentation/report_screen.dart';
import 'attendance_tile.dart';
import 'count_banner.dart';
import 'status_picker_dialog.dart';

/// Klasseromsmodus — standard for timer i klasserom.
class ClassroomScreen extends ConsumerStatefulWidget {
  final FravaersOkterData session;
  final GrupperData group;

  const ClassroomScreen({
    super.key,
    required this.session,
    required this.group,
  });

  @override
  ConsumerState<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends ConsumerState<ClassroomScreen> {
  bool _allRegisteredNotified = false;

  @override
  Widget build(BuildContext context) {
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endSession(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.classroomTitle(widget.group.navn)),
          actions: [
            IconButton(
              icon: const Icon(Icons.description),
              tooltip: AppLocalizations.of(context)!.report,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ReportScreen(oktId: widget.session.id),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: AppLocalizations.of(context)!.endSession,
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
                records.every(
                    (r) => r.post.status != AttendanceStatus.ukjent)) {
              if (!_allRegisteredNotified) {
                _allRegisteredNotified = true;
                HapticService.onAllRegistered();
              }
            } else {
              _allRegisteredNotified = false;
            }

            return Column(
              children: [
                CountBanner(records: records),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.grey[100],
                  child: Text(
                    AppLocalizations.of(context)!.tapChangeStatusHint,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return AttendanceTile(
                        record: record,
                        onTap: () => _quickToggle(record),
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

  /// Hurtig-toggle: ukjent → til stede → fravær → ukjent
  Future<void> _quickToggle(AttendanceRecord record) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = record.post.status;

    AttendanceStatus newStatus;
    if (current == AttendanceStatus.ukjent) {
      newStatus = AttendanceStatus.tilStede;
      await HapticService.onPresent();
    } else if (current == AttendanceStatus.tilStede) {
      newStatus = AttendanceStatus.fravaer;
      await HapticService.onAbsent();
    } else {
      newStatus = AttendanceStatus.ukjent;
    }

    await repo.updateStatus(
      postId: record.post.id,
      status: newStatus,
    );
  }

  Future<void> _showStatusPicker(
    BuildContext context,
    AttendanceRecord record,
  ) async {
    final result = await showDialog<StatusResult>(
      context: context,
      builder: (_) => StatusPickerDialog(elevNavn: record.elev.navn),
    );

    if (result != null) {
      await ref.read(attendanceRepositoryProvider).updateStatus(
            postId: record.post.id,
            status: result.status,
            forsinkelsesMinutter: result.forsinkelsesMinutter,
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
