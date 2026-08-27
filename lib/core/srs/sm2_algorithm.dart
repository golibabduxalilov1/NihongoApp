import '../../domain/entities/srs_state.dart';

/// SuperMemo-2 (SM-2) algoritmining to'liq implementatsiyasi.
///
/// Bu algoritm 1987 yilda Piotr Wozniak tomonidan ishlab chiqilgan va
/// Anki kabi ko'plab SRS ilovalarida ishlatiladi. Asosiy g'oya: foydalanuvchi
/// so'zni qanchalik oson eslasa, keyingi takrorlashgacha shunchalik uzoq
/// vaqt o'tadi (unutish egri chizig'iga asoslangan).
///
/// Formula manbasi: https://en.wikipedia.org/wiki/SuperMemo#Description_of_SM-2_algorithm
class Sm2Algorithm {
  /// Ease factor hech qachon 1.3 dan past tushmaydi — aks holda
  /// intervallar cheksiz qisqarib, so'z "abadiy qiyin" bo'lib qoladi.
  static const double _minEaseFactor = 1.3;

  /// Foydalanuvchi flashcard'ga javob berganidan keyin yangi SRS holatini hisoblaydi.
  ///
  /// [current] — so'zning joriy SRS holati
  /// [quality] — foydalanuvchi javobining sifati (0-5, RecallQuality orqali)
  ///
  /// Qaytaradi: yangilangan SrsState (yangi interval, ease factor, keyingi sana)
  static SrsState calculateNext(SrsState current, RecallQuality quality) {
    final q = quality.smValue;

    // 1-qadam: ease factor'ni yangilash (SM-2 rasmiy formulasi)
    // EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
    double newEaseFactor = current.easeFactor +
        (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEaseFactor < _minEaseFactor) {
      newEaseFactor = _minEaseFactor;
    }

    // 2-qadam: agar javob yomon bo'lsa (quality < 3), takrorlash hisoblagichi
    // nolga tushadi va so'z ertaga qayta ko'rsatiladi ("qayta boshlash").
    if (q < 3) {
      return current.copyWith(
        easeFactor: newEaseFactor,
        repetitions: 0,
        intervalDays: 1,
        nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      );
    }

    // 3-qadam: javob to'g'ri bo'lsa, intervalni SM-2 qoidasi bo'yicha o'stiramiz:
    // 1-marta to'g'ri: 1 kun
    // 2-marta to'g'ri: 6 kun
    // 3+ marta to'g'ri: oldingi interval * ease factor
    final newRepetitions = current.repetitions + 1;
    int newInterval;
    if (newRepetitions == 1) {
      newInterval = 1;
    } else if (newRepetitions == 2) {
      newInterval = 6;
    } else {
      newInterval = (current.intervalDays * newEaseFactor).round();
    }

    return current.copyWith(
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      intervalDays: newInterval,
      nextReviewDate: DateTime.now().add(Duration(days: newInterval)),
    );
  }

  /// Berilgan so'zlar ro'yxatidan hozir takrorlash kerak bo'lganlarini filtrlaydi.
  static List<T> filterDue<T>(
    List<T> items,
    SrsState Function(T item) getState,
  ) {
    return items.where((item) => getState(item).isDueForReview).toList();
  }
}
