import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';

class LayoutOutputEditor extends StatefulWidget {
  final LayoutEditorController controller;
  final bool advanced;
  const LayoutOutputEditor({
    super.key,
    required this.controller,
    this.advanced = true,
  });
  @override
  State<LayoutOutputEditor> createState() => _LayoutOutputEditorState();
}

class _LayoutOutputEditorState extends State<LayoutOutputEditor> {
  late final TextEditingController _name, _position, _length;
  final _positionFocus = FocusNode(),
      _nameFocus = FocusNode(),
      _lengthFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    final row = widget.controller.selected!;
    _name = TextEditingController(text: widget.controller.titleFor(row));
    _position = TextEditingController(text: '${math.min(row.from, row.to)}');
    _length = TextEditingController(
      text: '${widget.controller.lengthFor(row)}',
    );
  }

  @override
  void didUpdateWidget(covariant LayoutOutputEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final row = widget.controller.selected!;
    if (!_positionFocus.hasFocus) {
      _position.text = '${math.min(row.from, row.to)}';
    }
    if (!_nameFocus.hasFocus && _name.text != widget.controller.titleFor(row)) {
      _name.text = widget.controller.titleFor(row);
    }
    if (!_lengthFocus.hasFocus) {
      _length.text = '${widget.controller.lengthFor(row)}';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _length.dispose();
    _positionFocus.dispose();
    _nameFocus.dispose();
    _lengthFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = widget.controller, row = editor.selected!;
    final key = placementKey(row), output = editor.outputFor(key);
    final point = isPointSource(output);
    final theme = Theme.of(context), colors = theme.colorScheme;
    final editable = !editor.busy && output?.known == true;
    final position = math.min(row.from, row.to), length = editor.lengthFor(row);
    void step(int change) {
      _positionFocus.unfocus();
      editor.move(key, position + change);
      _position.text =
          '${math.min(editor.selected!.from, editor.selected!.to)}';
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.advanced) ...[
              Icon(Icons.tune, color: colors.primary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                widget.advanced
                    ? (point ? 'Selected light' : 'Selected output')
                    : 'Light settings',
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (widget.advanced) IconButton(
              tooltip: 'Remove from layout',
              onPressed: editor.busy
                  ? null
                  : () => editor.remove(key, continuous: !widget.advanced),
              icon: const Icon(Icons.delete_outline),
            ) else TextButton.icon(
              onPressed: editor.busy ? null : () => editor.remove(key, continuous: true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('layout-name'),
          controller: _name,
          focusNode: _nameFocus,
          maxLength: 32,
          enabled: !editor.busy,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: editor.titleFor(row),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => editor.rename(key, value),
        ),
        const SizedBox(height: 4),
        if (!point) ...[
          TextField(
            key: const ValueKey('layout-length'),
            controller: _length,
            focusNode: _lengthFocus,
            enabled: editable,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Strip length · LEDs',
              border: const OutlineInputBorder(),
              errorText: editor.lengthError,
              helperText: output == null
                  ? 'Connect the node to set its length.'
                  : '1–${editor.maximumFor(output)} LEDs · Identify tests the draft before saving.',
              helperMaxLines: 2,
            ),
            onChanged: (value) =>
                editor.resize(key, value, continuous: !widget.advanced),
          ),
          const SizedBox(height: 14),
        ],
        if (widget.advanced)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('layout-position'),
                  controller: _position,
                  focusNode: _positionFocus,
                  enabled: editable,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Position',
                    border: const OutlineInputBorder(),
                    errorText: editor.fieldError,
                  ),
                  onChanged: (value) => editor.positionText(key, value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Move one pixel left',
                onPressed: editable && position > 0 ? () => step(-1) : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: 'Move one pixel right',
                onPressed: editable && position + length < 65536
                    ? () => step(1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        const SizedBox(height: 10),
        if (widget.advanced || point) Row(
          children: [
            Icon(
              point ? Icons.lightbulb_outline : Icons.straighten,
              size: 15,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                point
                    ? 'RGB LED ${row.sourceIndex + 1} · driver ${row.driver.value}'
                    : '$length LEDs · ${output?.known == true ? 'configured length' : 'connect node to verify length'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (!point)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reverse direction'),
            subtitle: Text(widget.advanced
                ? 'Mapping ${row.from} → ${row.to}'
                : 'Reverse the animation direction along this strip.'),
            value: row.from > row.to,
            onChanged: editable ? (_) => editor.reverse(key) : null,
          ),
        const Divider(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                !editor.busy &&
                    editor.lengthError == null &&
                    editor.connected &&
                    output?.online == true &&
                    output?.ready == true
                ? () => editor.identify(key)
                : null,
            icon: editor.identifyingKey == key
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flashlight_on_outlined),
            label: Text(
              output?.online == true
                  ? 'Identify lights'
                  : 'Identify · node offline',
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          point ? 'Only this LED pulses green for three seconds.' : 'The strip fills green in this direction over two seconds, then holds fully lit for one second. Blue marks the end.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
    if (!widget.advanced) return content;
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: content),
    );
  }
}
