import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import 'json_lesson_loader.dart';

/// Ilova birinchi marta ishga tushganda bazani darslar kontenti bilan
/// to'ldiradi. Darslarning o'zi (lug'at, grammatika, mashqlar, quiz)
/// `assets/sample_data/lessons/lesson_NN.json` fayllaridan [JsonLessonLoader]
/// orqali o'qiladi — bu yerdagi Dart kodida darslik matni saqlanmaydi.
///
/// Bu klass darslardan tashqari qolgan boshlang'ich ma'lumotlarni
/// (checkpoint, joylashtirish testi, yozuv/gapirish mashqlari uchun
/// umumiy, litsenziyasiz namunalar) ham yuklaydi.
class SeedDataLoader {
  final DatabaseHelper _dbHelper;
  final JsonLessonLoader _lessonLoader;
  SeedDataLoader({DatabaseHelper? dbHelper, JsonLessonLoader? lessonLoader})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _lessonLoader = lessonLoader ?? JsonLessonLoader();

  Future<bool> isSeeded() async {
    final db = await _dbHelper.database;
    final rows = await db.query('lessons', limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> seedIfEmpty() async {
    if (await isSeeded()) return;

    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await _lessonLoader.loadAll(txn);
      await _seedCheckpoint(txn);
      await _seedPlacementTest(txn);
      await _seedWritingPractice(txn);
      await _seedSpeakingPractice(txn);
    });
  }

  // ---------------------------------------------------------------------
  // CHECKPOINT: 1-2 darslardan keyingi aralash imtihon
  // TODO: darslar soni oshgani sayin (11-50) qo'shimcha checkpoint'lar
  // (masalan har 5 darsdan keyin) qo'shilishi kerak.
  // ---------------------------------------------------------------------
  Future<void> _seedCheckpoint(Transaction txn) async {
    await txn.insert('checkpoints', {
      'id': 1,
      'from_lesson': 1,
      'to_lesson': 2,
      'pass_score': 70,
    });

    final checkpointQuestions = [
      {
        'question': "「わたしは がくせいです。」jumlasini tarjima qiling:",
        'options': [
          "Men talabaman",
          "Sen o'qituvchisan",
          "U kompaniya xodimi",
          "Biz talabamiz"
        ],
        'correct': 0,
      },
      {
        'question': "これ/それ/あれ orasidagi farq nimada?",
        'options': [
          "Faqat shakl farqi, ma'no bir xil",
          "Masofaga qarab tanlanadi (gapiruvchi/tinglovchiga nisbatan)",
          "Faqat savol gapida farq bor",
          "Erkak va ayol uchun har xil"
        ],
        'correct': 1,
      },
      {
        'question': "「先生」va「学生」so'zlari orasidagi farq:",
        'options': [
          "Bir xil ma'no",
          "せんせい - o'qituvchi, がくせい - talaba",
          "せんせい - talaba, がくせい - o'qituvchi",
          "Ikkalasi ham kompaniya xodimi"
        ],
        'correct': 1,
      },
      {
        'question': "Inkor gap qanday tuziladi?",
        'options': [
          "です o'rniga ではありません",
          "です dan oldin ない qo'shiladi",
          "Gap oxiriga いいえ qo'shiladi",
          "Fe'l shakli butunlay o'zgaradi"
        ],
        'correct': 0,
      },
      {
        'question': "「これは なんですか。」ga to'g'ri javob namunasi:",
        'options': ['はい、そうです。', '……ほんです。', 'いいえ、ちがいます。', 'ありがとうございます。'],
        'correct': 1,
      },
      {
        'question': "「は」zarrachasi qanday o'qiladi (talaffuz)?",
        'options': ['ha', 'wa', 'he', 'ba'],
        'correct': 1,
      },
      {
        'question': "「かいしゃいん」kasbi qaysi?",
        'options': [
          "O'qituvchi",
          "Talaba",
          "Kompaniya xodimi",
          "Shifokor"
        ],
        'correct': 2,
      },
      {
        'question': "「それは たなかさんの かさです。」— kimning soyaboni?",
        'options': ["Mening", "Tanakaning", "O'qituvchining", "Talabaning"],
        'correct': 1,
      },
    ];

    for (var i = 0; i < checkpointQuestions.length; i++) {
      final q = checkpointQuestions[i];
      await txn.insert('quiz_questions', {
        'id': 7000 + i,
        'lesson_id': null,
        'checkpoint_id': 1,
        'question': q['question'],
        'options': jsonEncode(q['options']),
        'correct_option_index': q['correct'],
      });
    }
  }

