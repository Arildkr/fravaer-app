import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.importStudents),
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
                  ? l10n.readingFile
                  : l10n.chooseFile),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.orSeparator, style: const TextStyle(color: Colors.grey)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
            // Manuell innliming
            Text(
              l10n.pasteStudentList,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.importHint,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _importing ? null : _importFromText,
          child: _importing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.importAction),
        ),
      ],
    );
  }

  Widget _buildPreviewDialog() {
    final preview = _preview!;
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.previewTitle),
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
                      l10n.foundStudentsCount(preview.names.length) +
                          (preview.hadHeader ? ' ${l10n.headerSkipped}' : ''),
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
              l10n.doesThisLookRight,
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
          child: Text(l10n.back),
        ),
        FilledButton(
          onPressed: _importing ? null : _importFromPreview,
          child: _importing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.importCountStudents(preview.names.length)),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _parsingFile = true;
      _fileError = null;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true, // last bytes direkte — nødvendig for Google Drive-filer
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _parsingFile = false);
        return;
      }

      final picked = result.files.single;
      final bytes = picked.bytes;
      final fileName = picked.name;

      final ImportPreview preview;
      if (bytes != null && bytes.isNotEmpty) {
        // Foretrekk bytes (fungerer alltid, også fra Google Drive)
        preview = FileImportService.parseBytes(bytes, fileName);
      } else if (picked.path != null) {
        // Fallback til filsti
        preview = await FileImportService.parseFile(File(picked.path!));
      } else {
        setState(() {
          _parsingFile = false;
          _fileError = l10n.couldNotReadFile;
        });
        return;
      }

      if (preview.names.isEmpty) {
        setState(() {
          _parsingFile = false;
          _fileError = l10n.noNamesFound;
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
        _fileError = '${l10n.couldNotReadFile}: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _importFromPreview() async {
    if (_preview == null) return;

    setState(() => _importing = true);

    final repo = ref.read(groupRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.studentsImported(count))),
      );
    }
  }

  Future<void> _importFromText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _importing = true);

    final l10n = AppLocalizations.of(context)!;

    final count =
        await ref.read(groupRepositoryProvider).importStudentsFromText(
              text: text,
              gruppeId: widget.gruppeId,
            );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.studentsImported(count))),
      );
    }
  }
}
