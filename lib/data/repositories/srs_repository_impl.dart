import 'package:sqflite/sqflite.dart';
import '../../domain/entities/srs_state.dart';
import '../../domain/repositories/srs_repository.dart';
import '../../core/database/database_helper.dart';

class SrsRepositoryImpl implements SrsRepository {
  final DatabaseHelper _dbHelper;
  SrsRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<SrsState> getStateForVocabulary(int vocabularyId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'srs_state',
      where: 'vocabulary_id = ?',
      whereArgs: [vocabularyId],
    );

    if (rows.isEmpty) {
      // Birinchi marta ko'rilayotgan so'z — boshlang'ich holat
      return SrsState.initial(vocabularyId);
    }

    final row = rows.first;
    return SrsState(
      vocabularyId: row['vocabulary_id'] as int,
      easeFactor: row['ease_factor'] as double,
      intervalDays: row['interval_days'] as int,
      nextReviewDate: DateTime.parse(row['next_review_date'] as String),
      repetitions: row['repetitions'] as int,
    );
  }

  @override
  Future<void> saveState(SrsState state) async {
    final db = await _dbHelper.database;
    await db.insert(
      'srs_state',
      {
        'vocabulary_id': state.vocabularyId,
        'ease_factor': state.easeFactor,
        'interval_days': state.intervalDays,
        'next_review_date': state.nextReviewDate.toIso8601String(),
        'repetitions': state.repetitions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<int>> getDueVocabularyIds(int lessonId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final rows = await db.rawQuery('''
      SELECT v.id FROM vocabulary v
      LEFT JOIN srs_state s ON s.vocabulary_id = v.id
      WHERE v.lesson_id = ?
        AND (s.next_review_date IS NULL OR s.next_review_date <= ?)
    ''', [lessonId, now]);

    return rows.map((r) => r['id'] as int).toList();
  }
}
