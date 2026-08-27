import '../entities/grammar_srs_state.dart';

abstract class GrammarSrsRepository {
  Future<GrammarSrsState> getStateForGrammarPoint(int grammarPointId);
  Future<void> saveState(GrammarSrsState state);

  /// Berilgan dars(lar) uchun hozir takrorlash kerak bo'lgan grammatika
  /// qoidalari ID'lari — eng ko'p xato qilinganlar birinchi o'rinda.
  Future<List<int>> getDueGrammarPointIds({List<int>? lessonIds});
}
