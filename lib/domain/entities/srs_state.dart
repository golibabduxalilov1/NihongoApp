/// Bitta lug'at so'zi uchun SM-2 algoritmi holati.
/// Bu ma'lumot har bir foydalanuvchi-so'z jufti uchun alohida saqlanadi
/// va har javobdan keyin yangilanadi (core/srs/sm2_algorithm.dart ga qarang).
class SrsState {
  final int vocabularyId;
  final double easeFactor; // qanchalik "oson" so'z, 1.3 dan boshlab, odatda 2.5
  final int intervalDays; // keyingi takrorlashgacha necha kun
  final DateTime nextReviewDate;
  final int repetitions; // ketma-ket to'g'ri javoblar soni

  const SrsState({
    required this.vocabularyId,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    required this.nextReviewDate,
    this.repetitions = 0,
  });

  factory SrsState.initial(int vocabularyId) {
    return SrsState(
      vocabularyId: vocabularyId,
      easeFactor: 2.5,
      intervalDays: 1,
      nextReviewDate: DateTime.now(),
      repetitions: 0,
    );
  }

  bool get isDueForReview => nextReviewDate.isBefore(DateTime.now()) ||
      nextReviewDate.isAtSameMomentAs(DateTime.now());

  SrsState copyWith({
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewDate,
    int? repetitions,
  }) {
    return SrsState(
      vocabularyId: vocabularyId,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}

/// Foydalanuvchi flashcard'ga qanday javob berganini bildiradi.
/// SM-2 algoritmida bu "quality" (0-5) ga mos keladi, lekin
/// UI soddaligi uchun 4 darajaga siqilgan.
enum RecallQuality {
  again(0), // umuman bilmadi
  hard(3), // qiynalib eslади
  good(4), // to'g'ri esladi
  easy(5); // juda oson edi

  final int smValue;
  const RecallQuality(this.smValue);
}
