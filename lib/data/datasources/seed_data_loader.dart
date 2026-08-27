import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

/// Ilova birinchi marta ishga tushganda bazani namunaviy 2 ta dars bilan
/// to'ldiradi. Bu MATNLAR Minna no Nihongo darsligidan OLINMAGAN — o'zim
/// yaratgan, formatga mos, litsenziyasiz namuna kontent (TZ bo'lim 11:
/// "namunaviy, litsenziyasiz test ma'lumotlari").
///
/// Haqiqiy foydalanish uchun foydalanuvchi Sozlamalar → Kontent import
/// orqali o'zining qonuniy darslik nusxasidan olingan JSON'ni yuklaydi.
class SeedDataLoader {
  final DatabaseHelper _dbHelper;
  SeedDataLoader({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<bool> isSeeded() async {
    final db = await _dbHelper.database;
    final rows = await db.query('lessons', limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> seedIfEmpty() async {
    if (await isSeeded()) return;

    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await _seedLesson1(txn);
      await _seedLesson2(txn);
      await _seedCheckpoint(txn);
    });
  }

  // ---------------------------------------------------------------------
  // 1-DARS: Tanishuv (namuna, Minna no Nihongo 1-darsi uslubida)
  // ---------------------------------------------------------------------
  Future<void> _seedLesson1(Transaction txn) async {
    await txn.insert('lessons', {
      'id': 1,
      'title': "1-dars: Tanishuv",
      'order_index': 1,
      'book': 1,
    });

    final vocab = [
      {
        'kanji': null,
        'kana': 'わたし',
        'romaji': 'watashi',
        'translation_uz': 'men',
        'translation_ru': 'я',
        'example_sentence': 'わたしは がくせいです。',
      },
      {
        'kanji': '学生',
        'kana': 'がくせい',
        'romaji': 'gakusei',
        'translation_uz': "talaba, o'quvchi",
        'translation_ru': 'студент',
        'example_sentence': 'わたしは がくせいです。',
      },
      {
        'kanji': '先生',
        'kana': 'せんせい',
        'romaji': 'sensei',
        'translation_uz': "o'qituvchi",
        'translation_ru': 'учитель',
        'example_sentence': 'あの ひとは せんせいです。',
      },
      {
        'kanji': null,
        'kana': 'かいしゃいん',
        'romaji': 'kaishain',
        'translation_uz': 'kompaniya xodimi',
        'translation_ru': 'сотрудник компании',
        'example_sentence': 'たなかさんは かいしゃいんです。',
      },
      {
        'kanji': null,
        'kana': 'はじめまして',
        'romaji': 'hajimemashite',
        'translation_uz': 'tanishganimdan xursandman',
        'translation_ru': 'очень приятно (при знакомстве)',
        'example_sentence': 'はじめまして。よろしく おねがいします。',
      },
    ];

    for (var i = 0; i < vocab.length; i++) {
      await txn.insert('vocabulary', {
        'id': 100 + i,
        'lesson_id': 1,
        ...vocab[i],
      });
    }

    final grammarExamples1 = [
      {'jp': 'わたしは たなかです。', 'translation': 'Men Tanakaman.'},
      {'jp': 'わたしは がくせいです。', 'translation': "Men talabaman."},
      {'jp': 'たなかさんは せんせいです。', 'translation': "Tanaka - o'qituvchi."},
    ];

    final grammarExamples2 = [
      {'jp': 'わたしは がくせいでは ありません。', 'translation': "Men talaba emasman."},
      {'jp': 'たなかさんは せんせいでは ありません。', 'translation': "Tanaka o'qituvchi emas."},
    ];

    await txn.insert('grammar_points', {
      'id': 100,
      'lesson_id': 1,
      'title': 'СУЩ1 は СУЩ2 です (A - B dir)',
      'explanation':
          "Bu eng asosiy gap tuzilmasi. 「は」zarrachasi mavzuni bildiradi "
          "(o'qilishi 'wa', yozilishi 'ha'). 「です」predikat qo'shimchasi "
          "bo'lib, ega bilan kesim orasidagi bog'lovchi vazifasini bajaradi, "
          "rus tilidagi 'является' ga o'xshaydi, lekin ko'proq odob-axloq "
          "shaklini bildiradi.",
      'examples': jsonEncode(grammarExamples1),
    });

    await txn.insert('grammar_points', {
      'id': 101,
      'lesson_id': 1,
      'title': 'СУЩ1 は СУЩ2 では ありません (A - B emas)',
      'explanation':
          "Inkor shakli. 「です」o'rniga 「では ありません」ishlatiladi "
          "(so'zlashuvda ko'pincha 「じゃ ありません」deyiladi). Diqqat: "
          "fe'l shakli o'zgarmaydi, faqat predikat qismi o'zgaradi.",
      'examples': jsonEncode(grammarExamples2),
    });

    // 4-bosqich: Tuzilmani mustahkamlash (controlled practice)
    await txn.insert('practice_items', {
      'id': 1000,
      'lesson_id': 1,
      'stage': 4,
      'type': 'fillBlank',
      'content': jsonEncode({
        'sentence': 'わたし＿　がくせいです。',
        'hint': "Mavzu zarrachasini qo'ying",
      }),
      'correct_answer': 'は',
    });
    await txn.insert('practice_items', {
      'id': 1001,
      'lesson_id': 1,
      'stage': 4,
      'type': 'multipleChoice',
      'content': jsonEncode({
        'question': "「たなかさんは せんせい＿。」 to'g'ri to'ldiring:",
        'options': ['です', 'ですか', 'ました', 'ません'],
      }),
      'correct_answer': 'です',
    });

    // 5-bosqich: Aralashtirilgan mashq
    await txn.insert('practice_items', {
      'id': 1002,
      'lesson_id': 1,
      'stage': 5,
      'type': 'rearrange',
      'content': jsonEncode({
        'words': ['わたしは', 'がくせいでは', 'ありません'],
        'instruction': "So'zlarni to'g'ri tartibga tering",
      }),
      'correct_answer': 'わたしは がくせいでは ありません',
    });

    // 6-bosqich: Erkin ishlatish
    await txn.insert('practice_items', {
      'id': 1003,
      'lesson_id': 1,
      'stage': 6,
      'type': 'openEnded',
      'content': jsonEncode({
        'prompt':
            "O'zingizni yapon tilida tanishtiring: ismingiz va kasbingiz "
                "(masalan がくせい, せんせい, かいしゃいん) haqida 2 gap yozing.",
      }),
      'correct_answer': null,
    });

    // 7-bosqich: Integratsiya
    await txn.insert('practice_items', {
      'id': 1004,
      'lesson_id': 1,
      'stage': 7,
      'type': 'openEnded',
      'content': jsonEncode({
        'prompt':
            "Qisqa tanishuv dialogini yozing: ikkita odam bir-biri bilan "
                "tanishadi, ism va kasbini so'raydi.",
      }),
      'correct_answer': null,
    });

    // Dars-oxiri quiz (8 savol)
    final quizQuestions = [
      {
        'question': "「はじめまして」nima ma'noni bildiradi?",
        'options': [
          'Tanishganimdan xursandman',
          'Rahmat',
          'Kechirasiz',
          'Xayr'
        ],
        'correct': 0,
      },
      {
        'question': "「学生」so'zining o'qilishi qanday?",
        'options': ['せんせい', 'がくせい', 'かいしゃいん', 'わたし'],
        'correct': 1,
      },
      {
        'question': "To'g'ri gapni tanlang:",
        'options': [
          'わたしは がくせいです。',
          'わたしを がくせいです。',
          'わたしに がくせいです。',
          'わたしが がくせいます。'
        ],
        'correct': 0,
      },
      {
        'question': "Inkor shaklda qaysi variant to'g'ri?",
        'options': [
          'せんせいでは ありません',
          'せんせいます ありません',
          'せんせいでした ありません',
          'せんせいく ありません'
        ],
        'correct': 0,
      },
      {
        'question': "「先生」ning tarjimasi:",
        'options': ["Talaba", "O'qituvchi", 'Kompaniya xodimi', 'Do\'st'],
        'correct': 1,
      },
      {
        'question': "「かいしゃいん」kim?",
        'options': ["O'qituvchi", 'Talaba', 'Kompaniya xodimi', 'Shifokor'],
        'correct': 2,
      },
      {
        'question': "「は」zarrachasi nima vazifa bajaradi?",
        'options': [
          "Mavzuni ko'rsatadi",
          "O'rinni ko'rsatadi",
          "Vaqtni ko'rsatadi",
          "Egalikni ko'rsatadi"
        ],
        'correct': 0,
      },
      {
        'question': "「です」so'zlashuvda qanday vazifa bajaradi?",
        'options': [
          'Fe\'l',
          'Ega bilan kesimni bog\'laydi',
          "Savol yasaydi",
          "Ko'plik yasaydi"
        ],
        'correct': 1,
      },
    ];

    for (var i = 0; i < quizQuestions.length; i++) {
      final q = quizQuestions[i];
      await txn.insert('quiz_questions', {
        'id': 5000 + i,
        'lesson_id': 1,
        'checkpoint_id': null,
        'question': q['question'],
        'options': jsonEncode(q['options']),
        'correct_option_index': q['correct'],
      });
    }

    await txn.insert('user_progress', {
      'lesson_id': 1,
      'current_stage': 1,
      'status': 'not_started',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------
  // 2-DARS: Bu nima? (buyum va ko'rsatish olmoshlari)
  // ---------------------------------------------------------------------
  Future<void> _seedLesson2(Transaction txn) async {
    await txn.insert('lessons', {
      'id': 2,
      'title': "2-dars: Bu nima?",
      'order_index': 2,
      'book': 1,
    });

    final vocab = [
      {
        'kanji': null,
        'kana': 'これ',
        'romaji': 'kore',
        'translation_uz': 'bu (gapiruvchiga yaqin)',
        'translation_ru': 'это (близко к говорящему)',
        'example_sentence': 'これは ほんです。',
      },
      {
        'kanji': null,
        'kana': 'それ',
        'romaji': 'sore',
        'translation_uz': 'u (tinglovchiga yaqin)',
        'translation_ru': 'то (близко к слушающему)',
        'example_sentence': 'それは わたしの かさです。',
      },
      {
        'kanji': '本',
        'kana': 'ほん',
        'romaji': 'hon',
        'translation_uz': 'kitob',
        'translation_ru': 'книга',
        'example_sentence': 'これは にほんごの ほんです。',
      },
      {
        'kanji': null,
        'kana': 'かさ',
        'romaji': 'kasa',
        'translation_uz': 'soyabon',
        'translation_ru': 'зонт',
        'example_sentence': 'それは たなかさんの かさです。',
      },
      {
        'kanji': null,
        'kana': 'なん',
        'romaji': 'nan',
        'translation_uz': 'nima',
        'translation_ru': 'что',
        'example_sentence': 'これは なんですか。',
      },
    ];

    for (var i = 0; i < vocab.length; i++) {
      await txn.insert('vocabulary', {
        'id': 200 + i,
        'lesson_id': 2,
        ...vocab[i],
      });
    }

    await txn.insert('grammar_points', {
      'id': 200,
      'lesson_id': 2,
      'title': 'これ／それ／あれ (ko\'rsatish olmoshlari)',
      'explanation':
          "これ — gapiruvchiga yaqin narsa, それ — tinglovchiga yaqin narsa, "
          "あれ — ikkalasidan ham uzoqdagi narsa. Bu olmoshlar mustaqil "
          "ishlatiladi (ot bilan birga kelmaydi), masalan これは ほんです "
          "to'g'ri, lekin これ ほんは xato.",
      'examples': jsonEncode([
        {'jp': 'これは ほんです。', 'translation': 'Bu kitob.'},
        {'jp': 'それは かさですか。', 'translation': 'U soyabonmi?'},
      ]),
    });

    await txn.insert('grammar_points', {
      'id': 201,
      'lesson_id': 2,
      'title': 'СУЩ は なんですか (Bu nima?)',
      'explanation':
          "「なん」so'roq olmoshi 'nima' ma'nosini bildiradi. Savol gapida "
          "「か」zarrachasi jumla oxiriga qo'shiladi, va yapon tilida savol "
          "belgisi shart emas (garchi ba'zi zamonaviy matnlarda ishlatilsa ham).",
      'examples': jsonEncode([
        {'jp': 'これは なんですか。', 'translation': 'Bu nima?'},
        {'jp': '……ほんです。', 'translation': '...Kitob.'},
      ]),
    });

    await txn.insert('practice_items', {
      'id': 2000,
      'lesson_id': 2,
      'stage': 4,
      'type': 'fillBlank',
      'content': jsonEncode({
        'sentence': '＿＿は ほんです。（gapiruvchiga yaqin narsa)',
        'hint': "3 harfli ko'rsatish olmoshi",
      }),
      'correct_answer': 'これ',
    });
    await txn.insert('practice_items', {
      'id': 2001,
      'lesson_id': 2,
      'stage': 4,
      'type': 'multipleChoice',
      'content': jsonEncode({
        'question': "「これは＿ですか。」nima so'ralmoqda?",
        'options': ['kim', 'nima', 'qayer', 'qachon'],
      }),
      'correct_answer': 'nima',
    });

    await txn.insert('practice_items', {
      'id': 2002,
      'lesson_id': 2,
      'stage': 5,
      'type': 'rearrange',
      'content': jsonEncode({
        'words': ['それは', 'たなかさんの', 'かさです'],
        'instruction': "So'zlarni to'g'ri tartibga tering",
      }),
      'correct_answer': 'それは たなかさんの かさです',
    });

    await txn.insert('practice_items', {
      'id': 2003,
      'lesson_id': 2,
      'stage': 6,
      'type': 'openEnded',
      'content': jsonEncode({
        'prompt':
            "Stolingizda turgan 3 ta narsani これ/それ bilan tasvirlab yozing.",
      }),
      'correct_answer': null,
    });

    await txn.insert('practice_items', {
      'id': 2004,
      'lesson_id': 2,
      'stage': 7,
      'type': 'openEnded',
      'content': jsonEncode({
        'prompt':
            "Do'stingiz bilan biror narsa haqida savol-javob dialogini yozing "
                "(なん ва これ/それ ishlatib).",
      }),
      'correct_answer': null,
    });

    final quizQuestions = [
      {
        'question': "Gapiruvchiga yaqin narsa uchun qaysi olmosh ishlatiladi?",
        'options': ['あれ', 'それ', 'これ', 'どれ'],
        'correct': 2,
      },
      {
        'question': "「本」so'zining tarjimasi:",
        'options': ['Soyabon', 'Kitob', 'Stol', 'Qalam'],
        'correct': 1,
      },
      {
        'question': "「なん」nima ma'noni bildiradi?",
        'options': ['Kim', 'Qayer', 'Nima', 'Qachon'],
        'correct': 2,
      },
      {
        'question': "To'g'ri savol gapini tanlang:",
        'options': [
          'これは なんですか。',
          'これ なん ですか。',
          'なんは これですか。',
          'これなん ですか'
        ],
        'correct': 0,
      },
      {
        'question': "Tinglovchiga yaqin narsa uchun:",
        'options': ['これ', 'あれ', 'それ', 'どこ'],
        'correct': 2,
      },
      {
        'question': "「かさ」ning ma'nosi:",
        'options': ['Kitob', 'Soyabon', 'Sumka', 'Soat'],
        'correct': 1,
      },
      {
        'question': "「それは わたしの ＿です。」 — bu yerga soyabon so'zi qo'yilsa:",
        'options': ['ほん', 'かさ', 'がくせい', 'せんせい'],
        'correct': 1,
      },
      {
        'question': "Ko'rsatish olmoshlari ot bilan qanday ishlatiladi?",
        'options': [
          "Ot bilan birga kelmaydi, mustaqil ishlatiladi",
          "Ot bilan qo'shilib yoziladi",
          "Otdan keyin kelishi shart",
          "Faqat savol gapida ishlatiladi"
        ],
        'correct': 0,
      },
    ];

    for (var i = 0; i < quizQuestions.length; i++) {
      final q = quizQuestions[i];
      await txn.insert('quiz_questions', {
        'id': 6000 + i,
        'lesson_id': 2,
        'checkpoint_id': null,
        'question': q['question'],
        'options': jsonEncode(q['options']),
        'correct_option_index': q['correct'],
      });
    }

    await txn.insert('user_progress', {
      'lesson_id': 2,
      'current_stage': 1,
      'status': 'not_started',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------
  // CHECKPOINT: 1-2 darslardan keyingi aralash imtihon
  // (haqiqiy ilovada bu odatda har 5 darsdan keyin, demo uchun 2 dan keyin)
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
}
