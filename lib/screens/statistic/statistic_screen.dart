import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import 'widgets/top_list.dart';
import 'widgets/donut_chart.dart';
import 'widgets/legend_item.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.statistic),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // reduce reserved bottom space so navbar sits flush with content
              padding: const EdgeInsets.only(bottom: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReportHeader(title: 'Estadísticas'),

                      // blue extension
                      Container(height: 48, color: AppColors.primary),

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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top ranking list
                                Text(
                                  'Ranking barrios',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),

                                const SizedBox(height: 8),
                                const TopList(),

                                const SizedBox(height: 8),

                                // Hour ranking + donut chart
                                Text(
                                  'Ranking de horas con mayores reportes',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text('From 1-6 Dec, 2021', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 12),

                                // Donut centered with legend rows beneath
                                Column(
                                  children: [
                                    Center(
                                      child: DonutChart(
                                        values: [0.4, 0.32, 0.28],
                                        colors: const [Color(0xFF6C5CE7), Color(0xFFFF6B9A), Color(0xFF00B2FF)],
                                        size: 140,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Builder(builder: (context) {
                                      final maxWidth = MediaQuery.of(context).size.width - 32; // account for horizontal padding
                                      final legendItems = [
                                        const LegendItem(Color(0xFF6C5CE7), '00:00 - 03:59', '40%'),
                                        const LegendItem(Color(0xFFFF6B9A), '04:00 - 07:59', '32%'),
                                        const LegendItem(Color(0xFF00B2FF), '08:00 - 11:59', '28%'),
                                      ];

                                      if (maxWidth < 420) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: legendItems
                                              .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: w))
                                              .toList(),
                                        );
                                      }

                                      final mid = (legendItems.length / 2).ceil();
                                      final left = legendItems.sublist(0, mid);
                                      final right = legendItems.sublist(mid);

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: left
                                                .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), child: w))
                                                .toList(),
                                          ),
                                          const SizedBox(width: 24),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: right
                                                .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), child: w))
                                                .toList(),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),

                                const SizedBox(height: 20),
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

  // Top list and legend moved to dedicated widgets in "widgets/".
}
