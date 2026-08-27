import '../entities/speaking_item.dart';

abstract class SpeakingRepository {
  Future<List<SpeakingItem>> getSpeakingItemsForLesson(int lessonId);
  Future<List<SpeakingItem>> getKaiwaItemsForLesson(int lessonId);
  Future<void> saveAttempt(SpeakingAttempt attempt);
  Future<List<SpeakingAttempt>> getAttemptsFor(int speakingItemId);
}
