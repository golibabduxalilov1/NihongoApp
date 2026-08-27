import '../entities/writing_practice_item.dart';

abstract class WritingPracticeRepository {
  Future<List<WritingPracticeItem>> getItemsForLesson(int? lessonId);
  Future<List<WritingPracticeItem>> getItemsByType(CharacterType type);
  Future<void> saveAttempt(WritingAttempt attempt);
}
