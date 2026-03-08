import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/file_import_service.dart';

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

  // Filimport-tilstand
  ImportPreview? _preview;
  bool _parsingFile = false;
  String? _fileError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vis forhåndsvisning hvis vi har parset en fil
    if (_preview != null) {
      return _buildPreviewDialog();
    }

    return AlertDialog(
      title: const Text('Importer elever'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filimport-knapp
            OutlinedButton.icon(
              onPressed: _parsingFile ? null : _pickFile,
              icon: _parsingFile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_parsingFile
                  ? 'Leser fil...'
                  : 'Velg fil (.xlsx, .csv)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            if (_fileError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _fileError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('eller', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            // Manuell innliming
            const Text(
              'Lim inn elevliste (ett navn per linje)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ola Nordmann\nKari Hansen',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              minLines: 4,
              style: const TextStyle(fontSize: 16),
            ),
            // Tooltip
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Skriv navn i kolonne A. Etternavn kan legges i kolonne B. '
                'Første rad kan være overskrift — appen finner ut av det automatisk.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
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
          onPressed: _importing ? null : _importFromText,
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

  Widget _buildPreviewDialog() {
    final preview = _preview!;
    return AlertDialog(
      title: const Text('Forhåndsvisning'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fant ${preview.names.length} elever'
                      '${preview.hadHeader ? ' (overskriftsrad hoppet over)' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ser dette riktig ut?',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            // Elevliste med scrolling
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: preview.names.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            preview.names[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _preview = null;
            _fileError = null;
          }),
          child: const Text('Tilbake'),
        ),
        FilledButton(
          onPressed: _importing ? null : _importFromPreview,
          child: _importing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Importer ${preview.names.length} elever'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _parsingFile = true;
      _fileError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'ods', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _parsingFile = false);
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        setState(() {
          _parsingFile = false;
          _fileError = 'Kunne ikke lese filen';
        });
        return;
      }

      final preview = await FileImportService.parseFile(File(filePath));

      if (preview.names.isEmpty) {
        setState(() {
          _parsingFile = false;
          _fileError = 'Fant ingen navn i filen';
        });
        return;
      }

      setState(() {
        _parsingFile = false;
        _preview = preview;
      });
    } catch (e) {
      setState(() {
        _parsingFile = false;
        _fileError = 'Kunne ikke lese filen: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _importFromPreview() async {
    if (_preview == null) return;

    setState(() => _importing = true);

    final repo = ref.read(groupRepositoryProvider);
    int count = 0;
    for (final name in _preview!.names) {
      await repo.addStudentToGroup(
        elevNavn: name,
        gruppeId: widget.gruppeId,
      );
      count++;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count elever importert')),
      );
    }
  }

  Future<void> _importFromText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _importing = true);

    final count =
        await ref.read(groupRepositoryProvider).importStudentsFromText(
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
