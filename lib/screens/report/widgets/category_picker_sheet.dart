import 'package:flutter/material.dart';

class CategoryPickerSheet extends StatelessWidget {
  final List<String> categories;

  const CategoryPickerSheet({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Clear'),
            onTap: () => Navigator.of(context).pop(''),
          ),
          ...categories.map((c) => ListTile(
                title: Text(c),
                onTap: () => Navigator.of(context).pop(c),
              )),
        ],
      ),
    );
  }
}
