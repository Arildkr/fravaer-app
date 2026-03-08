import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/status_helpers.dart';
import '../data/attendance_repository.dart';

/// Gjenbrukbar tile for visning av én elev med status.
/// Minst 60px trykksone per kravspesifikasjon.
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
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: status.color, width: 4),
          ),
          color: status.color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            // Status-indikator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                status.symbol,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Elevnavn og info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.elev.navn,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (status == AttendanceStatus.forseinka &&
                      record.post.forsinkelsesMinutter != null)
                    Text(
                      '${record.post.forsinkelsesMinutter} min forsinket',
                      style: TextStyle(
                        fontSize: 14,
                        color: status.color,
                      ),
                    ),
                  if (record.post.merknad != null &&
                      record.post.merknad!.isNotEmpty)
                    Text(
                      record.post.merknad!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            // Status-label
            Text(
              status.label,
              style: TextStyle(
                fontSize: 14,
                color: status.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
