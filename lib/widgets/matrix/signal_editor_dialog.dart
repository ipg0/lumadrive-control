import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';

class SignalEditorDialog extends StatefulWidget {
  final SignalGenerator signal;
  const SignalEditorDialog({super.key, required this.signal});
  @override
  State<SignalEditorDialog> createState() => _SignalEditorDialogState();
}

class _SignalEditorDialogState extends State<SignalEditorDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, period, amplitude, offset, phase;
  late SignalGenerator_Kind kind;
  @override
  void initState() {
    super.initState();
    final s = widget.signal;
    name = TextEditingController(text: s.name);
    period = TextEditingController(text: '${s.periodMs}');
    amplitude = TextEditingController(text: '${s.amplitude}');
    offset = TextEditingController(text: '${s.offset}');
    phase = TextEditingController(text: '${s.phase}');
    kind = s.kind;
  }

  @override
  void dispose() {
    for (final c in [name, period, amplitude, offset, phase]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Signal generator'),
    content: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              maxLength: 32,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a name' : null,
            ),
            DropdownButtonFormField<SignalGenerator_Kind>(
              initialValue: kind,
              decoration: const InputDecoration(labelText: 'Waveform'),
              items: const [
                DropdownMenuItem(
                  value: SignalGenerator_Kind.SINE,
                  child: Text('Sine'),
                ),
                DropdownMenuItem(
                  value: SignalGenerator_Kind.TRIANGLE,
                  child: Text('Triangle'),
                ),
                DropdownMenuItem(
                  value: SignalGenerator_Kind.SQUARE,
                  child: Text('Square'),
                ),
                DropdownMenuItem(
                  value: SignalGenerator_Kind.SAWTOOTH,
                  child: Text('Sawtooth'),
                ),
                DropdownMenuItem(
                  value: SignalGenerator_Kind.REVERSE_SAWTOOTH,
                  child: Text('Reverse sawtooth'),
                ),
              ],
              onChanged: (v) => setState(() => kind = v!),
            ),
            TextFormField(
              controller: period,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Period (ms)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 20 || n > 0xffffffff
                    ? 'Enter at least 20 ms'
                    : null;
              },
            ),
            for (final pair in [
              (amplitude, 'Amplitude'),
              (offset, 'Offset'),
              (phase, 'Phase offset (cycles)'),
            ])
              TextFormField(
                controller: pair.$1,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: pair.$2),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return n == null || !n.isFinite
                      ? 'Enter a finite number'
                      : null;
                },
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(
            context,
            widget.signal.deepCopy()
              ..name = name.text.trim()
              ..kind = kind
              ..periodMs = int.parse(period.text)
              ..amplitude = double.parse(amplitude.text)
              ..offset = double.parse(offset.text)
              ..phase = double.parse(phase.text),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}
