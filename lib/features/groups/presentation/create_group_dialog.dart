import 'package:flutter/material.dart';
import 'package:fravaer_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.newGroup),
      content: TextField(
        controller: _navnController,
        decoration: InputDecoration(
          labelText: l10n.groupNameLabel,
          hintText: l10n.groupNameHint,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _createGroup(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _createGroup,
          child: Text(l10n.create),
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
