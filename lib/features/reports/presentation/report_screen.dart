import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/app_providers.dart';

/// Rapportskjerm — genererer tekstrapport med ett trykk.
/// Cacher rapporten slik at den kun genereres én gang.
class ReportScreen extends ConsumerStatefulWidget {
  final String oktId;

  const ReportScreen({super.key, required this.oktId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late Future<String> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture =
        ref.read(reportRepositoryProvider).generateReport(widget.oktId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.report),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: l10n.exportPdf,
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.copyToClipboard,
            onPressed: () async {
              final text = await _reportFuture;
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.reportCopied)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.shareReport,
            onPressed: () async {
              final text = await _reportFuture;
              await Share.share(text);
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Feil: ${snapshot.error}'),
            );
          }

          final report = snapshot.data ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    report,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(l10n.exportPdf),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final text = await _reportFuture;
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        final l10n = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.reportCopiedFull),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyReport),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final text = await _reportFuture;
                      await Share.share(text);
                    },
                    icon: const Icon(Icons.share),
                    label: Text(l10n.shareVia),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportPdf() async {
    try {
      final pdfBytes = await ref
          .read(reportRepositoryProvider)
          .generatePdfReport(widget.oktId);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'fravaersrapport.pdf',
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.pdfExportError} $e')),
        );
      }
    }
  }
}
