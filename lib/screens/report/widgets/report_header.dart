import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../config/routes.dart';
import '../../../config/route_history.dart';

class ReportHeader extends StatelessWidget {
  final String title;

  const ReportHeader({super.key, this.title = 'Crea Tu Reporte'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          // Botón atrás
          IconButton(
            onPressed: () {
              // 1) If there is something to pop in the navigator stack, do it.
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                return;
              }

              // 2) Otherwise try to navigate to the last meaningful route
              // recorded by the route observer (if any).
                final current = ModalRoute.of(context)?.settings.name;
                final prev = appRouteObserver.previousMeaningfulRoute(current) ??
                  (appRouteObserver.lastRoute != null && appRouteObserver.lastRoute != current
                    ? appRouteObserver.lastRoute
                    : null);
              if (prev != null && prev.isNotEmpty && prev != current) {
                Navigator.pushReplacementNamed(context, prev);
                return;
              }

              // 3) Final fallback: go to app home.
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.notifications_none,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
