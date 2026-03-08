import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/status_helpers.dart';
import '../data/attendance_repository.dart';

/// Gjenbrukbar tile for visning av én elev med status.
/// Stor trykksone for utendørs bruk med hansker/en hånd.
class AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AttendanceTile({
    super.key,
    required this.record,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final status = record.post.status;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: status.color, width: 5),
          ),
          color: status.color.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            // Status-indikator — stor og tydelig
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                status.symbol,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 14),
            // Elevnavn og info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.elev.navn,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  if (status == AttendanceStatus.forseinka &&
                      record.post.forsinkelsesMinutter != null)
                    Text(
                      '${record.post.forsinkelsesMinutter} min forsinket',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: status.color,
                      ),
                    ),
                  if (record.post.merknad != null &&
                      record.post.merknad!.isNotEmpty)
                    Text(
                      record.post.merknad!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                      ),
                    ),
                ],
              ),
            ),
            // Status-label — stor og tydelig
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.label,
                style: TextStyle(
                  fontSize: 15,
                  color: status.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
