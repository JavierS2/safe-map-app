import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/incident_summary_card.dart';
import 'widgets/latest_reports_title.dart';
import 'widgets/report_item_card.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's count once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      provider.fetchTodayCount();
      provider.fetchLatestReports(limit: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    // Determine user's first name
    String fullName = auth.currentUserData?.fullName ?? auth.currentUser?.displayName ?? 'Usuario';
    String firstName = fullName.split(' ').where((s) => s.isNotEmpty).toList().first;
    // Greeting based on local hour
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }
    final reports = reportProvider.latestReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeBottomNavBar(selectedRoute: AppRoutes.home),
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
                      HomeHeader(
                        userName: firstName,
                        greeting: greeting,
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
                                    totalToday: reportProvider.todayCount,
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
                                              data: ReportItemData(
                                                neighborhood: r.neighborhood,
                                                dateTime:
                                                    '${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}/${r.date.year} - ${r.time}',
                                                type: r.category,
                                              ),
                                              onDetailsPressed: () async {
                                                // Navigate to dedicated details screen and mark as viewed
                                                final provider = Provider.of<ReportProvider>(context, listen: false);
                                                provider.viewReport(r);
                                                Navigator.pushNamed(context, AppRoutes.viewDetails, arguments: {'reportId': r.id});
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
