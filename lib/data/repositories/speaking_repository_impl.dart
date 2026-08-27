import '../../domain/entities/speaking_item.dart';
import '../../domain/repositories/speaking_repository.dart';
import '../../core/database/database_helper.dart';

class SpeakingRepositoryImpl implements SpeakingRepository {
  final DatabaseHelper _dbHelper;
  SpeakingRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<SpeakingItem>> getSpeakingItemsForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('speaking_items', where: 'lesson_id = ?', whereArgs: [lessonId]);
    return rows.map(_mapRow).toList();
  }

  @override
  Future<List<SpeakingItem>> getKaiwaItemsForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'speaking_items',
      where: 'lesson_id = ? AND is_kaiwa = 1',
      whereArgs: [lessonId],
    );
    return rows.map(_mapRow).toList();
  }

  SpeakingItem _mapRow(Map<String, dynamic> r) {
    return SpeakingItem(
      id: r['id'] as int,
      lessonId: r['lesson_id'] as int,
      promptText: r['prompt_text'] as String,
      promptRomaji: r['prompt_romaji'] as String?,
      promptTranslationUz: r['prompt_translation_uz'] as String,
      referenceAudioPath: r['reference_audio_path'] as String?,
      isKaiwa: (r['is_kaiwa'] as int) == 1,
    );
  }

  @override
  Future<void> saveAttempt(SpeakingAttempt attempt) async {
    final db = await _dbHelper.database;
    await db.insert('speaking_attempts', {
      'speaking_item_id': attempt.speakingItemId,
      'recognized_text': attempt.recognizedText,
      'similarity_score': attempt.similarityScore,
      'attempted_at': attempt.attemptedAt.toIso8601String(),
    });
  }

  @override
  Future<List<SpeakingAttempt>> getAttemptsFor(int speakingItemId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'speaking_attempts',
      where: 'speaking_item_id = ?',
      whereArgs: [speakingItemId],
      orderBy: 'attempted_at DESC',
    );
    return rows.map((r) {
      return SpeakingAttempt(
        id: r['id'] as int,
        speakingItemId: r['speaking_item_id'] as int,
        recognizedText: r['recognized_text'] as String?,
        similarityScore: r['similarity_score'] as double?,
        attemptedAt: DateTime.parse(r['attempted_at'] as String),
      );
    }).toList();
  }
}
