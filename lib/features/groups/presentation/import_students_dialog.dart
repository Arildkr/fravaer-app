import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class ImportStudentsDialog extends ConsumerStatefulWidget {
  final String gruppeId;

  const ImportStudentsDialog({super.key, required this.gruppeId});

  @override
  ConsumerState<ImportStudentsDialog> createState() =>
      _ImportStudentsDialogState();
}

class _ImportStudentsDialogState extends ConsumerState<ImportStudentsDialog> {
  final _controller = TextEditingController();
  bool _importing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importer elever'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lim inn elevliste (ett navn per linje).\n'
              'Format: Navn eller Navn;ElevID',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ola Nordmann\nKari Hansen\nPer Olsen;12345',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.pop(context),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: _importing ? null : _import,
          child: _importing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Importer'),
        ),
      ],
    );
  }

  Future<void> _import() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _importing = true);

    final count = await ref.read(groupRepositoryProvider).importStudentsFromText(
          text: text,
          gruppeId: widget.gruppeId,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count elever importert')),
      );
    }
  }
}
