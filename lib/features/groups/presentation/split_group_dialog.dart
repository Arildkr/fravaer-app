import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const Text('Del gruppe'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _navnController,
              decoration: const InputDecoration(
                labelText: 'Navn på ny gruppe',
                hintText: 'f.eks. Turgruppe 1',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Text(
              'Velg elever for den nye gruppen:',
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
                    child: const Text('Velg alle'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedIds.clear());
                    },
                    child: const Text('Fjern alle'),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedIds.length} valgt',
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
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: _selectedIds.isEmpty ? null : _split,
          child: const Text('Opprett gruppe'),
        ),
      ],
    );
  }

  Future<void> _split() async {
    final navn = _navnController.text.trim();
    if (navn.isEmpty || _selectedIds.isEmpty) return;

    final laererId = ref.read(activeLaererIdProvider);
    if (laererId == null) return;

    await ref.read(groupRepositoryProvider).splitGroup(
          sourceGruppeId: widget.group.id,
          nyttNavn: navn,
          laererId: laererId,
          elevIder: _selectedIds.toList(),
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$navn opprettet med ${_selectedIds.length} elever')),
      );
    }
  }
}
