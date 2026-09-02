import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/lesson.dart';
import '../../providers/lesson_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_screen.dart';
import '../practice/practice_screen.dart';
import '../quiz/quiz_screen.dart';

/// Darsning markaziy ekrani. Mockup dizayni: vertikal "yo'l" - har bir
/// bosqich chiziq bilan bog'langan doira, bajarilgani yashil, joriysi
/// qizil halqa bilan ajratilgan, qulflanganlari kulrang.
class LessonScreen extends ConsumerWidget {
  final int lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: lessonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Xatolik: $err')),
          data: (lesson) {
            if (lesson == null) {
              return const Center(child: Text('Dars topilmadi'));
            }
            return Column(
              children: [
                _LessonHeader(title: lesson.title),
                Expanded(child: _StagePath(lesson: lesson)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final String title;
  const _LessonHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: AppTypography.screenTitle)),
        ],
      ),
    );
  }
}

class _StagePath extends ConsumerWidget {
  final Lesson lesson;
  const _StagePath({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const items = LessonStage.values;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      itemCount: items.length + 1, // +1 = dars-oxiri quiz
      itemBuilder: (context, index) {
        final isLast = index == items.length;

        if (isLast) {
          return _QuizNode(lesson: lesson);
        }

        final stage = items[index];
        final stageNumber = stage.stageNumber;
        final isUnlocked =
            stageNumber <= lesson.currentStage || lesson.status == LessonCompletionStatus.completed;
        final isCompleted =
            stageNumber < lesson.currentStage || lesson.status == LessonCompletionStatus.completed;
        final isCurrent = !isCompleted && isUnlocked;
        final lineActive = isCompleted;

        return _StageNode(
          number: stageNumber,
          title: stage.title,
          subtitle: _stageSubtitle(stage),
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isUnlocked: isUnlocked,
          showLine: true,
          lineActive: lineActive,
          onTap: isUnlocked ? () => _navigateToStage(context, ref, lesson, stage) : null,
        );
      },
    );
  }

  String _stageSubtitle(LessonStage stage) {
    switch (stage) {
      case LessonStage.vocabIntro:
        return "Yangi so'zlar";
      case LessonStage.vocabDrill:
        return 'Flashcard, SRS';
      case LessonStage.grammarExplain:
        return 'Qoidalar va misollar';
      case LessonStage.controlledPractice:
        return "Bo'sh joy to'ldirish";
      case LessonStage.semiControlledPractice:
        return 'Gap tuzish';
      case LessonStage.freeProduction:
        return "O'z gapingiz";
      case LessonStage.integration:
        return 'Dialog yozish';
    }
  }

  void _navigateToStage(BuildContext context, WidgetRef ref, Lesson lesson, LessonStage stage) {
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

/// Bitta bosqich tugunini (doira + chiziq + matn) chizadi.
/// Mockupdagi ".stage-node" / ".stage-circle" / ".stage-line" ga mos.
class _StageNode extends StatelessWidget {
  final dynamic number; // int yoki String ("🏆" kabi)
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isUnlocked;
  final bool showLine;
  final bool lineActive;
  final VoidCallback? onTap;

  const _StageNode({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    required this.isUnlocked,
    required this.showLine,
    required this.lineActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                _buildCircle(),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineActive ? AppColors.green : AppColors.border,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.lessonTitle.copyWith(
                        fontSize: 14.5,
                        color: isUnlocked ? AppColors.ink : AppColors.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.lessonSubtitle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle() {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;

    if (isCompleted) {
      bg = AppColors.green;
      fg = Colors.white;
    } else if (isCurrent) {
      bg = Colors.white;
      fg = AppColors.primary;
      border = Border.all(color: AppColors.primary, width: 3);
      shadow = [
        const BoxShadow(color: AppColors.primaryLight, blurRadius: 0, spreadRadius: 5),
      ];
    } else {
      bg = const Color(0xFFEFEBE3);
      fg = AppColors.inkFaint;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
        boxShadow: shadow,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check_rounded, color: fg, size: 22)
            : Text('$number', style: AppTypography.buttonSecondary.copyWith(color: fg, fontSize: 16)),
      ),
    );
  }
}

class _QuizNode extends ConsumerWidget {
  final Lesson lesson;
  const _QuizNode({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStagesDone = lesson.currentStage > 7 || lesson.status == LessonCompletionStatus.completed;

    return _StageNode(
      number: '🏆',
      title: 'Yakuniy quiz',
      subtitle: lesson.quizScore != null ? "Natija: ${lesson.quizScore}%" : "O'tish balli 70%",
      isCompleted: lesson.isCompleted,
      isCurrent: allStagesDone && !lesson.isCompleted,
      isUnlocked: allStagesDone,
      showLine: false,
      lineActive: false,
      onTap: allStagesDone
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(lessonId: lesson.id)))
          : null,
    );
  }
}
