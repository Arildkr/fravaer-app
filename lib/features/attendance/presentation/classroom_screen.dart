import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../data/attendance_repository.dart';
import '../../reports/presentation/report_screen.dart';
import 'attendance_tile.dart';
import 'count_banner.dart';
import 'status_picker_dialog.dart';

/// Klasseromsmodus — standard for timer i klasserom.
/// Stor, trykkvennlig elevliste med teljepanel øverst.
class ClassroomScreen extends ConsumerWidget {
  final FravaersOkterData session;
  final GrupperData group;

  const ClassroomScreen({
    super.key,
    required this.session,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.navn} — Klasserom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Rapport',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportScreen(oktId: session.id),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Avslutt økt',
            onPressed: () => _endSession(context, ref),
          ),
        ],
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: attendanceRepo.watchSessionRecords(session.id),
        builder: (context, snapshot) {
          final records = snapshot.data ?? [];

          // Sjekk om alle er registrert for haptisk feedback
          if (records.isNotEmpty &&
              records.every((r) => r.post.status != AttendanceStatus.ukjent)) {
            HapticService.onAllRegistered();
          }

          return Column(
            children: [
              CountBanner(records: records),
              Expanded(
                child: ListView.separated(
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return AttendanceTile(
                      record: record,
                      onTap: () => _quickToggle(ref, record),
                      onLongPress: () => _showStatusPicker(context, ref, record),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Hurtig-toggle: ukjent → til stede → fravær
  Future<void> _quickToggle(WidgetRef ref, AttendanceRecord record) async {
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
    WidgetRef ref,
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

  Future<void> _endSession(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Avslutt økt?'),
        content: const Text('Du kan fortsatt se rapporten etter avslutning.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Avslutt'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(attendanceRepositoryProvider).endSession(session.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
