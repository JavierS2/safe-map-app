import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String body;
  final DateTime date;
  final VoidCallback? onTap;

  const NotificationItem({Key? key, required this.title, required this.body, required this.date, this.onTap}) : super(key: key);

  String _monthName(int m) {
    const names = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return names[m - 1];
  }

  String _timeStr(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm - ${_monthName(d.month)} ${d.day}';
  }

  String _sentenceCase(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final time = _timeStr(date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
        ),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.notifications_none, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sentenceCase(title), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(_sentenceCase(body), style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: Text(time, style: TextStyle(color: AppColors.primary, fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
