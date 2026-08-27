import '../../domain/entities/writing_practice_item.dart';
import '../../domain/repositories/writing_practice_repository.dart';
import '../../core/database/database_helper.dart';

class WritingPracticeRepositoryImpl implements WritingPracticeRepository {
  final DatabaseHelper _dbHelper;
  WritingPracticeRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<WritingPracticeItem>> getItemsForLesson(int? lessonId) async {
    final db = await _dbHelper.database;
    final rows = lessonId == null
        ? await db.query('writing_practice')
        : await db.query('writing_practice', where: 'lesson_id = ?', whereArgs: [lessonId]);
    return rows.map(_mapRow).toList();
  }

  @override
  Future<List<WritingPracticeItem>> getItemsByType(CharacterType type) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'writing_practice',
      where: 'character_type = ?',
      whereArgs: [type.name],
    );
    return rows.map(_mapRow).toList();
  }

  WritingPracticeItem _mapRow(Map<String, dynamic> r) {
    return WritingPracticeItem(
      id: r['id'] as int,
      lessonId: r['lesson_id'] as int?,
      character: r['character'] as String,
      romaji: r['romaji'] as String?,
      strokeOrderSvgPath: r['stroke_order_svg_path'] as String?,
      strokeCount: r['stroke_count'] as int,
      characterType: CharacterType.fromString(r['character_type'] as String),
    );
  }

  @override
  Future<void> saveAttempt(WritingAttempt attempt) async {
    final db = await _dbHelper.database;
    await db.insert('writing_attempts', {
      'writing_practice_id': attempt.writingPracticeId,
      'accuracy_score': attempt.accuracyScore,
      'attempted_at': attempt.attemptedAt.toIso8601String(),
    });
  }
}
