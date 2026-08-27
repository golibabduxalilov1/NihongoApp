import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/entities/grammar_point.dart';
import '../../domain/entities/practice_item.dart';
import 'repository_providers.dart';

/// Barcha darslar ro'yxati (bosh ekran uchun)
final lessonsListProvider = FutureProvider<List<Lesson>>((ref) async {
  final useCase = ref.watch(getLessonsUseCaseProvider);
  return useCase.call();
});

/// Bitta darsning tafsilotlari (id bo'yicha)
final lessonByIdProvider =
    FutureProvider.family<Lesson?, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessonById(lessonId);
});

/// Dars uchun lug'at ro'yxati
final vocabularyForLessonProvider =
    FutureProvider.family<List<VocabularyItem>, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getVocabularyForLesson(lessonId);
});

/// Dars uchun grammatika nuqtalari
final grammarForLessonProvider =
    FutureProvider.family<List<GrammarPoint>, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getGrammarForLesson(lessonId);
});

/// Dars + bosqich uchun mashqlar
class PracticeParams {
  final int lessonId;
  final int stage;
  const PracticeParams(this.lessonId, this.stage);

  @override
  bool operator ==(Object other) =>
      other is PracticeParams &&
      other.lessonId == lessonId &&
      other.stage == stage;

  @override
  int get hashCode => Object.hash(lessonId, stage);
}

final practiceItemsProvider =
    FutureProvider.family<List<PracticeItem>, PracticeParams>(
        (ref, params) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getPracticeItemsForLesson(params.lessonId, params.stage);
});

/// Dars oxiridagi quiz savollari
final lessonQuizProvider =
    FutureProvider.family<List<QuizQuestion>, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getQuizQuestionsForLesson(lessonId);
});

/// Darsning qulf holati (checkpoint o'tilganmi)
final lessonUnlockedProvider =
    FutureProvider.family<bool, int>((ref, lessonId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.isLessonUnlocked(lessonId);
});
