import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith('/resume')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go('/resume');
        break;
      case 2:
        context.go('/library');
        break;
      case 3:
        context.go('/profile');
        break;
      default:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: const Border(
                top: BorderSide(color: AppColors.outlineVariant),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  isActive: currentIndex == 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  label: 'Resume',
                  isActive: currentIndex == 1,
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  label: 'Library',
                  isActive: currentIndex == 2,
                  icon: Icons.video_library_outlined,
                  activeIcon: Icons.video_library,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  label: 'Profile',
                  isActive: currentIndex == 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  onTap: () => _onTap(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.mutedText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
