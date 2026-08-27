import '../entities/lesson.dart';
import '../entities/vocabulary.dart';
import '../entities/grammar_point.dart';
import '../entities/practice_item.dart';

/// Domain qatlami faqat shu interfeysni biladi — SQLite haqida hech narsa
/// bilmaydi. Bu Clean Architecture'ning asosiy printsipi: biznes-logika
/// ma'lumot manbaidan mustaqil bo'lishi kerak.
abstract class LessonRepository {
  Future<List<Lesson>> getAllLessons({int? book});
  Future<Lesson?> getLessonById(int id);

  Future<List<VocabularyItem>> getVocabularyForLesson(int lessonId);
  Future<List<GrammarPoint>> getGrammarForLesson(int lessonId);
  Future<List<PracticeItem>> getPracticeItemsForLesson(int lessonId, int stage);
  Future<List<QuizQuestion>> getQuizQuestionsForLesson(int lessonId);

  Future<void> updateLessonStage(int lessonId, int newStage);
  Future<void> markLessonCompleted(int lessonId, int quizScore);

  /// Checkpoint bloklash mantig'i: shu darsdan oldin o'tilishi shart bo'lgan
  /// checkpoint bor-yo'qligini va u o'tilganmi-yo'qligini tekshiradi.
  Future<bool> isLessonUnlocked(int lessonId);
}
