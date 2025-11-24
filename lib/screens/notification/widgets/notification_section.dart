import 'package:flutter/material.dart';
import 'notification_item.dart';

class NotificationSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>)? onTapItem;

  const NotificationSection({Key? key, required this.title, required this.items, this.onTapItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> itemWidgets = [];
    for (var i = 0; i < items.length; i++) {
      final n = items[i];
      final DateTime d = n['date'] as DateTime;
      itemWidgets.add(NotificationItem(
        title: n['title'] ?? '',
        body: n['body'] ?? '',
        date: d,
        onTap: onTapItem != null ? () => onTapItem!(n) : null,
      ));
      // add divider after every item
      itemWidgets.add(const SizedBox(height: 8));
      itemWidgets.add(const Divider(thickness: 1));
      itemWidgets.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        Column(children: itemWidgets),
      ],
    );
  }
}