  // ---------------------------------------------------------------------
  // PLACEMENT TEST: onboarding joylashtirish testi savollari
  // ---------------------------------------------------------------------
  Future<void> _seedPlacementTest(Transaction txn) async {
    final questions = [
      {
        'question': "「わたし＿ がくせいです。」to'g'ri zarrachani tanlang:",
        'options': ['は', 'を', 'に', 'で'],
        'correct': 0,
        'maps_to': 1,
        'order': 1,
      },
      {
        'question': "「はじめまして」nima ma'noni bildiradi?",
        'options': ['Rahmat', 'Tanishganimdan xursandman', 'Kechirasiz', 'Xayr'],
        'correct': 1,
        'maps_to': 1,
        'order': 2,
      },
      {
        'question': "Gapiruvchiga yaqin narsa uchun qaysi olmosh ishlatiladi?",
        'options': ['あれ', 'それ', 'これ', 'どれ'],
        'correct': 2,
        'maps_to': 2,
        'order': 3,
      },
      {
        'question': "「これは なんですか。」ga to'g'ri javob namunasi qanday boshlanadi?",
        'options': ['はい、そうです', '……ほんです', 'いいえ、ちがいます', 'ありがとう'],
        'correct': 1,
        'maps_to': 2,
        'order': 4,
      },
    ];

    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      await txn.insert('placement_test_questions', {
        'id': 8000 + i,
        'maps_to_lesson_id': q['maps_to'],
        'question': q['question'],
        'options': jsonEncode(q['options']),
        'correct_option_index': q['correct'],
        'difficulty_order': q['order'],
      });
    }
  }

  // ---------------------------------------------------------------------
  // WRITING PRACTICE: hiragana namunalari (litsenziyasiz, umumiy bilim)
  // ---------------------------------------------------------------------
  Future<void> _seedWritingPractice(Transaction txn) async {
    final characters = [
      {'char': 'あ', 'romaji': 'a', 'strokes': 3},
      {'char': 'い', 'romaji': 'i', 'strokes': 2},
      {'char': 'う', 'romaji': 'u', 'strokes': 2},
      {'char': 'え', 'romaji': 'e', 'strokes': 2},
      {'char': 'お', 'romaji': 'o', 'strokes': 3},
    ];

    for (var i = 0; i < characters.length; i++) {
      final c = characters[i];
      await txn.insert('writing_practice', {
        'id': 9000 + i,
        'lesson_id': null,
        'character': c['char'],
        'romaji': c['romaji'],
        'stroke_order_svg_path': null,
        'stroke_count': c['strokes'],
        'character_type': 'hiragana',
      });
    }
  }

  // ---------------------------------------------------------------------
  // SPEAKING PRACTICE: 1-dars uchun namuna shadowing/kaiwa elementlari
  // ---------------------------------------------------------------------
  Future<void> _seedSpeakingPractice(Transaction txn) async {
    final items = [
      {
        'text': 'はじめまして。よろしく おねがいします。',
        'romaji': 'Hajimemashite. Yoroshiku onegaishimasu.',
        'translation': 'Tanishganimdan xursandman. Yaxshi munosabatda bo\'laylik.',
        'is_kaiwa': 1,
      },
      {
        'text': 'わたしは がくせいです。',
        'romaji': 'Watashi wa gakusei desu.',
        'translation': 'Men talabaman.',
        'is_kaiwa': 0,
      },
    ];

    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      await txn.insert('speaking_items', {
        'id': 10000 + i,
        'lesson_id': 1,
        'prompt_text': it['text'],
        'prompt_romaji': it['romaji'],
        'prompt_translation_uz': it['translation'],
        'reference_audio_path': null,
        'is_kaiwa': it['is_kaiwa'],
      });
    }
  }
}
