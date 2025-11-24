import 'package:flutter/material.dart';

class NeighborhoodDialog extends StatefulWidget {
  final String? initial;
  const NeighborhoodDialog({super.key, this.initial});

  @override
  State<NeighborhoodDialog> createState() => _NeighborhoodDialogState();
}

class _NeighborhoodDialogState extends State<NeighborhoodDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar barrio'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Escribe el barrio'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('Clear')),
        TextButton(onPressed: () => Navigator.of(context).pop(_controller.text.trim()), child: const Text('Apply')),
      ],
    );
  }
}
