import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import 'widgets/notification_section.dart';
import '../../providers/auth_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  String _monthName(int m) {
    const names = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return names[m - 1];
  }

  // Group notifications into Today / Yesterday / Others
  Map<String, List<Map<String, dynamic>>> groupNotifications(List<Map<String, dynamic>> items) {
    final now = DateTime.now();
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final it in items) {
      final DateTime d = it['date'] as DateTime;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(d.year, d.month, d.day))
          .inDays;
      String key;
      if (diff == 0) {
        key = 'Hoy';
      } else if (diff == 1) {
        key = 'Ayer';
      } else {
        key = '${_monthName(d.month)} ${d.day}';
      }
      groups.putIfAbsent(key, () => []).add(it);
    }

    // Sort notifications inside each group by time (newest first)
    for (final entry in groups.entries) {
      entry.value.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    }

    return groups;
  }

  Widget _buildNotificationsLayout(Map<String, List<Map<String, dynamic>>> grouped, List<String> sectionKeys, {void Function(Map<String, dynamic>)? onTapItem, VoidCallback? onMarkAll}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ReportHeader(title: 'Notificaciones'),
                  Container(height: 48, color: AppColors.primary),

                  // White panel under header with rounded top corners
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -32),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFFFD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                              const SizedBox(height: 12),
                              // Top Row: mark all as read
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: onMarkAll,
                                  child: const Text('Marcar todas como leídas'),
                                ),
                              ),
                              if (grouped.isEmpty) ...[
                                const Center(child: Text('No hay notificaciones')),
                              ] else ...[
                                for (var i = 0; i < sectionKeys.length; i++)
                                  NotificationSection(
                                    title: sectionKeys[i],
                                    items: grouped[sectionKeys[i]]!,
                                    onTapItem: onTapItem,
                                  ),
                              ],
                              const Spacer(),
                            ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.notification),
        body: const SafeArea(
          child: Center(child: Text('No authenticated user')),
        ),
      );
    }

    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.notification),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: userStream,
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userDocs = userSnap.data?.docs ?? [];
            final userNotifications = userDocs.map((d) {
              final data = d.data();
              final ts = data['createdAt'] as Timestamp?;
              return {
                'id': 'user_${d.id}',
                'title': data['title'] ?? '',
                'body': data['body'] ?? '',
                'reportId': data['reportId'],
                'date': ts != null ? ts.toDate() : DateTime.now(),
                'read': data['read'] ?? false,
              };
            }).toList();

            final cityStream = FirebaseFirestore.instance
                .collection('city_notifications')
                .orderBy('createdAt', descending: true)
                .snapshots();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: cityStream,
              builder: (context, citySnap) {
                if (citySnap.connectionState == ConnectionState.waiting && userNotifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cityDocs = citySnap.data?.docs ?? [];
                final cityNotifications = cityDocs.map((d) {
                  final data = d.data();
                  final ts = data['createdAt'] as Timestamp?;
                  return {
                    'id': 'city_${d.id}',
                    'title': data['title'] ?? '',
                    'body': data['body'] ?? '',
                    'reportId': data['reportId'],
                    'date': ts != null ? ts.toDate() : DateTime.now(),
                    'read': false,
                  };
                }).toList();

                // Merge city notifications with user notifications, avoiding duplicates by reportId+title
                final combined = [...cityNotifications, ...userNotifications];
                final seen = <String>{};
                final merged = <Map<String, dynamic>>[];
                for (final n in combined) {
                  final key = '${n['reportId'] ?? ''}-${n['title'] ?? ''}';
                  if (seen.contains(key)) continue;
                  seen.add(key);
                  merged.add(n);
                }

                final grouped = groupNotifications(merged);
                // Order section keys: Hoy, Ayer, then other dates by newest first
                final sectionKeys = grouped.keys.toList();
                sectionKeys.sort((a, b) {
                  if (a == 'Hoy' && b != 'Hoy') return -1;
                  if (b == 'Hoy' && a != 'Hoy') return 1;
                  if (a == 'Ayer' && b != 'Ayer') return -1;
                  if (b == 'Ayer' && a != 'Ayer') return 1;
                  // For other keys, use the first item's date (groups are already sorted newest-first)
                  final aDate = grouped[a]!.isNotEmpty ? grouped[a]!.first['date'] as DateTime : DateTime.fromMillisecondsSinceEpoch(0);
                  final bDate = grouped[b]!.isNotEmpty ? grouped[b]!.first['date'] as DateTime : DateTime.fromMillisecondsSinceEpoch(0);
                  return bDate.compareTo(aDate);
                });

                // helper to mark all as read for current user
                Future<void> _markAllAsRead() async {
                  try {
                    final batch = FirebaseFirestore.instance.batch();
                    final unreadSnap = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('notifications')
                        .where('read', isEqualTo: false)
                        .get();
                    for (final d in unreadSnap.docs) {
                      batch.update(d.reference, {'read': true});
                    }
                    if (unreadSnap.docs.isNotEmpty) await batch.commit();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error marcando notificaciones')));
                  }
                }

                // handler when tapping a notification
                void _onTapNotification(Map<String, dynamic> n) async {
                  // Show detail dialog with 'Ver' button when there's a reportId
                  final reportId = (n['reportId'] ?? '')?.toString();
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(n['title'] ?? ''),
                      content: Text(n['body'] ?? ''),
                      actions: [
                        if (reportId != null && reportId.isNotEmpty)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, AppRoutes.viewDetails, arguments: {'reportId': reportId});
                            },
                            child: const Text('Ver', style: TextStyle(color: Colors.white)),
                          ),
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
                      ],
                    ),
                  );

                  // If it's a user-specific notification, mark it read
                  final id = n['id'] as String? ?? '';
                  if (id.startsWith('user_')) {
                    final docId = id.substring(5);
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('notifications')
                          .doc(docId)
                          .update({'read': true});
                    } catch (e) {
                      // ignore
                    }
                  }
                }

                // Return the notifications layout, passing handlers for mark-all and item taps
                return _buildNotificationsLayout(grouped, sectionKeys, onTapItem: _onTapNotification, onMarkAll: _markAllAsRead);
              },
            );
          },
        ),
      ),
    );
  }
}
