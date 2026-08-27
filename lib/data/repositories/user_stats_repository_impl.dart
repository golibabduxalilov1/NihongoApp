import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../../core/database/database_helper.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final DatabaseHelper _dbHelper;
  UserStatsRepositoryImpl({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<UserStats> getStats() async {
    final db = await _dbHelper.database;
    final rows = await db.query('user_stats', where: 'id = 1', limit: 1);

    if (rows.isEmpty) {
      final initial = UserStats.initial();
      await saveStats(initial);
      return initial;
    }

    return _mapRowToStats(rows.first);
  }

  UserStats _mapRowToStats(Map<String, dynamic> row) {
    return UserStats(
      dailyGoalMinutes: row['daily_goal_minutes'] as int,
      currentStreak: row['current_streak'] as int,
      longestStreak: row['longest_streak'] as int,
      streakFreezeAvailable: (row['streak_freeze_available'] as int) == 1,
      lastActiveDate:
          row['last_active_date'] != null ? DateTime.parse(row['last_active_date'] as String) : null,
      minutesStudiedToday: row['minutes_studied_today'] as int,
    );
  }

  @override
  Future<void> saveStats(UserStats stats) async {
    final db = await _dbHelper.database;
    await db.insert(
      'user_stats',
      {
        'id': 1,
        'daily_goal_minutes': stats.dailyGoalMinutes,
        'current_streak': stats.currentStreak,
        'longest_streak': stats.longestStreak,
        'streak_freeze_available': stats.streakFreezeAvailable ? 1 : 0,
        'last_active_date': stats.lastActiveDate?.toIso8601String(),
        'minutes_studied_today': stats.minutesStudiedToday,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Streak hisoblash mantig'i (TZ funksiya 1):
  /// - Agar oxirgi faollik bugun bo'lsa: faqat daqiqa qo'shiladi, streak o'zgarmaydi.
  /// - Agar oxirgi faollik kecha bo'lsa: streak +1, kunlik daqiqa hisoblagichi 0'dan boshlanadi.
  /// - Agar oxirgi faollik 2+ kun oldin bo'lsa va streak freeze mavjud bo'lsa:
  ///   freeze ishlatiladi (streak saqlanadi, freeze sarflanadi), aks holda streak 1'ga tushadi.
  @override
  Future<UserStats> recordActivity({required int minutesStudied}) async {
    final current = await getStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (current.lastActiveDate == null) {
      final updated = current.copyWith(
        currentStreak: 1,
        longestStreak: current.longestStreak < 1 ? 1 : current.longestStreak,
        lastActiveDate: today,
        minutesStudiedToday: minutesStudied,
      );
      await saveStats(updated);
      return updated;
    }

    final lastActive = DateTime(
      current.lastActiveDate!.year,
      current.lastActiveDate!.month,
      current.lastActiveDate!.day,
    );
    final daysSinceLastActive = today.difference(lastActive).inDays;

    UserStats updated;
    if (daysSinceLastActive == 0) {
      // Bugun allaqachon faol bo'lgan — daqiqani qo'shamiz
      updated = current.copyWith(minutesStudiedToday: current.minutesStudiedToday + minutesStudied);
    } else if (daysSinceLastActive == 1) {
      // Ketma-ket kun — streak davom etadi
      final newStreak = current.currentStreak + 1;
      updated = current.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
        lastActiveDate: today,
        minutesStudiedToday: minutesStudied,
      );
    } else if (daysSinceLastActive == 2 && current.streakFreezeAvailable) {
      // Bir kun o'tkazib yuborilgan, lekin streak freeze bor — streak saqlanadi
      final newStreak = current.currentStreak + 1;
      updated = current.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
        streakFreezeAvailable: false,
        lastActiveDate: today,
        minutesStudiedToday: minutesStudied,
      );
    } else {
      // Streak uzilgan — qaytadan 1'dan boshlanadi
      updated = current.copyWith(
        currentStreak: 1,
        lastActiveDate: today,
        minutesStudiedToday: minutesStudied,
      );
    }

    await saveStats(updated);
    return updated;
  }
}
