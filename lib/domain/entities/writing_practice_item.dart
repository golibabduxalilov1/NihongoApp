enum CharacterType {
  hiragana,
  katakana,
  kanji;

  static CharacterType fromString(String s) {
    return CharacterType.values.firstWhere((t) => t.name == s, orElse: () => CharacterType.hiragana);
  }
}

/// Bitta harf/kanji uchun yozish mashqi ma'lumoti.
/// TZ funksiya 6: "Kanji/kana yozish mashqi (stroke order)".
/// [strokeOrderSvgPath] — chiziq yo'nalishini ko'rsatuvchi SVG fayl yo'li.
/// Mualliflik huquqi siyosati bo'yicha bu fayl repo ichida emas, faqat
/// foydalanuvchi import qilgan kontent orqali keladi.
class WritingPracticeItem {
  final int id;
  final int? lessonId;
  final String character; // masalan "あ"
  final String? romaji; // masalan "a"
  final String? strokeOrderSvgPath;
  final int strokeCount;
  final CharacterType characterType;

  const WritingPracticeItem({
    required this.id,
    this.lessonId,
    required this.character,
    this.romaji,
    this.strokeOrderSvgPath,
    required this.strokeCount,
    this.characterType = CharacterType.hiragana,
  });
}

/// Foydalanuvchining bitta chizish urinishi natijasi.
class WritingAttempt {
  final int id;
  final int writingPracticeId;
  final double? accuracyScore; // 0.0 - 1.0, asosiy chiziq yo'nalishi moslik darajasi
  final DateTime attemptedAt;

  const WritingAttempt({
    required this.id,
    required this.writingPracticeId,
    this.accuracyScore,
    required this.attemptedAt,
  });
}
