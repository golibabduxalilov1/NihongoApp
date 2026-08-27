import '../../domain/entities/mistake_log_entry.dart';
import '../../domain/repositories/mistake_repository.dart';
import '../../core/database/database_helper.dart';

class MistakeRepositoryImpl implements MistakeRepository {
  final DatabaseHelper _dbHelper;
  MistakeRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> logMistake(MistakeLogEntry entry) async {
    final db = await _dbHelper.database;
    await db.insert('mistake_log', {
      'practice_item_id': entry.practiceItemId,
      'quiz_question_id': entry.quizQuestionId,
      'lesson_id': entry.lessonId,
      'topic_tag': entry.topicTag,
      'selected_answer': entry.selectedAnswer,
      'correct_answer': entry.correctAnswer,
      'created_at': entry.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<WeakPoint>> getWeakPoints({int limit = 10}) async {
    final db = await _dbHelper.database;

    // topic_tag bo'yicha guruhlab, xatolar sonini hisoblaymiz.
    // topic_tag null bo'lgan yozuvlar tahlilga kirmaydi (umumiy xato,
    // aniq mavzuga bog'lanmagan).
    final rows = await db.rawQuery('''
      SELECT topic_tag, lesson_id, COUNT(*) as mistake_count
      FROM mistake_log
      WHERE topic_tag IS NOT NULL
      GROUP BY topic_tag
      ORDER BY mistake_count DESC
      LIMIT ?
    ''', [limit]);

    return rows.map((r) {
      final tag = r['topic_tag'] as String;
      return WeakPoint(
        topicTag: tag,
        displayName: _humanizeTopicTag(tag),
        mistakeCount: r['mistake_count'] as int,
        lessonId: r['lesson_id'] as int,
      );
    }).toList();
  }

  /// "particle_wa" -> "は zarrachasi" kabi o'qish uchun qulay nomga aylantiradi.
  String _humanizeTopicTag(String tag) {
    const knownTags = {
      'particle_wa': 'は zarrachasi',
      'particle_ga': 'が zarrachasi',
      'particle_wo': 'を zarrachasi',
      'particle_ni': 'に zarrachasi',
      'particle_de': 'で zarrachasi',
    };
    return knownTags[tag] ?? tag;
  }

  @override
  Future<List<MistakeLogEntry>> getMistakesForLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'mistake_log',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'created_at DESC',
    );

    return rows.map((r) {
      return MistakeLogEntry(
        id: r['id'] as int,
        practiceItemId: r['practice_item_id'] as int?,
        quizQuestionId: r['quiz_question_id'] as int?,
        lessonId: r['lesson_id'] as int,
        topicTag: r['topic_tag'] as String?,
        selectedAnswer: r['selected_answer'] as String?,
        correctAnswer: r['correct_answer'] as String?,
        createdAt: DateTime.parse(r['created_at'] as String),
      );
    }).toList();
  }
}
