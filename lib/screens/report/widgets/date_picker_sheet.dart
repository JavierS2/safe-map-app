import 'package:flutter/material.dart';

class DatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;

  const DatePickerSheet({super.key, this.initialDate});

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop({'clear': true}), child: const Text('Clear')),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(context).pop({'date': _temp}), child: const Text('Apply')),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: CalendarDatePicker(
              initialDate: _temp,
              firstDate: DateTime(_temp.year - 5),
              lastDate: DateTime(_temp.year + 5),
              onDateChanged: (d) => setState(() => _temp = d),
            ),
          ),
        ],
      ),
    );
  }
}
