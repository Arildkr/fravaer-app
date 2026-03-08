import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  final _navnController = TextEditingController();

  @override
  void dispose() {
    _navnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ny gruppe'),
      content: TextField(
        controller: _navnController,
        decoration: const InputDecoration(
          labelText: 'Gruppenavn',
          hintText: 'f.eks. 10A, Tur Hardangervidda',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _createGroup(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: _createGroup,
          child: const Text('Opprett'),
        ),
      ],
    );
  }

  Future<void> _createGroup() async {
    final navn = _navnController.text.trim();
    if (navn.isEmpty) return;

    final laererId = ref.read(activeLaererIdProvider);
    if (laererId == null) return;

    await ref.read(groupRepositoryProvider).createGroup(
          navn: navn,
          laererId: laererId,
        );

    if (mounted) Navigator.pop(context);
  }
}
