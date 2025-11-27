import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/report/widgets/barrios_santa_marta.dart';

class NeighborhoodDialog extends StatefulWidget {
  final String? initial;
  const NeighborhoodDialog({super.key, this.initial});

  @override
  State<NeighborhoodDialog> createState() => _NeighborhoodDialogState();
}

class _NeighborhoodDialogState extends State<NeighborhoodDialog> {
  late TextEditingController _controller;
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
    // Start with an empty result list; only show matches when the user types.
    _filtered = [];
    if (_controller.text.trim().isNotEmpty) _filter(_controller.text.trim());
  }

  void _filter(String q) {
    final ql = q.trim().toLowerCase();
    setState(() {
      if (ql.isEmpty) {
        // If nothing typed, show no results (empty)
        _filtered = [];
      } else {
        // When typing, compute matches but only show the first match as a single row
        final matches = ql.length == 1
            ? barriosSantaMarta.where((b) => b.toLowerCase().startsWith(ql)).toList()
            : barriosSantaMarta.where((b) => b.toLowerCase().contains(ql)).toList();
        if (matches.isEmpty) {
          _filtered = [];
        } else {
          _filtered = [matches.first];
        }
      }
    });
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
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Escribe el barrio'),
              onChanged: _filter,
            ),
            const SizedBox(height: 12),
            // Show a single-row list when there is a match; otherwise show nothing.
            if (_filtered.isEmpty)
              const SizedBox.shrink()
            else
              SizedBox(
                height: 56,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final barrio = _filtered[i];
                    return ListTile(
                      title: Text(barrio),
                      onTap: () => Navigator.of(context).pop(barrio),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('Clear')),
        TextButton(onPressed: () => Navigator.of(context).pop(_controller.text.trim()), child: const Text('Apply')),
      ],
    );
  }
}
