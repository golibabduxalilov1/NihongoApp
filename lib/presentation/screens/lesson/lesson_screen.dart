import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/lesson.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_screen.dart';
import '../practice/practice_screen.dart';
import '../quiz/quiz_screen.dart';

/// Darsning markaziy ekrani: 7 bosqichni ro'yxat sifatida ko'rsatadi,
/// ketma-ketlik qoidasini (avvalgi bosqich tugamasa keyingisi qulflangan)
/// shu yerda vizual jihatdan amalga oshiradi.
class LessonScreen extends ConsumerWidget {
  final int lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: lessonAsync.when(
          data: (lesson) => Text(lesson?.title ?? 'Dars'),
          loading: () => const Text('Yuklanmoqda...'),
          error: (_, __) => const Text('Dars'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Dars topilmadi'));
          }
          return _StageList(lesson: lesson);
        },
      ),
    );
  }
}

class _StageList extends ConsumerWidget {
  final Lesson lesson;
  const _StageList({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: LessonStage.values.length + 1, // +1 = dars-oxiri quiz
      itemBuilder: (context, index) {
        if (index == LessonStage.values.length) {
          return _QuizTile(lesson: lesson);
        }

        final stage = LessonStage.values[index];
        final stageNumber = stage.stageNumber;
        final isUnlocked = stageNumber <= lesson.currentStage ||
            lesson.status == LessonCompletionStatus.completed;
        final isCompleted = stageNumber < lesson.currentStage ||
            lesson.status == LessonCompletionStatus.completed;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            enabled: isUnlocked,
            leading: CircleAvatar(
              backgroundColor:
                  isCompleted ? AppColors.success : AppColors.secondary,
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text('$stageNumber',
                      style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              stage.title,
              style: TextStyle(
                color: isUnlocked ? Colors.black : AppColors.locked,
              ),
            ),
            trailing: isUnlocked
                ? const Icon(Icons.chevron_right)
                : const Icon(Icons.lock, color: AppColors.locked),
            onTap: isUnlocked
                ? () => _navigateToStage(context, ref, lesson, stage)
                : null,
          ),
        );
      },
    );
  }

  void _navigateToStage(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    LessonStage stage,
  ) {
    Widget screen;
    switch (stage) {
      case LessonStage.vocabIntro:
      case LessonStage.vocabDrill:
        screen = FlashcardScreen(
          lessonId: lesson.id,
          stage: stage.stageNumber,
          isIntroMode: stage == LessonStage.vocabIntro,
        );
        break;
      case LessonStage.grammarExplain:
        screen = GrammarScreen(lessonId: lesson.id);
        break;
      case LessonStage.controlledPractice:
      case LessonStage.semiControlledPractice:
      case LessonStage.freeProduction:
      case LessonStage.integration:
        screen = PracticeScreen(
          lessonId: lesson.id,
          stage: stage.stageNumber,
          stageName: stage.title,
        );
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _QuizTile extends ConsumerWidget {
  final Lesson lesson;
  const _QuizTile({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStagesDone = lesson.currentStage > 7 ||
        lesson.status == LessonCompletionStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: allStagesDone ? Colors.amber.shade50 : null,
      child: ListTile(
        enabled: allStagesDone,
        leading: Icon(
          Icons.quiz,
          color: allStagesDone ? AppColors.warning : AppColors.locked,
        ),
        title: Text(
          "Dars quiz (yakuniy test)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: allStagesDone ? Colors.black : AppColors.locked,
          ),
        ),
        subtitle: lesson.quizScore != null
            ? Text("Natija: ${lesson.quizScore}%")
            : const Text("8-10 savol, o'tish balli 70%"),
        trailing: allStagesDone
            ? const Icon(Icons.chevron_right)
            : const Icon(Icons.lock, color: AppColors.locked),
        onTap: allStagesDone
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(lessonId: lesson.id),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
