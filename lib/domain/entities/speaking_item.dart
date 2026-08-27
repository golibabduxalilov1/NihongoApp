/// Gapirish/shadowing mashqi uchun bitta element.
/// TZ funksiya 4: "Talaffuz va gapirish mashqi (shadowing)".
/// [isKaiwa] — Minna no Nihongo darsligining 会話 (kaiwa, dialog) qismidan
/// olinganini bildiradi.
class SpeakingItem {
  final int id;
  final int lessonId;
  final String promptText; // yapon tilida matn
  final String? promptRomaji;
  final String promptTranslationUz;
  final String? referenceAudioPath; // foydalanuvchi import qilgan audio
  final bool isKaiwa;

  const SpeakingItem({
    required this.id,
    required this.lessonId,
    required this.promptText,
    this.promptRomaji,
    required this.promptTranslationUz,
    this.referenceAudioPath,
    this.isKaiwa = false,
  });
}

/// Foydalanuvchining bitta urinishi: nima deb tanildi (speech-to-text
/// natijasi) va taxminiy moslik darajasi.
class SpeakingAttempt {
  final int id;
  final int speakingItemId;
  final String? recognizedText;
  final double? similarityScore; // 0.0 - 1.0
  final DateTime attemptedAt;

  const SpeakingAttempt({
    required this.id,
    required this.speakingItemId,
    this.recognizedText,
    this.similarityScore,
    required this.attemptedAt,
  });
}
