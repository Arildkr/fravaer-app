import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';

import '../../../core/database/tables.dart';
import '../../../core/theme/app_theme.dart';
import '../data/attendance_repository.dart';

/// Teljepanel: tydelig oversikt med store tall, lesbare i sollys.
class CountBanner extends StatelessWidget {
  final List<AttendanceRecord> records;
  final bool isUtsjekkFase;

  const CountBanner({super.key, required this.records, this.isUtsjekkFase = false});

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final ukjente =
        records.where((r) => r.post.status == AttendanceStatus.ukjent).length;
    final tilStede = records
        .where((r) => r.post.status == AttendanceStatus.tilStede)
        .length;
    final utsjekket = records
        .where((r) => r.post.status == AttendanceStatus.utsjekket)
        .length;
    final fravaer =
        records.where((r) => r.post.status == AttendanceStatus.fravaer).length;
    final forsinket = records
        .where((r) => r.post.status == AttendanceStatus.forseinka)
        .length;

    final l10n = AppLocalizations.of(context)!;

    if (isUtsjekkFase) {
      // Utsjekk-fase: vis utsjekket av innsjekket
      final innsjekket = tilStede + utsjekket;
      final allUtsjekket = tilStede == 0 && innsjekket > 0;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: allUtsjekket
            ? AppTheme.statusPlanlagtBorte.withValues(alpha: 0.12)
            : Colors.blue[50],
        child: Column(
          children: [
            Text(
              '$utsjekket / $innsjekket ${l10n.statusCheckedOut.toLowerCase()}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: allUtsjekket ? AppTheme.statusPlanlagtBorte : Colors.blue[800],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                if (tilStede > 0)
                  _CountChip(
                      label: l10n.statusPresent,
                      count: tilStede,
                      color: AppTheme.statusTilStede),
                _CountChip(
                    label: l10n.statusCheckedOut,
                    count: utsjekket,
                    color: AppTheme.statusPlanlagtBorte),
                if (fravaer > 0)
                  _CountChip(
                      label: l10n.statusAbsent,
                      count: fravaer,
                      color: AppTheme.statusFravaer),
              ],
            ),
          ],
        ),
      );
    }

    // Innsjekk-fase: standard visning
    final registrert = total - ukjente;
    final alleDone = ukjente == 0 && total > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: alleDone
          ? AppTheme.statusTilStede.withValues(alpha: 0.12)
          : AppTheme.statusUkjent.withValues(alpha: 0.08),
      child: Column(
        children: [
          Text(
            l10n.registeredCount(registrert, total),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: alleDone
                  ? AppTheme.statusTilStede
                  : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              _CountChip(
                  label: l10n.statusPresent,
                  count: tilStede,
                  color: AppTheme.statusTilStede),
              _CountChip(
                  label: l10n.statusAbsent,
                  count: fravaer,
                  color: AppTheme.statusFravaer),
              _CountChip(
                  label: l10n.statusLate,
                  count: forsinket,
                  color: AppTheme.statusForseinka),
              if (ukjente > 0)
                _CountChip(
                    label: l10n.statusUnknown,
                    count: ukjente,
                    color: AppTheme.statusUkjent),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
