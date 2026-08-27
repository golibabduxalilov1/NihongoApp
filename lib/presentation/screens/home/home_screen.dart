import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../domain/entities/lesson.dart';
import '../../providers/lesson_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../lesson/lesson_screen.dart';
import '../stats/stats_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nihongo Manzil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistika',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Sozlamalar',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Xatolik: $err')),
        data: (lessons) => _LessonListView(lessons: lessons),
      ),
    );
  }
}

class _LessonListView extends ConsumerWidget {
  final List<Lesson> lessons;
  const _LessonListView({required this.lessons});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Hali darslar yo'q. Sozlamalar orqali kontent import qiling.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final completedCount = lessons.where((l) => l.isCompleted).length;
    final overallProgress = completedCount / lessons.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Umumiy progress: $completedCount / ${lessons.length} dars',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                lineHeight: 12,
                percent: overallProgress,
                backgroundColor: Colors.grey.shade300,
                progressColor: AppColors.primary,
                barRadius: const Radius.circular(8),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _LessonCard(lesson: lesson);
            },
          ),
        ),
      ],
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final Lesson lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(lessonUnlockedProvider(lesson.id));

    return unlockedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isUnlocked) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            enabled: isUnlocked,
            leading: _buildStatusIcon(lesson, isUnlocked),
            title: Text(
              lesson.title,
              style: TextStyle(
                color: isUnlocked ? Colors.black : AppColors.locked,
              ),
            ),
            subtitle: Text(
              isUnlocked
                  ? "Bosqich: ${lesson.currentStage}/7"
                  : "Oldingi checkpoint imtihonidan o'ting",
            ),
            trailing: lesson.quizScore != null
                ? Text('${lesson.quizScore}%')
                : const Icon(Icons.chevron_right),
            onTap: isUnlocked
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(lessonId: lesson.id),
                      ),
                    );
                  }
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(Lesson lesson, bool isUnlocked) {
    if (!isUnlocked) {
      return const Icon(Icons.lock, color: AppColors.locked);
    }
    if (lesson.isCompleted) {
      return const Icon(Icons.check_circle, color: AppColors.success);
    }
    if (lesson.status == LessonCompletionStatus.inProgress) {
      return const Icon(Icons.play_circle, color: AppColors.warning);
    }
    return const Icon(Icons.circle_outlined);
  }
}
