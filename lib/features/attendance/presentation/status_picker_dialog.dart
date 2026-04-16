import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/status_helpers.dart';

/// Dialog for å velge status og skrive merknad.
/// Store trykkeflater for utendørs bruk.
class StatusPickerDialog extends StatefulWidget {
  final String elevNavn;
  final String? currentMerknad;
  final bool isUtsjekkFase;
  final AttendanceStatus currentStatus;

  const StatusPickerDialog({
    super.key,
    required this.elevNavn,
    required this.currentStatus,
    this.currentMerknad,
    this.isUtsjekkFase = false,
  });

  @override
  State<StatusPickerDialog> createState() => _StatusPickerDialogState();
}

class _StatusPickerDialogState extends State<StatusPickerDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.currentMerknad ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _pop(StatusResult result) {
    final merknad = _noteController.text.trim();
    Navigator.pop(
      context,
      StatusResult(result.status,
          forsinkelsesMinutter: result.forsinkelsesMinutter,
          merknad: merknad.isEmpty ? null : merknad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.elevNavn,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ValueListenableBuilder(
          valueListenable: _noteController,
          builder: (_, value, __) => FilledButton(
            onPressed: () => _pop(StatusResult(widget.currentStatus)),
            child: Text(l10n.save),
          ),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Merknads-felt øverst
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.noteLabel,
                hintText: l10n.noteHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit_note),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _noteController,
                  builder: (_, value, __) => value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _noteController.clear(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              maxLines: 2,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 20),
            _StatusOption(
              status: AttendanceStatus.tilStede,
              onTap: () => _pop(const StatusResult(AttendanceStatus.tilStede)),
            ),
            const SizedBox(height: 6),
            _StatusOption(
              status: AttendanceStatus.utsjekket,
              labelOverride: widget.isUtsjekkFase ? null : l10n.statusPlannedAbsent,
              onTap: () => _pop(const StatusResult(AttendanceStatus.utsjekket)),
            ),
            const SizedBox(height: 6),
            _StatusOption(
              status: AttendanceStatus.fravaer,
              onTap: () => _pop(const StatusResult(AttendanceStatus.fravaer)),
            ),
            const Divider(height: 20),
            // Hurtigval for forsinkelse
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.lateLabel,
                  style: const TextStyle(
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
                    onTap: () => _pop(StatusResult(AttendanceStatus.forseinka,
                        forsinkelsesMinutter: min)),
                  ),
                _CustomDelayChip(
                  onMinutes: (min) => _pop(StatusResult(
                      AttendanceStatus.forseinka,
                      forsinkelsesMinutter: min)),
                ),
              ],
            ),
            const Divider(height: 20),
            _StatusOption(
              status: AttendanceStatus.ukjent,
              onTap: () => _pop(const StatusResult(AttendanceStatus.ukjent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final AttendanceStatus status;
  final VoidCallback onTap;
  final String? labelOverride;

  const _StatusOption({required this.status, required this.onTap, this.labelOverride});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                labelOverride ?? status.labelOf(l10n),
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

class _CustomDelayChip extends StatelessWidget {
  final void Function(int minutes) onMinutes;

  const _CustomDelayChip({required this.onMinutes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ActionChip(
        label: const Text(
          '…',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor:
            AttendanceStatus.forseinka.color.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onPressed: () async {
          final controller = TextEditingController();
          final result = await showDialog<int>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Antall minutter'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutter forsinket',
                  border: OutlineInputBorder(),
                  suffixText: 'min',
                ),
                autofocus: true,
                onSubmitted: (_) {
                  final v = int.tryParse(controller.text);
                  if (v != null && v > 0) Navigator.pop(ctx, v);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Avbryt'),
                ),
                FilledButton(
                  onPressed: () {
                    final v = int.tryParse(controller.text);
                    if (v != null && v > 0) Navigator.pop(ctx, v);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (result != null) onMinutes(result);
        },
      ),
    );
  }
}

/// Resultat fra statusvalg, inkl. eventuell merknad.
class StatusResult {
  final AttendanceStatus status;
  final int? forsinkelsesMinutter;
  final String? merknad;

  const StatusResult(this.status, {this.forsinkelsesMinutter, this.merknad});
}
