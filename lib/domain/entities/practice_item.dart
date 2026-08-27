/// Mashq/savol turlari
enum PracticeType {
  flashcard,
  fillBlank,
  rearrange,
  multipleChoice,
  openEnded;

  static PracticeType fromString(String s) {
    return PracticeType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => PracticeType.multipleChoice,
    );
  }
}

/// Bitta mashq/savol elementi.
/// `content` maydoni turi bo'yicha har xil ma'no bildiradi:
/// - multipleChoice: {"question": "...", "options": ["a","b","c","d"]}
/// - fillBlank: {"sentence": "私は___です。", "hint": "watashi"}
/// - rearrange: {"words": ["わたし","は","がくせい","です"]}
/// - openEnded: {"prompt": "O'zingiz haqingizda ayting"}
class PracticeItem {
  final int id;
  final int lessonId;
  final int stage; // qaysi bosqichga tegishli (4, 5, yoki 6)
  final PracticeType type;
  final Map<String, dynamic> content;
  final String? correctAnswer;
  final String? topicTag; // masalan "particle_wa" - xato tahlili uchun
  final Map<String, String>? mistakeExplanations; // noto'g'ri variant -> nega xato ekanligi

  const PracticeItem({
    required this.id,
    required this.lessonId,
    required this.stage,
    required this.type,
    required this.content,
    this.correctAnswer,
    this.topicTag,
    this.mistakeExplanations,
  });

  /// Berilgan noto'g'ri javob uchun tushuntirish matnini topadi.
  /// Topilmasa umumiy xabar qaytaradi.
  String explanationFor(String wrongAnswer) {
    return mistakeExplanations?[wrongAnswer] ??
        "Bu javob to'g'ri emas. To'g'ri javob: $correctAnswer";
  }
}

/// Dars oxiridagi yoki checkpoint savoli (baholanadigan)
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });
}
