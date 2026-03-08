import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/theme/app_theme.dart';
import '../data/attendance_repository.dart';

/// Teljepanel: «21 / 28 registrert» med tydelig indikator på gjenstående ukjente.
class CountBanner extends StatelessWidget {
  final List<AttendanceRecord> records;

  const CountBanner({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final ukjente = records.where((r) => r.post.status == AttendanceStatus.ukjent).length;
    final registrert = total - ukjente;
    final tilStede = records.where((r) => r.post.status == AttendanceStatus.tilStede).length;
    final fravaer = records.where((r) => r.post.status == AttendanceStatus.fravaer).length;
    final forsinket = records.where((r) => r.post.status == AttendanceStatus.forseinka).length;

    final alleDone = ukjente == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: alleDone
          ? AppTheme.statusTilStede.withValues(alpha: 0.1)
          : AppTheme.statusUkjent.withValues(alpha: 0.1),
      child: Column(
        children: [
          // Hovedteller
          Text(
            '$registrert / $total registrert',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: alleDone ? AppTheme.statusTilStede : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          // Detaljer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountChip(label: 'Til stede', count: tilStede, color: AppTheme.statusTilStede),
              const SizedBox(width: 8),
              _CountChip(label: 'Fravær', count: fravaer, color: AppTheme.statusFravaer),
              const SizedBox(width: 8),
              _CountChip(label: 'Forsinket', count: forsinket, color: AppTheme.statusForseinka),
              if (ukjente > 0) ...[
                const SizedBox(width: 8),
                _CountChip(label: 'Ukjent', count: ukjente, color: AppTheme.statusUkjent),
              ],
            ],
          ),
          // Advarsel
          if (ukjente > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$ukjente ikke registrert',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
