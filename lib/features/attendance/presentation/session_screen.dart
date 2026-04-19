import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import 'attendance_tile.dart';
import 'count_banner.dart';
import 'status_picker_dialog.dart';

enum SessionPhase { innsjekk, utsjekk }

/// Universell registreringsskjerm med to-fase innsjekk/utsjekk.
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
  bool _allDoneNotified = false;
  SessionPhase _phase = SessionPhase.innsjekk;

  String? _shareId;
  String? _inviteCode;
  bool _sharingLoading = false;

  @override
  void initState() {
    super.initState();
    // Gjenoppta lytting hvis økten allerede er delt (f.eks. etter app-restart)
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

  String _buildTitle(AppLocalizations l10n) {
    if (widget.session.navn != null && widget.session.navn!.isNotEmpty) {
      return widget.session.navn!;
    }
    final dato = DateFormat('dd.MM.yyyy').format(widget.session.dato);
    return '${widget.group.navn} — $dato';
  }

  void _togglePhase() => setState(() {
        _phase =
            _phase == SessionPhase.innsjekk ? SessionPhase.utsjekk : SessionPhase.innsjekk;
        _allDoneNotified = false;
      });

  @override
  Widget build(BuildContext context) {
    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final isInnsjekk = _phase == SessionPhase.innsjekk;

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
                        builder: (_) => ReportScreen(oktId: widget.session.id),
                      ),
                    ),
                  ),
                  if (_sharingLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _shareId != null ? Icons.cloud_done : Icons.cloud_upload,
                        color: _shareId != null ? Colors.greenAccent : null,
                      ),
                      tooltip: _shareId != null ? l10n.shareSession : l10n.shareSession,
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

            if (records.isNotEmpty) {
              final tilStede = records
                  .where((r) => r.post.status == AttendanceStatus.tilStede)
                  .length;
              SchedulerBinding.instance.addPostFrameCallback((_) {
                WidgetUpdater.updateActiveSession(
                  gruppeNavn: widget.group.navn,
                  tilStede: tilStede,
                  totalt: records.length,
                ).catchError((_) {});
              });
            }

            // Haptisk feedback når alle er ferdig registrert i gjeldende fase
            if (isInnsjekk) {
              final alleDone = records.isNotEmpty &&
                  records.every((r) => r.post.status != AttendanceStatus.ukjent);
              if (alleDone && !_allDoneNotified) {
                _allDoneNotified = true;
                HapticService.onAllRegistered();
              } else if (!alleDone) {
                _allDoneNotified = false;
              }
            } else {
              final innsjekket = records
                  .where((r) => r.post.status == AttendanceStatus.tilStede)
                  .length;
              if (innsjekket == 0 && records.isNotEmpty && !_allDoneNotified) {
                _allDoneNotified = true;
                HapticService.onAllRegistered();
              } else if (innsjekket > 0) {
                _allDoneNotified = false;
              }
            }

            // Filtrer på søk
            var filtered = _searchQuery.isNotEmpty
                ? records
                    .where((r) => r.elev.navn
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList()
                : List<AttendanceRecord>.from(records);

            // I utsjekk-fase: sorter slik at de som ikke er utsjekket kommer øverst
            if (!isInnsjekk) {
              filtered.sort((a, b) {
                int order(AttendanceStatus s) {
                  if (s == AttendanceStatus.tilStede) return 0; // trenger utsjekk
                  if (s == AttendanceStatus.forseinka) return 1; // trenger utsjekk
                  if (s == AttendanceStatus.utsjekket) return 3; // ferdig
                  return 2; // fravaer / ukjent
                }
                return order(a.post.status).compareTo(order(b.post.status));
              });
            }

            return Column(
              children: [
                if (_shareId != null) _SharingBanner(l10n: l10n),
                _PhaseBanner(phase: _phase, l10n: l10n),
                CountBanner(records: records, isUtsjekkFase: !isInnsjekk),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, i) =>
                        i == 0 ? const SizedBox.shrink() : const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Text(
                            isInnsjekk ? l10n.innsjekkHint : l10n.utsjekkHint,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF888888)),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final record = filtered[index - 1];
                      // Dimm kun ukjent/fravaer i utsjekk-fase; forsinket er aktiv
                      final dimmed = !isInnsjekk &&
                          record.post.status != AttendanceStatus.tilStede &&
                          record.post.status != AttendanceStatus.utsjekket &&
                          record.post.status != AttendanceStatus.forseinka;
                      return Opacity(
                        opacity: dimmed ? 0.35 : 1.0,
                        child: AttendanceTile(
                          record: record,
                          onTap: () => _quickRegister(record),
                          onLongPress: () => _showStatusPicker(context, record),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePhase,
                    icon: Icon(
                      isInnsjekk ? Icons.logout : Icons.login,
                      size: 18,
                    ),
                    label: Text(
                      isInnsjekk ? l10n.switchToUtsjekk : l10n.switchToInnsjekk,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _endSession(context),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text(l10n.endSession),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tap-logikk avhenger av fase.
  /// Innsjekk: ukjent → tilStede → fravaer → ukjent (3-stegs syklus)
  /// Utsjekk: tilStede/forseinka → utsjekket; utsjekket → tilStede
  Future<void> _quickRegister(AttendanceRecord record) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final status = record.post.status;

    final AttendanceStatus next;
    if (_phase == SessionPhase.innsjekk) {
      switch (status) {
        case AttendanceStatus.ukjent:
          next = AttendanceStatus.tilStede;
        case AttendanceStatus.tilStede:
          next = AttendanceStatus.fravaer;
        default:
          next = AttendanceStatus.ukjent;
      }
    } else {
      if (status == AttendanceStatus.tilStede ||
          status == AttendanceStatus.forseinka) {
        next = AttendanceStatus.utsjekket;
      } else if (status == AttendanceStatus.utsjekket) {
        next = AttendanceStatus.tilStede;
      } else {
        return; // ikke endre ukjent i utsjekk-fase
      }
    }

    await repo.updateStatus(
      postId: record.post.id,
      status: next,
      merknad: record.post.merknad,
    );

    if (_shareId != null) {
      ref.read(sessionSharingServiceProvider).pushStatusUpdate(
            shareId: _shareId!,
            postId: record.post.id,
            status: next,
            merknad: record.post.merknad,
          );
    }

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
        currentStatus: record.post.status,
        currentMerknad: record.post.merknad,
        isUtsjekkFase: _phase == SessionPhase.utsjekk,
      ),
    );

    if (result != null) {
      await ref.read(attendanceRepositoryProvider).updateStatus(
            postId: record.post.id,
            status: result.status,
            forsinkelsesMinutter: result.forsinkelsesMinutter,
            merknad: result.merknad,
          );

      if (_shareId != null) {
        ref.read(sessionSharingServiceProvider).pushStatusUpdate(
              shareId: _shareId!,
              postId: record.post.id,
              status: result.status,
              forsinkelsesMinutter: result.forsinkelsesMinutter,
              merknad: result.merknad,
            );
      }

      if (result.status == AttendanceStatus.tilStede) {
        await HapticService.onPresent();
      } else if (result.status == AttendanceStatus.fravaer) {
        await HapticService.onAbsent();
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
      try {
        await WidgetUpdater.clearSession();
      } catch (_) {}
      ref.read(activeSessionIdProvider.notifier).state = null;
      if (context.mounted) Navigator.pop(context);
    }
  }
}

/// Banner som vises øverst når sanntidsdeling er aktiv.
class _SharingBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _SharingBanner({required this.l10n});

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

/// Fase-banner øverst i listen — tydelig indikator på innsjekk vs utsjekk.
class _PhaseBanner extends StatelessWidget {
  final SessionPhase phase;
  final AppLocalizations l10n;

  const _PhaseBanner({required this.phase, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isInnsjekk = phase == SessionPhase.innsjekk;
    final color = isInnsjekk ? Colors.green[700]! : Colors.blue[700]!;
    final bgColor = isInnsjekk ? Colors.green[50]! : Colors.blue[50]!;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isInnsjekk ? Icons.login : Icons.logout, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            isInnsjekk ? l10n.phaseInnsjekk.toUpperCase() : l10n.phaseUtsjekk.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
