import '../entities/srs_state.dart';

abstract class SrsRepository {
  Future<SrsState> getStateForVocabulary(int vocabularyId);
  Future<void> saveState(SrsState state);

  /// Berilgan dars uchun hozir takrorlash kerak bo'lgan so'zlar ID'lari
  Future<List<int>> getDueVocabularyIds(int lessonId);
}
