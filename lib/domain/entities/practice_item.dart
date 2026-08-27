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

  const PracticeItem({
    required this.id,
    required this.lessonId,
    required this.stage,
    required this.type,
    required this.content,
    this.correctAnswer,
  });
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
