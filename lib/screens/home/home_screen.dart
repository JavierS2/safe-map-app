import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'widgets/home_header.dart';
import 'widgets/incident_summary_card.dart';
import 'widgets/latest_reports_title.dart';
import 'widgets/report_item_card.dart';
import 'widgets/safe_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      const ReportItemData(
        neighborhood: 'El Líbano',
        dateTime: '30/10/2025 - 07:20',
        type: 'Hurto simple',
      ),
      const ReportItemData(
        neighborhood: 'Mamatoco',
        dateTime: '29/10/2025 - 20:15',
        type: 'Robo violento',
      ),
      const ReportItemData(
        neighborhood: 'El Prado',
        dateTime: '29/10/2025 - 14:50',
        type: 'Hurto simple',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(),
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
                      const HomeHeader(
                        userName: 'Eduardo',
                        greeting: 'Buenos días',
                      ),

                      // Extend the blue background a bit lower so the
                      // rounded white panel overlays blue instead of the
                      // light app background (prevents a straight white
                      // rectangle showing through the curves).
                      Container(
                        height: 48,
                        color: AppColors.primary,
                      ),

                      // White panel under header with rounded top corners
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, -32),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAFFFD),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: IncidentSummaryCard(
                                    totalToday: 53,
                                    onReportNow: () {
                                      Navigator.pushNamed(context, '/create-report');
                                    },
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(height: 24),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: LatestReportsTitle(),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: reports
                                        .map(
                                          (r) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: ReportItemCard(
                                              data: r,
                                              onDetailsPressed: () {},
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
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
