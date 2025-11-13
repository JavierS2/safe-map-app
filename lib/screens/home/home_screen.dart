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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(
                userName: 'Eduardo',
                greeting: 'Buenos días',
              ),
              const SizedBox(height: 16),
              
              // ----------- CAMBIO AQUÍ -----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IncidentSummaryCard(
                  totalToday: 53,
                  onReportNow: () {
                    Navigator.pushNamed(context, '/create-report');
                  },
                ),
              ),
              // -----------------------------------

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
                            onDetailsPressed: () {
                            },
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
    );
  }
}
