import 'package:flutter/material.dart';

class DateInput extends StatefulWidget {
  final TextEditingController controller;

  const DateInput({super.key, required this.controller});

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  Future _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      widget.controller.text =
          "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFA9EEFF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "DD / MM / YYYY",
              hintStyle: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ),
      ),
    );
  }
}
