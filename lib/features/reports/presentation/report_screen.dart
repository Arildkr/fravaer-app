import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/app_providers.dart';

/// Rapportskjerm — genererer Visma-formatert tekstrapport med ett trykk.
/// Deling via utklippstavle, e-post, SMS etc.
class ReportScreen extends ConsumerWidget {
  final String oktId;

  const ReportScreen({super.key, required this.oktId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportRepo = ref.watch(reportRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Kopier til utklippstavle',
            onPressed: () async {
              final text = await reportRepo.generateReport(oktId);
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rapport kopiert')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Del rapport',
            onPressed: () async {
              final text = await reportRepo.generateReport(oktId);
              await Share.share(text);
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: reportRepo.generateReport(oktId),
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
                    onPressed: () async {
                      final text = await reportRepo.generateReport(oktId);
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rapport kopiert til utklippstavle'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Kopier rapport'),
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
                      final text = await reportRepo.generateReport(oktId);
                      await Share.share(text);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Del via...'),
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
}
