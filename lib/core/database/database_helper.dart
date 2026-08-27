import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite bazasini yaratish, ochish va versiyalashni boshqaradi.
/// Singleton pattern — butun ilova davomida bitta ulanish ishlatiladi.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  static const int _dbVersion = 2;
  static const String _dbName = 'nihongo_manzil.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Foreign key cheklovlarini yoqish (SQLite'da standart o'chirilgan)
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        book INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vocabulary (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        kanji TEXT,
        kana TEXT NOT NULL,
        romaji TEXT,
        translation_uz TEXT NOT NULL,
        translation_ru TEXT,
        example_sentence TEXT,
        example_sentence_romaji TEXT,
        audio_path TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE grammar_points (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        explanation TEXT NOT NULL,
        examples TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE practice_items (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        stage INTEGER NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        correct_answer TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_questions (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER,
        checkpoint_id INTEGER,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_option_index INTEGER NOT NULL,
        explanation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE checkpoints (
        id INTEGER PRIMARY KEY,
        from_lesson INTEGER NOT NULL,
        to_lesson INTEGER NOT NULL,
        pass_score INTEGER DEFAULT 70
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        lesson_id INTEGER PRIMARY KEY,
        current_stage INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'not_started',
        quiz_score INTEGER,
        updated_at TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE srs_state (
        vocabulary_id INTEGER PRIMARY KEY,
        ease_factor REAL DEFAULT 2.5,
        interval_days INTEGER DEFAULT 1,
        next_review_date TEXT NOT NULL,
        repetitions INTEGER DEFAULT 0,
        FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE checkpoint_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checkpoint_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        passed INTEGER NOT NULL,
        attempted_at TEXT NOT NULL,
        FOREIGN KEY (checkpoint_id) REFERENCES checkpoints (id) ON DELETE CASCADE
      )
    ''');

    // Tez-tez so'raladigan ustunlar uchun indekslar (NFR: so'rovlar < 100ms)
    await db.execute('CREATE INDEX idx_vocab_lesson ON vocabulary (lesson_id)');
    await db.execute('CREATE INDEX idx_grammar_lesson ON grammar_points (lesson_id)');
    await db.execute('CREATE INDEX idx_practice_lesson ON practice_items (lesson_id, stage)');
    await db.execute('CREATE INDEX idx_srs_next_review ON srs_state (next_review_date)');

    await _createV2Tables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
  }

  /// v2 da qo'shilgan barcha jadvallar (7 ta yirik yangi funksiya uchun).
  /// Alohida metodga chiqarilgan, chunki bir xil kod ham yangi o'rnatishda
  /// (_onCreate), ham eski bazani yangilashda (_onUpgrade) ishlaydi.
  Future<void> _createV2Tables(Database db) async {
    // === 1. Motivatsiya va odat shakllantirish ===
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_stats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        daily_goal_minutes INTEGER NOT NULL DEFAULT 20,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        streak_freeze_available INTEGER NOT NULL DEFAULT 1,
        last_active_date TEXT,
        minutes_studied_today INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // === 3. Moslashuvchan grammatika takrorlash (SRS grammatika uchun) ===
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grammar_srs_state (
        grammar_point_id INTEGER PRIMARY KEY,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 1,
        next_review_date TEXT NOT NULL,
        error_count INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (grammar_point_id) REFERENCES grammar_points (id) ON DELETE CASCADE
      )
    ''');

    // === 2. Xato tahlili va mikro-feedback ===
    // practice_items ga mistake_explanation ustunini qo'shamiz (variant -> tushuntirish).
    // SQLite'da ustun mavjudligini tekshirib, faqat yo'q bo'lsa qo'shamiz
    // (ALTER TABLE ADD COLUMN xato bermasligi uchun).
    final practiceCols = await db.rawQuery("PRAGMA table_info(practice_items)");
    final hasMistakeCol = practiceCols.any((c) => c['name'] == 'mistake_explanation');
    if (!hasMistakeCol) {
      await db.execute('ALTER TABLE practice_items ADD COLUMN mistake_explanation TEXT');
    }
    final hasTopicCol = practiceCols.any((c) => c['name'] == 'topic_tag');
    if (!hasTopicCol) {
      await db.execute('ALTER TABLE practice_items ADD COLUMN topic_tag TEXT');
    }

    // Foydalanuvchining har bir mashqda qilgan xatolarini saqlaymiz —
    // GetWeakPointsUseCase shu jadval asosida "zaif tomonlar"ni topadi.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mistake_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        practice_item_id INTEGER,
        quiz_question_id INTEGER,
        lesson_id INTEGER NOT NULL,
        topic_tag TEXT,
        selected_answer TEXT,
        correct_answer TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // === 4. Talaffuz va gapirish mashqi (shadowing) ===
    await db.execute('''
      CREATE TABLE IF NOT EXISTS speaking_items (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        prompt_text TEXT NOT NULL,
        prompt_romaji TEXT,
        prompt_translation_uz TEXT NOT NULL,
        reference_audio_path TEXT,
        is_kaiwa INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS speaking_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        speaking_item_id INTEGER NOT NULL,
        recognized_text TEXT,
        similarity_score REAL,
        attempted_at TEXT NOT NULL,
        FOREIGN KEY (speaking_item_id) REFERENCES speaking_items (id) ON DELETE CASCADE
      )
    ''');

    // === 5. Onboarding va joylashtirish testi ===
    await db.execute('''
      CREATE TABLE IF NOT EXISTS placement_test_questions (
        id INTEGER PRIMARY KEY,
        maps_to_lesson_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_option_index INTEGER NOT NULL,
        difficulty_order INTEGER NOT NULL,
        FOREIGN KEY (maps_to_lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS placement_test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recommended_lesson_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        taken_at TEXT NOT NULL,
        FOREIGN KEY (recommended_lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // === 6. Kanji/kana yozish mashqi (stroke order) ===
    await db.execute('''
      CREATE TABLE IF NOT EXISTS writing_practice (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER,
        character TEXT NOT NULL,
        romaji TEXT,
        stroke_order_svg_path TEXT,
        stroke_count INTEGER NOT NULL,
        character_type TEXT NOT NULL DEFAULT 'hiragana',
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS writing_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        writing_practice_id INTEGER NOT NULL,
        accuracy_score REAL,
        attempted_at TEXT NOT NULL,
        FOREIGN KEY (writing_practice_id) REFERENCES writing_practice (id) ON DELETE CASCADE
      )
    ''');

    // Indekslar
    await db.execute('CREATE INDEX IF NOT EXISTS idx_grammar_srs_next_review ON grammar_srs_state (next_review_date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_mistake_lesson ON mistake_log (lesson_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_mistake_topic ON mistake_log (topic_tag)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_speaking_lesson ON speaking_items (lesson_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_writing_lesson ON writing_practice (lesson_id)');

    // user_stats uchun boshlang'ich (yagona) qatorni yaratamiz, agar yo'q bo'lsa
    final existing = await db.query('user_stats', where: 'id = 1');
    if (existing.isEmpty) {
      await db.insert('user_stats', {
        'id': 1,
        'daily_goal_minutes': 20,
        'current_streak': 0,
        'longest_streak': 0,
        'streak_freeze_available': 1,
        'last_active_date': null,
        'minutes_studied_today': 0,
      });
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Faqat test/dev uchun: bazani to'liq tozalash
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('writing_attempts');
    await db.delete('writing_practice');
    await db.delete('placement_test_results');
    await db.delete('placement_test_questions');
    await db.delete('speaking_attempts');
    await db.delete('speaking_items');
    await db.delete('mistake_log');
    await db.delete('grammar_srs_state');
    await db.delete('user_stats');
    await db.delete('checkpoint_results');
    await db.delete('srs_state');
    await db.delete('user_progress');
    await db.delete('checkpoints');
    await db.delete('quiz_questions');
    await db.delete('practice_items');
    await db.delete('grammar_points');
    await db.delete('vocabulary');
    await db.delete('lessons');
  }
}
