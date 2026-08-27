/// Grammatika qoidasi uchun SM-2 SRS holati (lug'at uchun ishlatiladigan
/// SrsState bilan bir xil algoritm, lekin alohida jadval — chunki
/// grammatika qoidasi va so'z butunlay boshqa narsa).
/// TZ funksiya 3: "Moslashuvchan (adaptive) grammatika takrorlash".
///
/// [errorCount] — necha marta noto'g'ri javob berilgani; bu qiymat qancha
/// yuqori bo'lsa, GetWeakPointsUseCase shu qoidani "zaif" deb belgilaydi
/// va ko'proq tez-tez qaytarib turadi.
class GrammarSrsState {
  final int grammarPointId;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewDate;
  final int errorCount;
  final int repetitions;

  const GrammarSrsState({
    required this.grammarPointId,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    required this.nextReviewDate,
    this.errorCount = 0,
    this.repetitions = 0,
  });

  factory GrammarSrsState.initial(int grammarPointId) {
    return GrammarSrsState(
      grammarPointId: grammarPointId,
      nextReviewDate: DateTime.now(),
    );
  }

  bool get isDueForReview =>
      nextReviewDate.isBefore(DateTime.now()) || nextReviewDate.isAtSameMomentAs(DateTime.now());

  GrammarSrsState copyWith({
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewDate,
    int? errorCount,
    int? repetitions,
  }) {
    return GrammarSrsState(
      grammarPointId: grammarPointId,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      errorCount: errorCount ?? this.errorCount,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}
