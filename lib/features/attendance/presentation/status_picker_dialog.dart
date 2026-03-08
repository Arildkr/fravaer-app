import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/status_helpers.dart';

/// Dialog for å velge status. Inkluderer hurtigval for forsinkelse.
class StatusPickerDialog extends StatelessWidget {
  final String elevNavn;

  const StatusPickerDialog({super.key, required this.elevNavn});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(elevNavn),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusOption(
            status: AttendanceStatus.tilStede,
            onTap: () => Navigator.pop(context, const StatusResult(AttendanceStatus.tilStede)),
          ),
          _StatusOption(
            status: AttendanceStatus.fravaer,
            onTap: () => Navigator.pop(context, const StatusResult(AttendanceStatus.fravaer)),
          ),
          const Divider(),
          // Hurtigval for forsinkelse
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Forsinket:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final min in [5, 10, 15, 20])
                _DelayChip(
                  minutes: min,
                  onTap: () => Navigator.pop(
                    context,
                    StatusResult(AttendanceStatus.forseinka, forsinkelsesMinutter: min),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          _StatusOption(
            status: AttendanceStatus.planlagtBorte,
            onTap: () => Navigator.pop(context, const StatusResult(AttendanceStatus.planlagtBorte)),
          ),
          _StatusOption(
            status: AttendanceStatus.ukjent,
            onTap: () => Navigator.pop(context, const StatusResult(AttendanceStatus.ukjent)),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final AttendanceStatus status;
  final VoidCallback onTap;

  const _StatusOption({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(status.symbol, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Text(
              status.label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _DelayChip extends StatelessWidget {
  final int minutes;
  final VoidCallback onTap;

  const _DelayChip({required this.minutes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('+$minutes'),
      backgroundColor: AttendanceStatus.forseinka.color.withValues(alpha: 0.15),
      onPressed: onTap,
    );
  }
}

/// Resultat fra statusvalg.
class StatusResult {
  final AttendanceStatus status;
  final int? forsinkelsesMinutter;

  const StatusResult(this.status, {this.forsinkelsesMinutter});
}
