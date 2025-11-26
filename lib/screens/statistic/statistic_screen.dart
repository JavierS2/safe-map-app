import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import '../../providers/report_provider.dart';
import 'widgets/top_list.dart';
import 'widgets/donut_chart.dart';
import 'widgets/legend_item.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {

  @override
  void initState() {
    super.initState();
    // fetch monthly stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      provider.fetchMonthlyStats();
    });
  }

  String _monthRangeText() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final monthName = _monthName(now.month);
    return 'Del 1 al $lastDay de $monthName de ${now.year}';
  }

  String _monthName(int m) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final name = months[m - 1];
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

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
                      const ReportHeader(title: 'Estadísticas mensuales'),

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

                                const SizedBox(height: 28),
                                Consumer<ReportProvider>(builder: (context, provider, _) {
                                  final data = provider.monthlyTopNeighborhoods.isNotEmpty ? provider.monthlyTopNeighborhoods : null;
                                  return TopList(data: data);
                                }),

                                const SizedBox(height: 28),

                                // Hour ranking + donut chart
                                Text(
                                  'Ranking de horas con mayores reportes',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(_monthRangeText(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 12),

                                // Donut centered with legend rows beneath
                                Column(
                                  children: [
                                    // chart color palette (extended for more buckets)
                                    const SizedBox.shrink(),
                                    Center(
                                      child: Consumer<ReportProvider>(builder: (context, provider, _) {
                                        final values = provider.monthlyDonutValues.isNotEmpty ? provider.monthlyDonutValues : [0.0, 0.0, 0.0];
                                        final chartColors = const [
                                          Color(0xFF6C5CE7), // purple
                                          Color(0xFFFF6B9A), // pink
                                          Color(0xFF00B2FF), // cyan
                                          Color(0xFFFFA726), // orange
                                          Color(0xFF66BB6A), // green
                                          Color(0xFFFFEB3B), // yellow
                                        ];
                                        return DonutChart(
                                          values: values,
                                          colors: chartColors,
                                          size: 140,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 12),
                                    Consumer<ReportProvider>(builder: (context, provider, _) {
                                      final labels = provider.monthlyDonutLabels;
                                      final percents = provider.monthlyDonutPercents;
                                      final chartColors = const [
                                        Color(0xFF6C5CE7),
                                        Color(0xFFFF6B9A),
                                        Color(0xFF00B2FF),
                                        Color(0xFFFFA726),
                                        Color(0xFF66BB6A),
                                        Color(0xFFFFEB3B),
                                      ];
                                      final items = List<Widget>.generate(labels.length, (i) {
                                        final color = chartColors[i % chartColors.length];
                                        return LegendItem(color, labels[i], percents[i]);
                                      });

                                      final maxWidth = MediaQuery.of(context).size.width - 32;
                                      if (maxWidth < 420) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: items.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: w)).toList(),
                                        );
                                      }

                                      final mid = (items.length / 2).ceil();
                                      final left = items.sublist(0, mid);
                                      final right = items.sublist(mid);

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: left.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), child: w)).toList()),
                                          const SizedBox(width: 24),
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: right.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), child: w)).toList()),
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
