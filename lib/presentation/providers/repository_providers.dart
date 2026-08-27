import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../data/repositories/srs_repository_impl.dart';
import '../../data/repositories/checkpoint_repository_impl.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/srs_repository.dart';
import '../../domain/repositories/checkpoint_repository.dart';
import '../../domain/usecases/get_lessons_usecase.dart';
import '../../domain/usecases/advance_lesson_stage_usecase.dart';
import '../../domain/usecases/submit_lesson_quiz_usecase.dart';
import '../../domain/usecases/review_flashcard_usecase.dart';
import '../../domain/usecases/evaluate_checkpoint_usecase.dart';

// --- Repositorylar (Data qatlami -> Domain interfeysi) ---

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepositoryImpl();
});

final srsRepositoryProvider = Provider<SrsRepository>((ref) {
  return SrsRepositoryImpl();
});

final checkpointRepositoryProvider = Provider<CheckpointRepository>((ref) {
  return CheckpointRepositoryImpl();
});

// --- Use case'lar (Domain qatlami biznes-logikasi) ---

final getLessonsUseCaseProvider = Provider<GetLessonsUseCase>((ref) {
  return GetLessonsUseCase(ref.watch(lessonRepositoryProvider));
});

final advanceLessonStageUseCaseProvider =
    Provider<AdvanceLessonStageUseCase>((ref) {
  return AdvanceLessonStageUseCase(ref.watch(lessonRepositoryProvider));
});

final submitLessonQuizUseCaseProvider =
    Provider<SubmitLessonQuizUseCase>((ref) {
  return SubmitLessonQuizUseCase(ref.watch(lessonRepositoryProvider));
});

final reviewFlashcardUseCaseProvider =
    Provider<ReviewFlashcardUseCase>((ref) {
  return ReviewFlashcardUseCase(ref.watch(srsRepositoryProvider));
});

final evaluateCheckpointUseCaseProvider =
    Provider<EvaluateCheckpointUseCase>((ref) {
  return EvaluateCheckpointUseCase(ref.watch(checkpointRepositoryProvider));
});
