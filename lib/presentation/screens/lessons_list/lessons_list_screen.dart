import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../domain/entities/lesson.dart';
import '../../providers/lesson_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../lesson/lesson_screen.dart';

/// To'liq darslar ro'yxati - umumiy progress bar bilan.
/// HomeScreen faqat "joriy dars"ni ko'rsatadi; bu ekran barcha
/// darslarni (I va II kitob) tartib bilan ko'rsatadi.
class LessonsListScreen extends ConsumerWidget {
  const LessonsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Darslar',
                  style: AppTypography.screenTitle.copyWith(fontSize: 22)),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(lessonsListProvider);
                ref.invalidate(lessonUnlockedProvider);
                await ref.read(lessonsListProvider.future);
              },
              child: lessonsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Xatolik: $err')),
                data: (lessons) => _LessonListBody(lessons: lessons),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonListBody extends ConsumerWidget {
  final List<Lesson> lessons;
  const _LessonListBody({required this.lessons});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Hali darslar yo'q. Profil > Sozlamalar orqali kontent import qiling.",
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          ),
        ],
      );
    }

    final completedCount = lessons.where((l) => l.isCompleted).length;
    final overallProgress = completedCount / lessons.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Umumiy progress: $completedCount / ${lessons.length} dars',
                      style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 10,
                      percent: overallProgress,
                      backgroundColor: AppColors.border,
                      progressColor: AppColors.primary,
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: lessons.length,
            itemBuilder: (context, index) => _LessonRow(lesson: lessons[index]),
          ),
        ),
      ],
    );
  }
}

class _LessonRow extends ConsumerWidget {
  final Lesson lesson;
  const _LessonRow({required this.lesson});

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
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              enabled: isUnlocked,
              leading: _buildStatusIcon(isUnlocked),
              title: Text(lesson.title, style: AppTypography.lessonTitle),
              subtitle: Text(
                isUnlocked
                    ? 'Bosqich: ${lesson.currentStage}/7'
                    : "Oldingi checkpoint imtihonidan o'ting",
                style: AppTypography.lessonSubtitle,
              ),
              trailing: lesson.quizScore != null
                  ? Text('${lesson.quizScore}%',
                      style: AppTypography.buttonSecondary
                          .copyWith(color: AppColors.green))
                  : Icon(isUnlocked ? Icons.chevron_right : Icons.lock_outline,
                      color: AppColors.inkFaint),
              onTap: isUnlocked
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LessonScreen(lessonId: lesson.id)))
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(bool isUnlocked) {
    Color bg;
    IconData icon;
    if (!isUnlocked) {
      bg = const Color(0xFFF2F0EA);
      icon = Icons.lock_outline;
    } else if (lesson.isCompleted) {
      bg = AppColors.mint;
      icon = Icons.check_rounded;
    } else if (lesson.status == LessonCompletionStatus.inProgress) {
      bg = AppColors.peach;
      icon = Icons.play_arrow_rounded;
    } else {
      bg = const Color(0xFFF2F0EA);
      icon = Icons.circle_outlined;
    }
    return Container(
      width: 44,
      height: 44,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: AppColors.ink, size: 20),
    );
  }
}
