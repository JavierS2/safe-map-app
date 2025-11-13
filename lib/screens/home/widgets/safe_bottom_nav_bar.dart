import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class SafeBottomNavBar extends StatelessWidget {
  const SafeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
        children: const [
          _NavItem(
            icon: Icons.home_rounded,
            isSelected: true,
          ),
          _NavItem(icon: Icons.search_rounded),
          _NavItem(icon: Icons.map_rounded),
          _NavItem(icon: Icons.person_rounded),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      );
    }

    return Icon(
      icon,
      color: AppColors.navIcon,
      size: 26,
    );
  }
}
