import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: status.color, width: 4),
          ),
          color: status.color.withValues(alpha: 0.06),
        ),
        child: Row(
          children: [
            // Status-indikator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                status.symbol,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 10),
            // Elevnavn og info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    record.elev.navn,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  if (status == AttendanceStatus.forseinka &&
                      record.post.forsinkelsesMinutter != null)
                    Text(
                      AppLocalizations.of(context)!.minutesLate(record.post.forsinkelsesMinutter!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: status.color,
                      ),
                    ),
                  if (record.post.merknad != null &&
                      record.post.merknad!.isNotEmpty)
                    Text(
                      record.post.merknad!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                      ),
                    ),
                ],
              ),
            ),
            // Status-label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.labelOf(l10n),
                style: TextStyle(
                  fontSize: 13,
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
