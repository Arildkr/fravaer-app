import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/theme/app_theme.dart';
import '../data/attendance_repository.dart';

/// Teljepanel: tydelig oversikt med store tall, lesbare i sollys.
class CountBanner extends StatelessWidget {
  final List<AttendanceRecord> records;

  const CountBanner({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final ukjente =
        records.where((r) => r.post.status == AttendanceStatus.ukjent).length;
    final registrert = total - ukjente;
    final tilStede = records
        .where((r) => r.post.status == AttendanceStatus.tilStede)
        .length;
    final fravaer =
        records.where((r) => r.post.status == AttendanceStatus.fravaer).length;
    final forsinket = records
        .where((r) => r.post.status == AttendanceStatus.forseinka)
        .length;

    final alleDone = ukjente == 0 && total > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: alleDone
          ? AppTheme.statusTilStede.withValues(alpha: 0.12)
          : AppTheme.statusUkjent.withValues(alpha: 0.08),
      child: Column(
        children: [
          // Hovedteller — stor og tydelig
          Text(
            '$registrert / $total registrert',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: alleDone
                  ? AppTheme.statusTilStede
                  : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          // Detaljerte tall — Wrap for å unngå overflow på smale skjermer
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              _CountChip(
                  label: 'Til stede',
                  count: tilStede,
                  color: AppTheme.statusTilStede),
              _CountChip(
                  label: 'Fravær',
                  count: fravaer,
                  color: AppTheme.statusFravaer),
              _CountChip(
                  label: 'Forsinket',
                  count: forsinket,
                  color: AppTheme.statusForseinka),
              if (ukjente > 0)
                _CountChip(
                    label: 'Ukjent',
                    count: ukjente,
                    color: AppTheme.statusUkjent),
            ],
          ),
          // Advarsel — tydeligere
          if (ukjente > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$ukjente ikke registrert',
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
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
