import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/status_helpers.dart';

/// Dialog for å velge status. Store trykkeflater for utendørs bruk.
class StatusPickerDialog extends StatelessWidget {
  final String elevNavn;

  const StatusPickerDialog({super.key, required this.elevNavn});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        elevNavn,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusOption(
            status: AttendanceStatus.tilStede,
            onTap: () => Navigator.pop(
                context, const StatusResult(AttendanceStatus.tilStede)),
          ),
          const SizedBox(height: 6),
          _StatusOption(
            status: AttendanceStatus.fravaer,
            onTap: () => Navigator.pop(
                context, const StatusResult(AttendanceStatus.fravaer)),
          ),
          const Divider(height: 20),
          // Hurtigval for forsinkelse
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Forsinket:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333))),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final min in [5, 10, 15, 20, 30, 45, 60])
                _DelayChip(
                  minutes: min,
                  onTap: () => Navigator.pop(
                    context,
                    StatusResult(AttendanceStatus.forseinka,
                        forsinkelsesMinutter: min),
                  ),
                ),
            ],
          ),
          const Divider(height: 20),
          _StatusOption(
            status: AttendanceStatus.planlagtBorte,
            onTap: () => Navigator.pop(context,
                const StatusResult(AttendanceStatus.planlagtBorte)),
          ),
          const SizedBox(height: 6),
          _StatusOption(
            status: AttendanceStatus.ukjent,
            onTap: () => Navigator.pop(
                context, const StatusResult(AttendanceStatus.ukjent)),
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
    return Material(
      color: status.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child:
                    Text(status.symbol, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Text(
                status.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
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
    return SizedBox(
      height: 48,
      child: ActionChip(
        label: Text(
          '+$minutes',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor:
            AttendanceStatus.forseinka.color.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onPressed: onTap,
      ),
    );
  }
}

/// Resultat fra statusvalg.
class StatusResult {
  final AttendanceStatus status;
  final int? forsinkelsesMinutter;

  const StatusResult(this.status, {this.forsinkelsesMinutter});
}
