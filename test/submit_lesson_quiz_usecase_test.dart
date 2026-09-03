import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_comet/domain/entities/lesson.dart';
import 'package:nihongo_comet/domain/entities/vocabulary.dart';
import 'package:nihongo_comet/domain/entities/grammar_point.dart';
import 'package:nihongo_comet/domain/entities/practice_item.dart';
import 'package:nihongo_comet/domain/repositories/lesson_repository.dart';
import 'package:nihongo_comet/domain/usecases/submit_lesson_quiz_usecase.dart';

/// Repository'ning soxta (fake) implementatsiyasi — haqiqiy SQLite
/// kerak emas, faqat use case logikasini izolyatsiyada tekshiramiz.
class _FakeLessonRepository implements LessonRepository {
  bool markedCompleted = false;
  int? lastScore;

  @override
  Future<void> markLessonCompleted(int lessonId, int quizScore) async {
    markedCompleted = true;
    lastScore = quizScore;
  }

  @override
  Future<List<Lesson>> getAllLessons({int? book}) async => [];
  @override
  Future<Lesson?> getLessonById(int id) async => null;
  @override
  Future<List<VocabularyItem>> getVocabularyForLesson(int lessonId) async => [];
  @override
  Future<List<GrammarPoint>> getGrammarForLesson(int lessonId) async => [];
  @override
  Future<List<PracticeItem>> getPracticeItemsForLesson(
          int lessonId, int stage) async =>
      [];
  @override
  Future<List<QuizQuestion>> getQuizQuestionsForLesson(int lessonId) async =>
      [];
  @override
  Future<void> updateLessonStage(int lessonId, int newStage) async {}
  @override
  Future<bool> isLessonUnlocked(int lessonId) async => true;
}

void main() {
  group('SubmitLessonQuizUseCase', () {
    test('70% dan yuqori ball bo\'lsa dars completed deb belgilanadi', () async {
      final fakeRepo = _FakeLessonRepository();
      final useCase = SubmitLessonQuizUseCase(fakeRepo);

      // 10 savoldan 8 tasi to'g'ri = 80%
      final correctAnswers = {for (var i = 0; i < 10; i++) i: 0};
      final answers = {for (var i = 0; i < 8; i++) i: 0}
        ..addAll({8: 1, 9: 1}); // oxirgi 2 tasi xato

      final result = await useCase.call(
        lessonId: 1,
        answers: answers,
        correctAnswers: correctAnswers,
      );

      expect(result.score, 80);
      expect(result.passed, true);
      expect(fakeRepo.markedCompleted, true);
      expect(fakeRepo.lastScore, 80);
    });

    test('70% dan past ball bo\'lsa dars completed deb belgilanmaydi', () async {
      final fakeRepo = _FakeLessonRepository();
      final useCase = SubmitLessonQuizUseCase(fakeRepo);

      final correctAnswers = {for (var i = 0; i < 10; i++) i: 0};
      final answers = {for (var i = 0; i < 5; i++) i: 0}
        ..addAll({for (var i = 5; i < 10; i++) i: 1});

      final result = await useCase.call(
        lessonId: 1,
        answers: answers,
        correctAnswers: correctAnswers,
      );

      expect(result.score, 50);
      expect(result.passed, false);
      expect(fakeRepo.markedCompleted, false);
    });

    test('aynan 70% bo\'lsa ham o\'tgan hisoblanadi (chegara holati)', () async {
      final fakeRepo = _FakeLessonRepository();
      final useCase = SubmitLessonQuizUseCase(fakeRepo);

      final correctAnswers = {for (var i = 0; i < 10; i++) i: 0};
      final answers = {for (var i = 0; i < 7; i++) i: 0}
        ..addAll({for (var i = 7; i < 10; i++) i: 1});

      final result = await useCase.call(
        lessonId: 1,
        answers: answers,
        correctAnswers: correctAnswers,
      );

      expect(result.score, 70);
      expect(result.passed, true);
    });
  });
}
