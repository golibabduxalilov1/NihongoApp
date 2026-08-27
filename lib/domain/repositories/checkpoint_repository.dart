import '../entities/checkpoint.dart';
import '../entities/practice_item.dart';

abstract class CheckpointRepository {
  /// Berilgan dars raqamidan keyin checkpoint bor-yo'qligini tekshiradi
  /// (masalan 5-darsdan keyin checkpoint bo'lsa, shu darsni tugatgach chiqadi).
  Future<Checkpoint?> getCheckpointAfterLesson(int lessonId);

  Future<List<QuizQuestion>> getCheckpointQuestions(int checkpointId);

  Future<void> saveResult(CheckpointResult result);

  /// Foydalanuvchi shu checkpoint'ni o'tganmi (kamida bir marta pass_score dan yuqori)
  Future<bool> hasPassedCheckpoint(int checkpointId);
}
