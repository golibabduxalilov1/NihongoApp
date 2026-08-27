import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lesson_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/lesson.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistika'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (lessons) {
          final completed =
              lessons.where((l) => l.isCompleted).toList();
          final withScores =
              completed.where((l) => l.quizScore != null).toList();

          final avgScore = withScores.isEmpty
              ? 0
              : withScores.map((l) => l.quizScore!).reduce((a, b) => a + b) ~/
                  withScores.length;

          final weakLessons = withScores
              .where((l) => (l.quizScore ?? 100) < 80)
              .toList()
            ..sort((a, b) => (a.quizScore ?? 0).compareTo(b.quizScore ?? 0));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Yakunlangan darslar',
                      value: '${completed.length}/${lessons.length}',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "O'rtacha ball",
                      value: '$avgScore%',
                      icon: Icons.bar_chart,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Zaif tomonlar (80% dan past)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (weakLessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Hozircha zaif tomon aniqlanmadi. Ajoyib!"),
                )
              else
                ...weakLessons.map((l) => _WeakLessonTile(lesson: l)),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _WeakLessonTile extends StatelessWidget {
  final Lesson lesson;
  const _WeakLessonTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: AppColors.warning),
        title: Text(lesson.title),
        trailing: Text('${lesson.quizScore}%',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
