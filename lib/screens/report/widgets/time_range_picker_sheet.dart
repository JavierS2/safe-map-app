import 'package:flutter/material.dart';

class TimeRangePickerSheet extends StatefulWidget {
  final TimeOfDay? start;
  final TimeOfDay? end;

  const TimeRangePickerSheet({super.key, this.start, this.end});

  @override
  State<TimeRangePickerSheet> createState() => _TimeRangePickerSheetState();
}

class _TimeRangePickerSheetState extends State<TimeRangePickerSheet> {
  TimeOfDay? _start;
  TimeOfDay? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _end = widget.end;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StatefulBuilder(builder: (ctx, setStateSB) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop({'clear': true}), child: const Text('Clear')),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  TextButton(onPressed: () {
                    if (_start != null && _end != null) {
                      final s = _start!.hour * 60 + _start!.minute;
                      final e = _end!.hour * 60 + _end!.minute;
                      if (s > e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La hora de inicio no puede ser mayor que la hora fin')));
                        return;
                      }
                    }
                    Navigator.of(context).pop({'start': _start, 'end': _end});
                  }, child: const Text('Apply')),
                ],
              ),
            ),
            ListTile(
              title: const Text('Hora inicio'),
              subtitle: Text(_start?.format(context) ?? 'No establecido'),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _start ?? const TimeOfDay(hour: 0, minute: 0));
                if (picked != null) setStateSB(() => _start = picked);
              },
            ),
            ListTile(
              title: const Text('Hora fin'),
              subtitle: Text(_end?.format(context) ?? 'No establecido'),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _end ?? const TimeOfDay(hour: 23, minute: 59));
                if (picked != null) setStateSB(() => _end = picked);
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}
