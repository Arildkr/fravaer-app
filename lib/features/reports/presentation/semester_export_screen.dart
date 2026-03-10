import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/app_providers.dart';

/// Semester-eksport — velg periode og eksporter CSV med fraværsoversikt.
class SemesterExportScreen extends ConsumerStatefulWidget {
  final GrupperData group;

  const SemesterExportScreen({super.key, required this.group});

  @override
  ConsumerState<SemesterExportScreen> createState() =>
      _SemesterExportScreenState();
}

class _SemesterExportScreenState extends ConsumerState<SemesterExportScreen> {
  late DateTime _fraDato;
  late DateTime _tilDato;
  bool _exporting = false;

  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    // Standard: inneværende halvår
    final now = DateTime.now();
    if (now.month <= 6) {
      _fraDato = DateTime(now.year, 1, 1);
      _tilDato = DateTime(now.year, 6, 30, 23, 59, 59);
    } else {
      _fraDato = DateTime(now.year, 8, 1);
      _tilDato = DateTime(now.year, 12, 31, 23, 59, 59);
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fraDato : _tilDato,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fraDato = picked;
        } else {
          _tilDato = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);

    final l10n = AppLocalizations.of(context)!;

    try {
      final csv = await ref.read(reportRepositoryProvider).generateSemesterCsv(
            gruppeId: widget.group.id,
            fraDato: _fraDato,
            tilDato: _tilDato,
          );

      if (csv.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noSessionsInPeriod)),
          );
        }
        return;
      }

      // Skriv til midlertidig fil og del
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/fravaer_${widget.group.navn.replaceAll(' ', '_')}.csv');
      await file.writeAsString(csv, encoding: latin1);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Fravær ${widget.group.navn}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportError} $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportScreenTitle(widget.group.navn)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.choosePeriod,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.exportCsvDescription),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: l10n.from,
                    date: _dateFormat.format(_fraDato),
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateButton(
                    label: l10n.to,
                    date: _dateFormat.format(_tilDato),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.csvLegend,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _exporting ? null : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download),
                label: Text(l10n.exportCsv),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(date, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
