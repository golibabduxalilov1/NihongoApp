/// Joylashtirish (placement) testidagi bitta savol.
/// TZ funksiya 5: "Onboarding va joylashtirish testi".
/// [difficultyOrder] — savollar shu tartibda beriladi (oson -> qiyin),
/// shunda test qisqaroq bo'lishi mumkin (foydalanuvchi ketma-ket xato
/// qilishni boshlasa, testni erta to'xtatish mumkin).
class PlacementTestQuestion {
  final int id;
  final int mapsToLessonId; // shu savolga to'g'ri javob shu darsni bilishni anglatadi
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int difficultyOrder;

  const PlacementTestQuestion({
    required this.id,
    required this.mapsToLessonId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.difficultyOrder,
  });
}

class PlacementTestResult {
  final int id;
  final int recommendedLessonId;
  final int score;
  final DateTime takenAt;

  const PlacementTestResult({
    required this.id,
    required this.recommendedLessonId,
    required this.score,
    required this.takenAt,
  });
}
