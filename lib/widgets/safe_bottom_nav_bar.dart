import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../config/routes.dart';

class SafeBottomNavBar extends StatelessWidget {
  final String? selectedRoute;

  const SafeBottomNavBar({super.key, this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = selectedRoute ?? ModalRoute.of(context)?.settings.name;
    final bool isHomeRoute = currentRoute == AppRoutes.home;
    final bool isSearchRoute = currentRoute == AppRoutes.reportSearch;
    final bool isStatisticRoute = currentRoute == AppRoutes.statistic;
    final bool isAccountRoute = currentRoute == AppRoutes.accountSettings;
    final bool isMapRoute = currentRoute == AppRoutes.map;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -2),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            isSelected: isHomeRoute,
            onTap: () {
              if (!isHomeRoute) Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          _NavItem(
            icon: Icons.search_rounded,
            isSelected: isSearchRoute,
            onTap: () {
              if (!isSearchRoute) Navigator.pushReplacementNamed(context, AppRoutes.reportSearch);
            },
          ),
          _NavItem(
            icon: Icons.map_rounded,
            isSelected: isMapRoute,
            onTap: () {
              if (!isMapRoute) Navigator.pushReplacementNamed(context, AppRoutes.map);
            },
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            isSelected: isStatisticRoute,
            onTap: () {
              if (!isStatisticRoute) Navigator.pushReplacementNamed(context, AppRoutes.statistic);
            },
          ),
          _NavItem(
            icon: Icons.person_rounded,
            isSelected: isAccountRoute,
            onTap: () {
              if (!isAccountRoute) Navigator.pushReplacementNamed(context, AppRoutes.accountSettings);
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = isSelected
        ? Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          )
        : Icon(
            icon,
            color: AppColors.navIcon,
            size: 26,
          );

    final Widget child = SizedBox(
      width: 56,
      child: Center(child: content),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }
}
