import '../entities/grammar_srs_state.dart';
import '../entities/srs_state.dart';
import '../repositories/grammar_srs_repository.dart';
import '../../core/srs/sm2_algorithm.dart';

/// Grammatika qoidasini takrorlaganda chaqiriladi (lug'at uchun
/// ReviewFlashcardUseCase ga o'xshash, lekin grammar_srs_state jadvali
/// bilan ishlaydi va xato sonini alohida kuzatadi).
class ReviewGrammarUseCase {
  final GrammarSrsRepository repository;
  ReviewGrammarUseCase(this.repository);

  Future<GrammarSrsState> call(int grammarPointId, RecallQuality quality) async {
    final current = await repository.getStateForGrammarPoint(grammarPointId);

    // SM-2 formulasini qayta ishlatamiz, lekin GrammarSrsState'ga moslab.
    final asSrsState = SrsState(
      vocabularyId: current.grammarPointId,
      easeFactor: current.easeFactor,
      intervalDays: current.intervalDays,
      nextReviewDate: current.nextReviewDate,
      repetitions: current.repetitions,
    );
    final updatedSrs = Sm2Algorithm.calculateNext(asSrsState, quality);

    final newErrorCount = quality.smValue < 3 ? current.errorCount + 1 : current.errorCount;

    final updated = current.copyWith(
      easeFactor: updatedSrs.easeFactor,
      intervalDays: updatedSrs.intervalDays,
      nextReviewDate: updatedSrs.nextReviewDate,
      repetitions: updatedSrs.repetitions,
      errorCount: newErrorCount,
    );

    await repository.saveState(updated);
    return updated;
  }
}
