import 'package:flutter/material.dart';

class NodeNameDialog extends StatefulWidget {
  const NodeNameDialog({super.key, required this.address, this.current});
  final String address;
  final String? current;

  @override
  State<NodeNameDialog> createState() => _NodeNameDialogState();
}

class _NodeNameDialogState extends State<NodeNameDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Name node'),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.address, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      TextField(
        key: const ValueKey('node-name-input'),
        controller: _name,
        autofocus: true,
        maxLength: 32,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Node name', hintText: 'For example, Front doors',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.of(context).pop(_name.text.trim()),
      ),
      const SizedBox(height: 4),
      Text(
        'Saved on this device. Leave blank to use the address.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.of(context).pop(_name.text.trim()), child: const Text('Save')),
    ],
  );
}
