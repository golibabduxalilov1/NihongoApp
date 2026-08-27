import 'dart:convert';
import '../../domain/entities/checkpoint.dart';
import '../../domain/entities/practice_item.dart';
import '../../domain/repositories/checkpoint_repository.dart';
import '../../core/database/database_helper.dart';

class CheckpointRepositoryImpl implements CheckpointRepository {
  final DatabaseHelper _dbHelper;
  CheckpointRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<Checkpoint?> getCheckpointAfterLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'checkpoints',
      where: 'to_lesson = ?',
      whereArgs: [lessonId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    final r = rows.first;
    return Checkpoint(
      id: r['id'] as int,
      fromLesson: r['from_lesson'] as int,
      toLesson: r['to_lesson'] as int,
      passScore: r['pass_score'] as int,
    );
  }

  @override
  Future<List<QuizQuestion>> getCheckpointQuestions(int checkpointId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'quiz_questions',
      where: 'checkpoint_id = ?',
      whereArgs: [checkpointId],
    );

    return rows.map((r) {
      final optionsJson = jsonDecode(r['options'] as String) as List;
      return QuizQuestion(
        id: r['id'] as int,
        question: r['question'] as String,
        options: optionsJson.cast<String>(),
        correctOptionIndex: r['correct_option_index'] as int,
        explanation: r['explanation'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> saveResult(CheckpointResult result) async {
    final db = await _dbHelper.database;
    await db.insert('checkpoint_results', {
      'checkpoint_id': result.checkpointId,
      'score': result.score,
      'passed': result.passed ? 1 : 0,
      'attempted_at': result.attemptedAt.toIso8601String(),
    });
  }

  @override
  Future<bool> hasPassedCheckpoint(int checkpointId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'checkpoint_results',
      where: 'checkpoint_id = ? AND passed = 1',
      whereArgs: [checkpointId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
