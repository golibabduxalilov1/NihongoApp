import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// `assets/sample_data/lessons/lesson_NN.json` fayllaridan darslar
/// kontentini (lug'at, grammatika, mashqlar, quiz) o'qib bazaga yozadi.
///
/// Har bir fayl [lessonTemplateSchema] (assets/sample_data/lesson_template.json)
/// bilan bir xil formatda bo'lishi kerak: `lesson`, `vocabulary`, `grammar`,
/// `practice_items`, `quiz_questions` maydonlari.
///
/// Fayllar `lesson_01.json` dan boshlab ketma-ket raqamlanadi; birinchi
/// topilmagan raqamda qidiruv to'xtaydi. `maxLessons` shu tartibsiz
/// ro'yxatni cheklab qo'yish uchun xavfsizlik chegarasi.
class JsonLessonLoader {
  final String assetDir;
  final int maxLessons;

  JsonLessonLoader({
    this.assetDir = 'assets/sample_data/lessons',
    this.maxLessons = 200,
  });

  /// `lesson_01.json`, `lesson_02.json`, ... fayllarini ketma-ket o'qib,
  /// har birini [txn] orqali bazaga yozadi. Nechta dars yozilganini qaytaradi.
  Future<int> loadAll(Transaction txn) async {
    var loaded = 0;
    for (var n = 1; n <= maxLessons; n++) {
      final fileName = 'lesson_${n.toString().padLeft(2, '0')}.json';
      final assetPath = '$assetDir/$fileName';

      String raw;
      try {
        raw = await rootBundle.loadString(assetPath);
      } catch (_) {
        // Fayl topilmadi — ketma-ket raqamlash shu yerda uziladi deb hisoblaymiz.
        break;
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      await _loadLesson(txn, json, fallbackId: n);
      loaded++;
    }
    return loaded;
  }

  Future<void> _loadLesson(
    Transaction txn,
    Map<String, dynamic> json, {
    required int fallbackId,
  }) async {
    final lessonJson = json['lesson'] as Map<String, dynamic>;
    final lessonId = (lessonJson['id'] as int?) ?? fallbackId;

    await txn.insert(
      'lessons',
      {
        'id': lessonId,
        'title': lessonJson['title'] as String,
        'order_index': lessonJson['order_index'] as int,
        'book': lessonJson['book'] as int,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final vocabulary = (json['vocabulary'] as List?) ?? const [];
    for (var i = 0; i < vocabulary.length; i++) {
      final v = vocabulary[i] as Map<String, dynamic>;
      await txn.insert(
        'vocabulary',
        {
          'id': lessonId * 1000 + 100 + i,
          'lesson_id': lessonId,
          'kanji': v['kanji'] as String?,
          'kana': v['kana'] as String,
          'romaji': v['romaji'] as String?,
          'translation_uz': v['translation_uz'] as String,
          'translation_ru': v['translation_ru'] as String?,
          'example_sentence': v['example_sentence'] as String?,
          'example_sentence_romaji': v['example_sentence_romaji'] as String?,
          'audio_path': v['audio_path'] as String?,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final grammar = (json['grammar'] as List?) ?? const [];
    for (var i = 0; i < grammar.length; i++) {
      final g = grammar[i] as Map<String, dynamic>;
      await txn.insert(
        'grammar_points',
        {
          'id': lessonId * 1000 + 200 + i,
          'lesson_id': lessonId,
          'title': g['title'] as String,
          'explanation': g['explanation'] as String,
          'examples': jsonEncode(g['examples']),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final practiceItems = (json['practice_items'] as List?) ?? const [];
    for (var i = 0; i < practiceItems.length; i++) {
      final p = practiceItems[i] as Map<String, dynamic>;
      final mistakeExplanation = p['mistake_explanation'];
      await txn.insert(
        'practice_items',
        {
          'id': lessonId * 1000 + 300 + i,
          'lesson_id': lessonId,
          'stage': p['stage'] as int,
          'type': p['type'] as String,
          'content': jsonEncode(p['content']),
          'correct_answer': p['correct_answer'] as String?,
          'topic_tag': p['topic_tag'] as String?,
          'mistake_explanation':
              mistakeExplanation == null ? null : jsonEncode(mistakeExplanation),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final quizQuestions = (json['quiz_questions'] as List?) ?? const [];
    for (var i = 0; i < quizQuestions.length; i++) {
      final q = quizQuestions[i] as Map<String, dynamic>;
      await txn.insert(
        'quiz_questions',
        {
          'id': lessonId * 1000 + 500 + i,
          'lesson_id': lessonId,
          'checkpoint_id': null,
          'question': q['question'] as String,
          'options': jsonEncode(q['options']),
          'correct_option_index': q['correct_option_index'] as int,
          'explanation': q['explanation'] as String?,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await txn.insert(
      'user_progress',
      {
        'lesson_id': lessonId,
        'current_stage': 1,
        'status': 'not_started',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
