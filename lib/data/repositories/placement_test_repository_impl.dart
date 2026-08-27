import 'dart:convert';
import '../../domain/entities/placement_test.dart';
import '../../domain/repositories/placement_test_repository.dart';
import '../../core/database/database_helper.dart';

class PlacementTestRepositoryImpl implements PlacementTestRepository {
  final DatabaseHelper _dbHelper;
  PlacementTestRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<PlacementTestQuestion>> getQuestions({int limit = 15}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'placement_test_questions',
      orderBy: 'difficulty_order ASC',
      limit: limit,
    );

    return rows.map((r) {
      final optionsJson = jsonDecode(r['options'] as String) as List;
      return PlacementTestQuestion(
        id: r['id'] as int,
        mapsToLessonId: r['maps_to_lesson_id'] as int,
        question: r['question'] as String,
        options: optionsJson.cast<String>(),
        correctOptionIndex: r['correct_option_index'] as int,
        difficultyOrder: r['difficulty_order'] as int,
      );
    }).toList();
  }

  @override
  Future<void> saveResult(PlacementTestResult result) async {
    final db = await _dbHelper.database;
    await db.insert('placement_test_results', {
      'recommended_lesson_id': result.recommendedLessonId,
      'score': result.score,
      'taken_at': result.takenAt.toIso8601String(),
    });
  }
}
