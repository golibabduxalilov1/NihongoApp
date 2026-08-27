import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/entities/grammar_point.dart';
import '../../domain/entities/practice_item.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../core/database/database_helper.dart';

class LessonRepositoryImpl implements LessonRepository {
  final DatabaseHelper _dbHelper;
  LessonRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Lesson>> getAllLessons({int? book}) async {
    final db = await _dbHelper.database;

    final whereClause = book != null ? 'WHERE l.book = ?' : '';
    final whereArgs = book != null ? [book] : <dynamic>[];

    final rows = await db.rawQuery('''
      SELECT l.id, l.title, l.order_index, l.book,
             COALESCE(up.current_stage, 1) as current_stage,
             COALESCE(up.status, 'not_started') as status,
             up.quiz_score
      FROM lessons l
      LEFT JOIN user_progress up ON up.lesson_id = l.id
      $whereClause
      ORDER BY l.order_index ASC
    ''', whereArgs);

    return rows.map(_mapRowToLesson).toList();
  }

  @override
  Future<Lesson?> getLessonById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT l.id, l.title, l.order_index, l.book,
             COALESCE(up.current_stage, 1) as current_stage,
             COALESCE(up.status, 'not_started') as status,
             up.quiz_score
      FROM lessons l
      LEFT JOIN user_progress up ON up.lesson_id = l.id
      WHERE l.id = ?
    ''', [id]);

    if (rows.isEmpty) return null;
    return _mapRowToLesson(rows.first);
  }

  Lesson _mapRowToLesson(Map<String, dynamic> row) {
    LessonCompletionStatus status;
    switch (row['status'] as String) {
      case 'completed':
        status = LessonCompletionStatus.completed;
        break;
      case 'in_progress':
        status = LessonCompletionStatus.inProgress;
        break;
      default:
        status = LessonCompletionStatus.notStarted;
    }

    return Lesson(
      id: row['id'] as int,
      title: row['title'] as String,
      orderIndex: row['order_index'] as int,
      book: row['book'] as int,
      currentStage: row['current_stage'] as int,
      status: status,
      quizScore: row['quiz_score'] as int?,
    );
  }

  @override
  Future<List<VocabularyItem>> getVocabularyForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'vocabulary',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return rows.map((r) => VocabularyItem.fromMap(r)).toList();
  }

  @override
  Future<List<GrammarPoint>> getGrammarForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'grammar_points',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    return rows.map((r) {
      final examplesJson = jsonDecode(r['examples'] as String) as List;
      return GrammarPoint(
        id: r['id'] as int,
        lessonId: r['lesson_id'] as int,
        title: r['title'] as String,
        explanation: r['explanation'] as String,
        examples: examplesJson
            .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }

  @override
  Future<List<PracticeItem>> getPracticeItemsForLesson(
      int lessonId, int stage) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'practice_items',
      where: 'lesson_id = ? AND stage = ?',
      whereArgs: [lessonId, stage],
    );

    return rows.map((r) {
      return PracticeItem(
        id: r['id'] as int,
        lessonId: r['lesson_id'] as int,
        stage: r['stage'] as int,
        type: PracticeType.fromString(r['type'] as String),
        content: jsonDecode(r['content'] as String) as Map<String, dynamic>,
        correctAnswer: r['correct_answer'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<QuizQuestion>> getQuizQuestionsForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'quiz_questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    return rows.map(_mapRowToQuizQuestion).toList();
  }

  QuizQuestion _mapRowToQuizQuestion(Map<String, dynamic> r) {
    final optionsJson = jsonDecode(r['options'] as String) as List;
    return QuizQuestion(
      id: r['id'] as int,
      question: r['question'] as String,
      options: optionsJson.cast<String>(),
      correctOptionIndex: r['correct_option_index'] as int,
      explanation: r['explanation'] as String?,
    );
  }

  @override
  Future<void> updateLessonStage(int lessonId, int newStage) async {
    final db = await _dbHelper.database;
    await db.insert(
      'user_progress',
      {
        'lesson_id': lessonId,
        'current_stage': newStage,
        'status': 'in_progress',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> markLessonCompleted(int lessonId, int quizScore) async {
    final db = await _dbHelper.database;
    await db.insert(
      'user_progress',
      {
        'lesson_id': lessonId,
        'current_stage': 7,
        'status': 'completed',
        'quiz_score': quizScore,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> isLessonUnlocked(int lessonId) async {
    final db = await _dbHelper.database;

    // Shu darsdan oldingi eng yaqin checkpoint'ni topamiz
    final checkpointRows = await db.rawQuery('''
      SELECT c.id, c.pass_score
      FROM checkpoints c
      WHERE c.to_lesson < ?
      ORDER BY c.to_lesson DESC
      LIMIT 1
    ''', [lessonId]);

    if (checkpointRows.isEmpty) {
      return true; // checkpoint yo'q — cheklov yo'q
    }

    final checkpointId = checkpointRows.first['id'] as int;

    final resultRows = await db.query(
      'checkpoint_results',
      where: 'checkpoint_id = ? AND passed = 1',
      whereArgs: [checkpointId],
      limit: 1,
    );

    return resultRows.isNotEmpty;
  }
}
