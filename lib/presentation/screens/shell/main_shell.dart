import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'home_screen.dart';
import '../lessons_list/lessons_list_screen.dart';
import '../practice_hub/practice_hub_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';

/// Ilovaning asosiy skeleton'i: pastki navbar orqali 5 bo'lim orasida
/// almashtiradi (mockupdagi "Bosh sahifa / Darslar / Mashq / Statistika / Profil").
/// Har bir tab holati IndexedStack bilan saqlanadi — tab almashtirilganda
/// scroll pozitsiyasi va state yo'qolmaydi.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    LessonsListScreen(),
    PracticeHubScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavItemData(icon: Icons.home_rounded, label: 'Bosh sahifa'),
    _NavItemData(icon: Icons.menu_book_rounded, label: 'Darslar'),
    _NavItemData(icon: Icons.track_changes_rounded, label: 'Mashq'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Statistika'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final active = i == _currentIndex;
            final color = active ? AppColors.primary : AppColors.inkFaint;
            return InkWell(
              onTap: () => setState(() => _currentIndex = i),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 22, color: color),
                    const SizedBox(height: 4),
                    Text(item.label, style: AppTypography.navLabel.copyWith(color: color)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}
