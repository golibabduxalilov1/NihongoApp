import '../repositories/lesson_repository.dart';

class QuizSubmissionResult {
  final int score; // foizda, 0-100
  final bool passed;
  final int correctCount;
  final int totalCount;

  const QuizSubmissionResult({
    required this.score,
    required this.passed,
    required this.correctCount,
    required this.totalCount,
  });
}

/// Dars oxiridagi quiz javoblarini baholaydi va natijani saqlaydi.
/// O'tish balli standart 70% (TZ bo'lim 7 ga muvofiq).
class SubmitLessonQuizUseCase {
  final LessonRepository repository;
  static const int passThreshold = 70;

  SubmitLessonQuizUseCase(this.repository);

  /// [answers] — savol id -> foydalanuvchi tanlagan variant indeksi
  /// [correctAnswers] — savol id -> to'g'ri variant indeksi
  Future<QuizSubmissionResult> call({
    required int lessonId,
    required Map<int, int> answers,
    required Map<int, int> correctAnswers,
  }) async {
    int correctCount = 0;
    for (final entry in answers.entries) {
      if (correctAnswers[entry.key] == entry.value) {
        correctCount++;
      }
    }

    final total = correctAnswers.length;
    final score = total == 0 ? 0 : ((correctCount / total) * 100).round();
    final passed = score >= passThreshold;

    if (passed) {
      await repository.markLessonCompleted(lessonId, score);
    }

    return QuizSubmissionResult(
      score: score,
      passed: passed,
      correctCount: correctCount,
      totalCount: total,
    );
  }
}
