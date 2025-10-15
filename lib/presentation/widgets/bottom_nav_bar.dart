import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/constants.dart';

/// Bottom navigation bar with 4 tabs using Flutter's standard BottomNavigationBar
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.bottomNavBackground,
      selectedItemColor: AppColors.bottomNavActive,
      unselectedItemColor: AppColors.bottomNavInactive,
      selectedFontSize: AppTextStyles.navActive.fontSize!,
      unselectedFontSize: AppTextStyles.navInactive.fontSize!,
      selectedLabelStyle: AppTextStyles.navActive,
      unselectedLabelStyle: AppTextStyles.navInactive,
      elevation: AppConstants.elevation8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.dashboardLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: AppStrings.communityLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy),
          label: AppStrings.askDualifyLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.profileLabel,
        ),
      ],
    );
  }
}
