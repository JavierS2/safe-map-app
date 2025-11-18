import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import 'widgets/notification_section.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final notifications = <Map<String, dynamic>>[
      {
        'title': 'Reportaron Un Robo Cerca De Ti',
        'body': 'Reporte de robo calle 33 carrera 12, barrio cantilito.',
        'date': now,
      },
      {
        'title': 'Mira Los Ultimos Reportes En Tu Zona',
        'body': 'Resumen de los últimos atracos y robos cerca de tu zona.',
        'date': now.subtract(const Duration(days: 0)),
      },
      {
        'title': 'Reportaron Un Robo Cerca De Ti',
        'body': 'Reporte de robo calle 12 carrera 33, barrio galicia.',
        'date': now.subtract(const Duration(days: 1)),
      },
      {
        'title': 'Reportaron Un Robo Cerca De Ti',
        'body': 'Reporte de robo calle 34 carrera 14, barrio primero de mayo.',
        'date': now.subtract(const Duration(days: 3)),
      },
    ];

    String _monthName(int m) {
      const names = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return names[m - 1];
    }

    

    // Group notifications into Today / Yesterday / Others
    Map<String, List<Map<String, dynamic>>> groupNotifications(List<Map<String, dynamic>> items) {
      final Map<String, List<Map<String, dynamic>>> groups = {};
      for (final it in items) {
        final DateTime d = it['date'] as DateTime;
        final diff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
        String key;
        if (diff == 0) {
          key = 'Hoy';
        } else if (diff == 1) {
          key = 'Ayer';
        } else {
          // format like 'Apr 24'
          key = '${_monthName(d.month)} ${d.day}';
        }
        groups.putIfAbsent(key, () => []).add(it);
      }
      return groups;
    }

    final grouped = groupNotifications(notifications);
    final sectionKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.notification),
      body: SafeArea(
        child: LayoutBuilder(
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
                                if (notifications.isEmpty) ...[
                                  const Center(child: Text('No notifications')),
                                ] else ...[
                                  for (var i = 0; i < sectionKeys.length; i++)
                                    NotificationSection(title: sectionKeys[i], items: grouped[sectionKeys[i]]!),
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
        ),
      ),
    );
  }
}
