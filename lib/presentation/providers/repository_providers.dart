import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../data/repositories/srs_repository_impl.dart';
import '../../data/repositories/checkpoint_repository_impl.dart';
import '../../data/repositories/user_stats_repository_impl.dart';
import '../../data/repositories/mistake_repository_impl.dart';
import '../../data/repositories/grammar_srs_repository_impl.dart';
import '../../data/repositories/speaking_repository_impl.dart';
import '../../data/repositories/placement_test_repository_impl.dart';
import '../../data/repositories/writing_practice_repository_impl.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/srs_repository.dart';
import '../../domain/repositories/checkpoint_repository.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../../domain/repositories/mistake_repository.dart';
import '../../domain/repositories/grammar_srs_repository.dart';
import '../../domain/repositories/speaking_repository.dart';
import '../../domain/repositories/placement_test_repository.dart';
import '../../domain/repositories/writing_practice_repository.dart';
import '../../domain/usecases/get_lessons_usecase.dart';
import '../../domain/usecases/advance_lesson_stage_usecase.dart';
import '../../domain/usecases/submit_lesson_quiz_usecase.dart';
import '../../domain/usecases/review_flashcard_usecase.dart';
import '../../domain/usecases/evaluate_checkpoint_usecase.dart';
import '../../domain/usecases/get_weak_points_usecase.dart';
import '../../domain/usecases/generate_targeted_practice_usecase.dart';
import '../../domain/usecases/placement_test_usecase.dart';
import '../../domain/usecases/record_study_activity_usecase.dart';
import '../../domain/usecases/review_grammar_usecase.dart';

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

final userStatsRepositoryProvider = Provider<UserStatsRepository>((ref) {
  return UserStatsRepositoryImpl();
});

final mistakeRepositoryProvider = Provider<MistakeRepository>((ref) {
  return MistakeRepositoryImpl();
});

final grammarSrsRepositoryProvider = Provider<GrammarSrsRepository>((ref) {
  return GrammarSrsRepositoryImpl();
});

final speakingRepositoryProvider = Provider<SpeakingRepository>((ref) {
  return SpeakingRepositoryImpl();
});

final placementTestRepositoryProvider = Provider<PlacementTestRepository>((ref) {
  return PlacementTestRepositoryImpl();
});

final writingPracticeRepositoryProvider = Provider<WritingPracticeRepository>((ref) {
  return WritingPracticeRepositoryImpl();
});

// --- Use case'lar (Domain qatlami biznes-logikasi) ---

final getLessonsUseCaseProvider = Provider<GetLessonsUseCase>((ref) {
  return GetLessonsUseCase(ref.watch(lessonRepositoryProvider));
});

final advanceLessonStageUseCaseProvider = Provider<AdvanceLessonStageUseCase>((ref) {
  return AdvanceLessonStageUseCase(ref.watch(lessonRepositoryProvider));
});

final submitLessonQuizUseCaseProvider = Provider<SubmitLessonQuizUseCase>((ref) {
  return SubmitLessonQuizUseCase(ref.watch(lessonRepositoryProvider));
});

final reviewFlashcardUseCaseProvider = Provider<ReviewFlashcardUseCase>((ref) {
  return ReviewFlashcardUseCase(ref.watch(srsRepositoryProvider));
});

final evaluateCheckpointUseCaseProvider = Provider<EvaluateCheckpointUseCase>((ref) {
  return EvaluateCheckpointUseCase(ref.watch(checkpointRepositoryProvider));
});

final getWeakPointsUseCaseProvider = Provider<GetWeakPointsUseCase>((ref) {
  return GetWeakPointsUseCase(ref.watch(mistakeRepositoryProvider));
});

final generateTargetedPracticeUseCaseProvider = Provider<GenerateTargetedPracticeUseCase>((ref) {
  return GenerateTargetedPracticeUseCase(
    ref.watch(lessonRepositoryProvider),
    ref.watch(mistakeRepositoryProvider),
  );
});

final placementTestUseCaseProvider = Provider<PlacementTestUseCase>((ref) {
  return PlacementTestUseCase(
    ref.watch(placementTestRepositoryProvider),
    ref.watch(lessonRepositoryProvider),
  );
});

final recordStudyActivityUseCaseProvider = Provider<RecordStudyActivityUseCase>((ref) {
  return RecordStudyActivityUseCase(ref.watch(userStatsRepositoryProvider));
});

final reviewGrammarUseCaseProvider = Provider<ReviewGrammarUseCase>((ref) {
  return ReviewGrammarUseCase(ref.watch(grammarSrsRepositoryProvider));
});
