import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_comet/core/srs/sm2_algorithm.dart';
import 'package:nihongo_comet/domain/entities/srs_state.dart';

void main() {
  group('Sm2Algorithm', () {
    test('yomon javobdan keyin interval 1 kunga tushadi', () {
      final initial = SrsState.initial(1).copyWith(
        repetitions: 5,
        intervalDays: 30,
        easeFactor: 2.8,
      );

      final result = Sm2Algorithm.calculateNext(initial, RecallQuality.again);

      expect(result.intervalDays, 1);
      expect(result.repetitions, 0);
    });

    test('birinchi to\'g\'ri javobda interval 1 kun bo\'ladi', () {
      final initial = SrsState.initial(1);
      final result = Sm2Algorithm.calculateNext(initial, RecallQuality.good);

      expect(result.repetitions, 1);
      expect(result.intervalDays, 1);
    });

    test('ikkinchi to\'g\'ri javobda interval 6 kun bo\'ladi', () {
      var state = SrsState.initial(1);
      state = Sm2Algorithm.calculateNext(state, RecallQuality.good);
      state = Sm2Algorithm.calculateNext(state, RecallQuality.good);

      expect(state.repetitions, 2);
      expect(state.intervalDays, 6);
    });

    test('uchinchi to\'g\'ri javobda interval ease factor bilan o\'sadi', () {
      var state = SrsState.initial(1);
      state = Sm2Algorithm.calculateNext(state, RecallQuality.good);
      state = Sm2Algorithm.calculateNext(state, RecallQuality.good);
      final easeFactorBeforeThird = state.easeFactor;
      state = Sm2Algorithm.calculateNext(state, RecallQuality.good);

      expect(state.repetitions, 3);
      expect(state.intervalDays, (6 * easeFactorBeforeThird).round());
    });

    test('ease factor 1.3 dan pastga tushmaydi', () {
      var state = SrsState.initial(1);
      // Ko'p marta "again" bermasdan past sifatli javob berib ko'ramiz
      for (var i = 0; i < 20; i++) {
        state = Sm2Algorithm.calculateNext(state, RecallQuality.hard);
      }
      expect(state.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('easy javob ease factorni oshiradi', () {
      final initial = SrsState.initial(1);
      final result = Sm2Algorithm.calculateNext(initial, RecallQuality.easy);
      expect(result.easeFactor, greaterThan(initial.easeFactor));
    });
  });
}
