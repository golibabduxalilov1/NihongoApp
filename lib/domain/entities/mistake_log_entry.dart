/// Foydalanuvchi bitta mashq yoki quiz savolida qilgan xatoning yozuvi.
/// TZ funksiya 2: "Xato tahlili va mikro-feedback".
///
/// [topicTag] — xato qaysi grammatik mavzuga tegishli ekanini belgilaydi
/// (masalan "particle_wa", "particle_ga", "particle_wo") — bu
/// GetWeakPointsUseCase orqali eng ko'p xato qilingan mavzularni
/// guruhlash uchun ishlatiladi.
class MistakeLogEntry {
  final int id;
  final int? practiceItemId;
  final int? quizQuestionId;
  final int lessonId;
  final String? topicTag;
  final String? selectedAnswer;
  final String? correctAnswer;
  final DateTime createdAt;

  const MistakeLogEntry({
    required this.id,
    this.practiceItemId,
    this.quizQuestionId,
    required this.lessonId,
    this.topicTag,
    this.selectedAnswer,
    this.correctAnswer,
    required this.createdAt,
  });
}

/// Bitta mavzu bo'yicha guruhlangan xatolar soni — statistika/zaif tomonlar
/// ekranida ko'rsatish uchun.
class WeakPoint {
  final String topicTag;
  final String displayName;
  final int mistakeCount;
  final int lessonId;

  const WeakPoint({
    required this.topicTag,
    required this.displayName,
    required this.mistakeCount,
    required this.lessonId,
  });
}
