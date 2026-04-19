import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../../core/utils/widget_updater.dart';
import '../data/attendance_repository.dart';
import '../../reports/presentation/report_screen.dart';
import '../../sharing/sharing_providers.dart';
import '../../sharing/presentation/sharing_consent_dialog.dart';
import '../../sharing/presentation/share_session_dialog.dart';
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
  bool _searchActive = false;
  bool _allRegisteredNotified = false;

  String? _shareId;
  String? _inviteCode;
  bool _sharingLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.session.shareId != null) {
      _shareId = widget.session.shareId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionSharingServiceProvider).startListening(
              shareId: _shareId!,
            );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_shareId != null) {
      ref.read(sessionSharingServiceProvider).stopListening(_shareId!);
    }
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
              : Text(l10n.tripTitle(widget.group.navn)),
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
                        builder: (_) => ReportScreen(oktId: widget.session.id),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    tooltip: l10n.endSession,
                    onPressed: () => _endSession(context),
                  ),
                  if (_sharingLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _shareId != null ? Icons.cloud_done : Icons.cloud_upload,
                        color: _shareId != null ? Colors.greenAccent : null,
                      ),
                      tooltip: l10n.shareSession,
                      onPressed: () => _shareId != null
                          ? _showShareDialog(context, l10n)
                          : _shareSession(context, l10n),
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
                if (_shareId != null) _TripSharingBanner(l10n: l10n),
                CountBanner(records: records),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, index) =>
                        index == 0 ? const SizedBox.shrink() : const Divider(height: 1),
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

  Future<void> _quickRegister(AttendanceRecord record) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = record.post.status;

    AttendanceStatus next;
    if (current == AttendanceStatus.ukjent) {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.tilStede);
      next = AttendanceStatus.tilStede;
      await HapticService.onPresent();
    } else if (current == AttendanceStatus.tilStede) {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.fravaer);
      next = AttendanceStatus.fravaer;
      await HapticService.onAbsent();
    } else {
      await repo.updateStatus(
          postId: record.post.id, status: AttendanceStatus.ukjent);
      next = AttendanceStatus.ukjent;
    }

    if (_shareId != null) {
      ref.read(sessionSharingServiceProvider).pushStatusUpdate(
            shareId: _shareId!,
            postId: record.post.id,
            status: next,
          );
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
            currentStatus: record.post.status,
          ),
    );

    if (result != null) {
      await ref.read(attendanceRepositoryProvider).updateStatus(
            postId: record.post.id,
            status: result.status,
            forsinkelsesMinutter: result.forsinkelsesMinutter,
          );
      if (_shareId != null) {
        ref.read(sessionSharingServiceProvider).pushStatusUpdate(
              shareId: _shareId!,
              postId: record.post.id,
              status: result.status,
              forsinkelsesMinutter: result.forsinkelsesMinutter,
            );
      }
    }
  }

  // ─── Deling ─────────────────────────────────────────────────────

  Future<void> _shareSession(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final consent = await showSharingConsentDialog(context);
    if (!consent || !mounted) return;

    setState(() => _sharingLoading = true);
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final records = await repo.getSessionRecordsOnce(widget.session.id);
      final service = ref.read(sessionSharingServiceProvider);

      final code = await service.shareSession(
        session: widget.session,
        groupName: widget.group.navn,
        records: records
            .map((r) => (
                  postId: r.post.id,
                  studentName: r.elev.navn,
                  status: r.post.status,
                  forsinkelsesMinutter: r.post.forsinkelsesMinutter,
                  merknad: r.post.merknad,
                ))
            .toList(),
      );

      service.startListening(shareId: widget.session.id);

      if (mounted) {
        setState(() {
          _shareId = widget.session.id;
          _inviteCode = code;
          _sharingLoading = false;
        });
        // ignore: use_build_context_synchronously
        _showShareDialog(context, l10n);
      }
    } catch (e) {
      if (mounted) setState(() => _sharingLoading = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.sharingError)));
    }
  }

  void _showShareDialog(BuildContext context, AppLocalizations l10n) {
    if (_inviteCode == null) return;
    showDialog(
      context: context,
      builder: (_) => ShareSessionDialog(
        inviteCode: _inviteCode!,
        onStopSharing: () => _stopSharing(context, l10n),
      ),
    );
  }

  Future<void> _stopSharing(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stopSharingTitle),
        content: Text(l10n.stopSharingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.stopSharing),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await ref.read(sessionSharingServiceProvider).deleteSharedSession(_shareId!);
      if (mounted) setState(() { _shareId = null; _inviteCode = null; });
      messenger.showSnackBar(SnackBar(content: Text(l10n.stopSharingDone)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.sharingError)));
    }
  }

  Future<void> _endSession(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.endTripTitle),
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
      // Slett skydata om deling er aktiv
      if (_shareId != null) {
        try {
          await ref
              .read(sessionSharingServiceProvider)
              .deleteSharedSession(_shareId!);
        } catch (_) {}
      }
      await ref
          .read(attendanceRepositoryProvider)
          .endSession(widget.session.id);
      await WidgetUpdater.clearSession();
      ref.read(activeSessionIdProvider.notifier).state = null;
      if (context.mounted) Navigator.pop(context);
    }
  }
}

/// Banner som vises øverst når sanntidsdeling er aktiv.
class _TripSharingBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _TripSharingBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.teal.shade700,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_done, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            l10n.activeSharingBanner,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
