import 'package:sqflite/sqflite.dart';
import '../../domain/entities/grammar_srs_state.dart';
import '../../domain/repositories/grammar_srs_repository.dart';
import '../../core/database/database_helper.dart';

class GrammarSrsRepositoryImpl implements GrammarSrsRepository {
  final DatabaseHelper _dbHelper;
  GrammarSrsRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<GrammarSrsState> getStateForGrammarPoint(int grammarPointId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'grammar_srs_state',
      where: 'grammar_point_id = ?',
      whereArgs: [grammarPointId],
    );

    if (rows.isEmpty) {
      return GrammarSrsState.initial(grammarPointId);
    }

    final row = rows.first;
    return GrammarSrsState(
      grammarPointId: row['grammar_point_id'] as int,
      easeFactor: row['ease_factor'] as double,
      intervalDays: row['interval_days'] as int,
      nextReviewDate: DateTime.parse(row['next_review_date'] as String),
      errorCount: row['error_count'] as int,
      repetitions: row['repetitions'] as int,
    );
  }

  @override
  Future<void> saveState(GrammarSrsState state) async {
    final db = await _dbHelper.database;
    await db.insert(
      'grammar_srs_state',
      {
        'grammar_point_id': state.grammarPointId,
        'ease_factor': state.easeFactor,
        'interval_days': state.intervalDays,
        'next_review_date': state.nextReviewDate.toIso8601String(),
        'error_count': state.errorCount,
        'repetitions': state.repetitions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<int>> getDueGrammarPointIds({List<int>? lessonIds}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    if (lessonIds == null || lessonIds.isEmpty) {
      final rows = await db.rawQuery('''
        SELECT g.id FROM grammar_points g
        LEFT JOIN grammar_srs_state s ON s.grammar_point_id = g.id
        WHERE s.next_review_date IS NULL OR s.next_review_date <= ?
        ORDER BY COALESCE(s.error_count, 0) DESC
      ''', [now]);
      return rows.map((r) => r['id'] as int).toList();
    }

    final placeholders = List.filled(lessonIds.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT g.id FROM grammar_points g
      LEFT JOIN grammar_srs_state s ON s.grammar_point_id = g.id
      WHERE g.lesson_id IN ($placeholders)
        AND (s.next_review_date IS NULL OR s.next_review_date <= ?)
      ORDER BY COALESCE(s.error_count, 0) DESC
    ''', [...lessonIds, now]);
    return rows.map((r) => r['id'] as int).toList();
  }
}
