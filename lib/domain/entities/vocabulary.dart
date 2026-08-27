class VocabularyItem {
  final int id;
  final int lessonId;
  final String? kanji; // masalan "食べます" — bo'lmasa null (faqat kana so'zlar uchun)
  final String kana; // masalan "たべます"
  final String? romaji; // masalan "tabemasu"
  final String translationUz;
  final String? translationRu;
  final String? exampleSentence; // kontekst uchun to'liq gap
  final String? audioPath;

  const VocabularyItem({
    required this.id,
    required this.lessonId,
    this.kanji,
    required this.kana,
    this.romaji,
    required this.translationUz,
    this.translationRu,
    this.exampleSentence,
    this.audioPath,
  });

  /// Ekranda ko'rsatiladigan asosiy yozuv: kanji bo'lsa kanji, bo'lmasa kana
  String get displayText => kanji ?? kana;

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'] as int,
      lessonId: map['lesson_id'] as int,
      kanji: map['kanji'] as String?,
      kana: map['kana'] as String,
      romaji: map['romaji'] as String?,
      translationUz: map['translation_uz'] as String,
      translationRu: map['translation_ru'] as String?,
      exampleSentence: map['example_sentence'] as String?,
      audioPath: map['audio_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'kanji': kanji,
      'kana': kana,
      'romaji': romaji,
      'translation_uz': translationUz,
      'translation_ru': translationRu,
      'example_sentence': exampleSentence,
      'audio_path': audioPath,
    };
  }
}
