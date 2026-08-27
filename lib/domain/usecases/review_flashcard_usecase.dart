import '../entities/srs_state.dart';
import '../repositories/srs_repository.dart';
import '../../core/srs/sm2_algorithm.dart';

/// Foydalanuvchi flashcard'da "bildim/qiynaldim/bilmadim" deganda chaqiriladi.
/// SM-2 algoritmi orqali keyingi takrorlash sanasini hisoblab, saqlaydi.
class ReviewFlashcardUseCase {
  final SrsRepository repository;
  ReviewFlashcardUseCase(this.repository);

  Future<SrsState> call(int vocabularyId, RecallQuality quality) async {
    final current = await repository.getStateForVocabulary(vocabularyId);
    final updated = Sm2Algorithm.calculateNext(current, quality);
    await repository.saveState(updated);
    return updated;
  }
}
