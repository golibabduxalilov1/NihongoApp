import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/user_stats.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../lesson/lesson_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _HomeHeader(statsAsync: statsAsync),
          Expanded(
            child: lessonsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Xatolik: $err')),
              data: (lessons) => _HomeBody(lessons: lessons, statsAsync: statsAsync),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sarlavha: salomlashish + streak belgisi (mockupdagi "🔥 12").
/// Endi haqiqiy UserStats'dan olinadi (RecordStudyActivityUseCase orqali
/// yangilanadi).
class _HomeHeader extends StatelessWidget {
  final AsyncValue<UserStats> statsAsync;
  const _HomeHeader({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    final streak = statsAsync.maybeWhen(data: (s) => s.currentStreak, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xayrli kun,', style: AppTypography.bodySmall),
              Text("Do'stim 👋", style: AppTypography.greetingName),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.gold, size: 18),
                const SizedBox(width: 4),
                Text('$streak', style: AppTypography.buttonSecondary.copyWith(color: AppColors.primaryDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final List<Lesson> lessons;
  final AsyncValue<UserStats> statsAsync;
  const _HomeBody({required this.lessons, required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    final inProgress = lessons.where((l) => l.status == LessonCompletionStatus.inProgress).toList();
    final currentLesson = inProgress.isNotEmpty ? inProgress.first : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      children: [
        _DailyGoalCard(statsAsync: statsAsync),
        if (currentLesson != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Text('Davom etish', style: AppTypography.sectionTitle),
          ),
          _LessonCard(lesson: currentLesson, isCurrent: true),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Text('Barcha darslar', style: AppTypography.sectionTitle),
        ),
        if (lessons.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              "Hali darslar yo'q. Profil > Sozlamalar orqali kontent import qiling.",
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          )
        else
          ...lessons.map((l) => _LessonCard(lesson: l)),
      ],
    );
  }
}

/// Kunlik maqsad kartasi - mockupdagi qizil "goal-card".
/// Endi UserStats.todayProgress orqali haqiqiy foizni ko'rsatadi.
class _DailyGoalCard extends StatelessWidget {
  final AsyncValue<UserStats> statsAsync;
  const _DailyGoalCard({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final progress = stats.todayProgress;
        final remaining = (stats.dailyGoalMinutes - stats.minutesStudiedToday).clamp(0, stats.dailyGoalMinutes);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BUGUNGI MAQSAD',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${(progress * 100).round()}%', style: AppTypography.goalPercent),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                stats.goalReachedToday
                    ? "Bugungi maqsadga yetdingiz! 🎉"
                    : '${stats.minutesStudiedToday} / ${stats.dailyGoalMinutes} daqiqa · yana $remaining daqiqa qoldi',
                style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final Lesson lesson;
  final bool isCurrent;
  const _LessonCard({required this.lesson, this.isCurrent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(lessonUnlockedProvider(lesson.id));

    return unlockedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isUnlocked) {
        return Opacity(
          opacity: isUnlocked ? 1.0 : 0.55,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isUnlocked
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LessonScreen(lessonId: lesson.id)),
                      )
                  : null,
              child: Row(
                children: [
                  _buildIcon(isUnlocked),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson.title, style: AppTypography.lessonTitle),
                        const SizedBox(height: 4),
                        Text(_subtitle(isUnlocked), style: AppTypography.lessonSubtitle),
                        if (isCurrent) ...[
                          const SizedBox(height: 6),
                          _StageMiniProgress(currentStage: lesson.currentStage),
                        ],
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    const Icon(Icons.chevron_right, color: AppColors.inkFaint)
                  else
                    const Icon(Icons.lock_outline, color: AppColors.inkFaint, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(bool isUnlocked) {
    if (!isUnlocked) return "Checkpoint imtihonidan o'ting";
    if (lesson.isCompleted) return 'Yakunlangan · ${lesson.quizScore ?? "-"}%';
    if (isCurrent) return 'Bosqich ${lesson.currentStage} / 7';
    return 'Boshlanmagan';
  }

  Widget _buildIcon(bool isUnlocked) {
    Color bg;
    IconData icon;
    if (!isUnlocked) {
      bg = const Color(0xFFF2F0EA);
      icon = Icons.lock_outline;
    } else if (lesson.isCompleted) {
      bg = AppColors.mint;
      icon = Icons.check_rounded;
    } else if (isCurrent) {
      bg = AppColors.peach;
      icon = Icons.menu_book_rounded;
    } else {
      bg = const Color(0xFFF2F0EA);
      icon = Icons.menu_book_outlined;
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.ink, size: 22),
    );
  }
}

/// Dars kartasi ichidagi mini 7-segmentli progress chizig'i
/// (mockupdagi ".lesson-progress-mini").
class _StageMiniProgress extends StatelessWidget {
  final int currentStage;
  const _StageMiniProgress({required this.currentStage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final stageNum = i + 1;
        Color color;
        if (stageNum < currentStage) {
          color = AppColors.green;
        } else if (stageNum == currentStage) {
          color = AppColors.gold;
        } else {
          color = AppColors.border;
        }
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 14,
            height: 4,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
        );
      }),
    );
  }
}
