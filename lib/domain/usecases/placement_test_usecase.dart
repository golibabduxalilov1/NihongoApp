import '../entities/placement_test.dart';
import '../repositories/placement_test_repository.dart';
import '../repositories/lesson_repository.dart';

class PlacementTestSubmission {
  final int recommendedLessonId;
  final int score;
  final String recommendedLessonTitle;

  const PlacementTestSubmission({
    required this.recommendedLessonId,
    required this.score,
    required this.recommendedLessonTitle,
  });
}

/// Onboarding paytida foydalanuvchi "MNN'ni qisman bilaman" desa,
/// 10-15 savoldan iborat testni baholab, qaysi darsdan boshlash kerakligini
/// tavsiya qiladi va user_progress'ni shunga mos oldindan to'ldiradi.
///
/// Mantiq: savollar oson->qiyin tartibda beriladi (difficulty_order).
/// Foydalanuvchi ketma-ket 2 tadan ortiq savolga xato javob bergan
/// so'nggi "to'g'ri javob berilgan" savolning maps_to_lesson_id qiymati
/// tavsiya etiladi — bu haqiqiy joylashtirish testlarining odatiy usuli
/// (masalan Duolingo placement test).
class PlacementTestUseCase {
  final PlacementTestRepository placementRepository;
  final LessonRepository lessonRepository;

  PlacementTestUseCase(this.placementRepository, this.lessonRepository);

  Future<PlacementTestSubmission> call(Map<int, int> answers) async {
    final questions = await placementRepository.getQuestions();
    // difficulty_order bo'yicha saralanganligiga ishonch hosil qilamiz
    final sorted = [...questions]..sort((a, b) => a.difficultyOrder.compareTo(b.difficultyOrder));

    int correctStreak = 0;
    int consecutiveWrong = 0;
    int lastCorrectLessonId = sorted.isNotEmpty ? sorted.first.mapsToLessonId : 1;
    int correctCount = 0;

    for (final q in sorted) {
      final answer = answers[q.id];
      final isCorrect = answer != null && answer == q.correctOptionIndex;

      if (isCorrect) {
        correctCount++;
        correctStreak++;
        consecutiveWrong = 0;
        lastCorrectLessonId = q.mapsToLessonId;
      } else {
        consecutiveWrong++;
        correctStreak = 0;
        // Ketma-ket 2 tadan ortiq xato — foydalanuvchi bu darajadan
        // qiynalayotganini bildiradi, testni shu yerda "to'xtatamiz"
        // (keyingi savollar hisoblanmaydi, lekin baribir javob berilgan
        // bo'lsa hisoblanadi — oddiy va tushunarli qoida uchun davom etamiz).
        if (consecutiveWrong >= 2) {
          break;
        }
      }
    }

    final score = questions.isEmpty ? 0 : ((correctCount / questions.length) * 100).round();

    final lesson = await lessonRepository.getLessonById(lastCorrectLessonId);

    final result = PlacementTestResult(
      id: 0,
      recommendedLessonId: lastCorrectLessonId,
      score: score,
      takenAt: DateTime.now(),
    );
    await placementRepository.saveResult(result);

    return PlacementTestSubmission(
      recommendedLessonId: lastCorrectLessonId,
      score: score,
      recommendedLessonTitle: lesson?.title ?? 'Noma\'lum dars',
    );
  }
}
