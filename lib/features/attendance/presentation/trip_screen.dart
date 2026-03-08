import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../core/utils/widget_updater.dart';
import '../data/attendance_repository.dart';
import '../../reports/presentation/report_screen.dart';
import 'count_banner.dart';
import 'attendance_tile.dart';
import 'status_picker_dialog.dart';

/// Turmodus — designet for en-hånds bruk i bevegelse.
class TripScreen extends ConsumerStatefulWidget {
  final FravaersOkterData session;
  final GrupperData group;

  const TripScreen({
    super.key,
    required this.session,
    required this.group,
  });

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _allRegisteredNotified = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          title: Text('${widget.group.navn} — Tur'),
          actions: [
            IconButton(
              icon: const Icon(Icons.description),
              tooltip: 'Rapport',
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
              tooltip: 'Avslutt økt',
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

            // Haptisk feedback kun én gang
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
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.grey[100],
                  child: const Text(
                    'Trykk = endre status · Hold inne = flere valg',
                    style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Søk etter elev...',
                      prefixIcon: const Icon(Icons.search, size: 28),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = filtered[index];
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

  Future<void> _quickRegister(AttendanceRecord record) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = record.post.status;

    if (current == AttendanceStatus.ukjent) {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.tilStede);
      await HapticService.onPresent();
    } else if (current == AttendanceStatus.tilStede) {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.fravaer);
      await HapticService.onAbsent();
    } else {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.ukjent);
    }

    if (_searchQuery.isNotEmpty) {
      _searchController.clear();
      setState(() => _searchQuery = '');
    }
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
    }
  }

  Future<void> _endSession(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Avslutt turregistrering?'),
        content:
            const Text('Du kan fortsatt se rapporten etter avslutning.'),
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
      await ref
          .read(attendanceRepositoryProvider)
          .endSession(widget.session.id);
      await WidgetUpdater.clearSession();
      if (context.mounted) Navigator.pop(context);
    }
  }
}
