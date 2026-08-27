import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/entities/mistake_log_entry.dart';
import '../practice/targeted_practice_screen.dart';

/// Statistika ekrani. TZ funksiya 2 talabiga muvofiq: foydalanuvchi
/// eng ko'p xato qilgan mavzularni ko'radi va shu yerdan to'g'ridan-to'g'ri
/// "Practice Hub"dagi maqsadli mashqqa o'tadi.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final weakPointsAsync = ref.watch(weakPointsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Text('Statistika', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 20),
          lessonsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Xatolik: $err'),
            data: (lessons) {
              final completed = lessons.where((l) => l.isCompleted).toList();
              final withScores = completed.where((l) => l.quizScore != null).toList();
              final avgScore = withScores.isEmpty
                  ? 0
                  : withScores.map((l) => l.quizScore!).reduce((a, b) => a + b) ~/ withScores.length;

              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Yakunlangan darslar',
                      value: '${completed.length}/${lessons.length}',
                      icon: Icons.check_circle_rounded,
                      bg: AppColors.mint,
                      fg: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "O'rtacha ball",
                      value: '$avgScore%',
                      icon: Icons.bar_chart_rounded,
                      bg: AppColors.lavender,
                      fg: AppColors.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Joriy streak',
                    value: '${stats.currentStreak} kun',
                    icon: Icons.local_fire_department_rounded,
                    bg: AppColors.peach,
                    fg: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Eng uzun streak',
                    value: '${stats.longestStreak} kun',
                    icon: Icons.emoji_events_rounded,
                    bg: const Color(0xFFFFF6E5),
                    fg: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Zaif tomonlar', style: AppTypography.sectionTitle),
          const SizedBox(height: 4),
          Text(
            "Eng ko'p xato qilgan grammatik mavzularingiz",
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          weakPointsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Xatolik: $err'),
            data: (weakPoints) {
              if (weakPoints.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Hozircha zaif tomon aniqlanmadi. Ajoyib!",
                    style: AppTypography.body,
                  ),
                );
              }
              return Column(
                children: weakPoints.map((wp) => _WeakPointTile(weakPoint: wp)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: fg, size: 26),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.sectionTitle.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WeakPointTile extends StatelessWidget {
  final WeakPoint weakPoint;
  const _WeakPointTile({required this.weakPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weakPoint.displayName, style: AppTypography.lessonTitle),
                const SizedBox(height: 2),
                Text('${weakPoint.mistakeCount} marta xato', style: AppTypography.lessonSubtitle),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TargetedPracticeScreen(topicTag: weakPoint.topicTag, topicName: weakPoint.displayName),
                ),
              );
            },
            child: const Text('Mashq qilish'),
          ),
        ],
      ),
    );
  }
}
