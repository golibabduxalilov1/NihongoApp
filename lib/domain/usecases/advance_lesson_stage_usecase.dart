import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Foydalanuvchi bir bosqichni tugatganda chaqiriladi.
/// Ketma-ketlik qoidasini shu yerda amalga oshiramiz: 7-bosqichdan keyin
/// dars "completed" bo'ladi, aks holda keyingi bosqichga o'tadi.
class AdvanceLessonStageUseCase {
  final LessonRepository repository;
  AdvanceLessonStageUseCase(this.repository);

  static const int totalStages = 7;

  Future<void> call(int lessonId, int completedStage) async {
    if (completedStage < totalStages) {
      await repository.updateLessonStage(lessonId, completedStage + 1);
    }
    // completedStage == totalStages bo'lsa, keyingi qadam dars-quiz —
    // uni SubmitLessonQuizUseCase orqali yakunlaymiz, bu yerda emas.
  }

  /// Foydalanuvchi shu bosqichga kira oladimi (avvalgi bosqich tugaganmi)
  bool canAccessStage(Lesson lesson, int requestedStage) {
    if (requestedStage == 1) return true;
    return lesson.currentStage >= requestedStage ||
        lesson.status == LessonCompletionStatus.completed;
  }
}
