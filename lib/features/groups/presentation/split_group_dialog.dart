import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/app_providers.dart';

/// Dialog for å dele en gruppe — velg elever som skal inn i ny gruppe.
class SplitGroupDialog extends ConsumerStatefulWidget {
  final GrupperData group;

  const SplitGroupDialog({super.key, required this.group});

  @override
  ConsumerState<SplitGroupDialog> createState() => _SplitGroupDialogState();
}

class _SplitGroupDialogState extends ConsumerState<SplitGroupDialog> {
  final _navnController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<EleverData>? _members;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await ref
        .read(groupRepositoryProvider)
        .getGroupMembers(widget.group.id);
    if (mounted) {
      setState(() {
        _members = members;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _navnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.splitGroupTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _navnController,
              decoration: InputDecoration(
                labelText: l10n.newGroupNameLabel,
                hintText: l10n.splitGroupNewGroupHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.selectStudentsForNewGroup,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else
              // Velg alle / ingen
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIds.addAll(_members!.map((m) => m.id));
                      });
                    },
                    child: Text(l10n.selectAll),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedIds.clear());
                    },
                    child: Text(l10n.clearAll),
                  ),
                  const Spacer(),
                  Text(
                    l10n.selectedCount(_selectedIds.length),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            if (!_loading)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _members?.length ?? 0,
                  itemBuilder: (context, index) {
                    final elev = _members![index];
                    final selected = _selectedIds.contains(elev.id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(elev.navn, style: const TextStyle(fontSize: 16)),
                      dense: true,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedIds.add(elev.id);
                          } else {
                            _selectedIds.remove(elev.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selectedIds.isEmpty ? null : _split,
          child: Text(l10n.createGroup),
        ),
      ],
    );
  }

  Future<void> _split() async {
    final navn = _navnController.text.trim();
    if (navn.isEmpty || _selectedIds.isEmpty) return;

    final laererId = ref.read(activeLaererIdProvider);
    if (laererId == null) return;

    final l10n = AppLocalizations.of(context)!;

    await ref.read(groupRepositoryProvider).splitGroup(
          sourceGruppeId: widget.group.id,
          nyttNavn: navn,
          laererId: laererId,
          elevIder: _selectedIds.toList(),
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupCreatedWithStudents(navn, _selectedIds.length))),
      );
    }
  }
}
