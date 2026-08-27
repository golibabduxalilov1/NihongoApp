import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/practice_item.dart';
import '../../../domain/entities/mistake_log_entry.dart';
import '../../../domain/usecases/submit_lesson_quiz_usecase.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../checkpoint/checkpoint_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {}; // questionId -> selected option index
  QuizSubmissionResult? _result;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(lessonQuizProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dars quiz'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: _result == null,
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Savollar topilmadi'));
          }

          if (_result != null) {
            return _buildResultView(context, _result!);
          }

          if (_currentIndex >= questions.length) {
            return _buildSubmitView(context, questions);
          }

          return _buildQuestionView(questions[_currentIndex], questions.length);
        },
      ),
    );
  }

  Widget _buildQuestionView(QuizQuestion q, int total) {
    final selected = _answers[q.id];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / total,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text('Savol ${_currentIndex + 1} / $total'),
          const SizedBox(height: 20),
          Text(q.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, i) {
                return RadioListTile<int>(
                  value: i,
                  groupValue: selected,
                  title: Text(q.options[i]),
                  onChanged: (value) {
                    setState(() => _answers[q.id] = value!);
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selected == null
                ? null
                : () => setState(() => _currentIndex++),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              _currentIndex == total - 1 ? 'Yakunlash' : 'Keyingi savol',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitView(BuildContext context, List<QuizQuestion> questions) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Barcha savollarga javob berdingiz.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submitQuiz(questions),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Natijani ko\'rish', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, QuizSubmissionResult result) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.passed ? Icons.emoji_events : Icons.refresh,
              color: result.passed ? AppColors.success : AppColors.warning,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              '${result.score}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${result.correctCount} / ${result.totalCount} to\'g\'ri javob'),
            const SizedBox(height: 8),
            Text(
              result.passed
                  ? "Tabriklaymiz! Dars muvaffaqiyatli yakunlandi."
                  : "O'tish balli 70%. Qayta urinib ko'ring.",
              style: TextStyle(
                color: result.passed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (result.passed) {
                  _navigateAfterPass();
                } else {
                  setState(() {
                    _currentIndex = 0;
                    _answers.clear();
                    _result = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  result.passed ? 'Darslar ro\'yxatiga qaytish' : 'Qayta urinish',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz(List<QuizQuestion> questions) async {
    final correctAnswers = {
      for (final q in questions) q.id: q.correctOptionIndex,
    };

    final useCase = ref.read(submitLessonQuizUseCaseProvider);
    final result = await useCase.call(
      lessonId: widget.lessonId,
      answers: _answers,
      correctAnswers: correctAnswers,
    );

    // Xato tahlili: har bir noto'g'ri javob mistake_log jadvaliga yoziladi,
    // shunda GetWeakPointsUseCase keyinchalik zaif mavzularni topa oladi.
    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    for (final q in questions) {
      final selected = _answers[q.id];
      if (selected != null && selected != q.correctOptionIndex) {
        await mistakeRepo.logMistake(MistakeLogEntry(
          id: 0,
          quizQuestionId: q.id,
          lessonId: widget.lessonId,
          selectedAnswer: q.options[selected],
          correctAnswer: q.options[q.correctOptionIndex],
          createdAt: DateTime.now(),
        ));
      }
    }

    // Motivatsiya tizimi: quiz tugatilganda faollik yozib boriladi.
    final recordActivity = ref.read(recordStudyActivityUseCaseProvider);
    await recordActivity.call(minutesStudied: 5);
    ref.invalidate(userStatsProvider);

    ref.invalidate(lessonByIdProvider(widget.lessonId));
    ref.invalidate(lessonsListProvider);
    setState(() => _result = result);
  }

  /// Dars quiz'i muvaffaqiyatli tugagach, agar shu darsdan keyin
  /// checkpoint belgilangan bo'lsa, foydalanuvchini avtomatik o'sha
  /// imtihonga yo'naltiramiz. Aks holda darslar ro'yxatiga (ilova ildiziga) qaytaramiz.
  ///
  /// Eslatma: HomeScreen'ga import qilmasdan qaytish uchun popUntil ishlatamiz —
  /// HomeScreen ilovaning ildiz ekrani (main.dart) bo'lgani uchun bu ishonchli.
  Future<void> _navigateAfterPass() async {
    final checkpointRepo = ref.read(checkpointRepositoryProvider);
    final checkpoint =
        await checkpointRepo.getCheckpointAfterLesson(widget.lessonId);

    if (!mounted) return;

    if (checkpoint != null) {
      final alreadyPassed =
          await checkpointRepo.hasPassedCheckpoint(checkpoint.id);
      if (!alreadyPassed && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => CheckpointScreen(checkpoint: checkpoint),
          ),
          (route) => false,
        );
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
