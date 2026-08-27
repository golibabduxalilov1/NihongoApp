import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite bazasini yaratish, ochish va versiyalashni boshqaradi.
/// Singleton pattern — butun ilova davomida bitta ulanish ishlatiladi.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  static const int _dbVersion = 1;
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
