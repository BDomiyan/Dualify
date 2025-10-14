import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'dashboard_page.dart';
import 'community_page.dart';
import 'ai_assistant_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_nav_bar.dart';

/// Main navigation wrapper that handles bottom navigation
/// and keeps pages in memory for better UX
class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  late PageController _pageController;

  // Keep pages in memory to preserve scroll position
  final List<Widget> _pages = [
    const DashboardPage(isInNavigationWrapper: true),
    const CommunityPage(isInNavigationWrapper: true),
    const AiAssistantPage(isInNavigationWrapper: true),
    const ProfilePage(isInNavigationWrapper: true),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: AppConstants.mainNavigationAnimationDuration),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe to prevent accidental navigation
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
