import '../entities/user_stats.dart';

abstract class UserStatsRepository {
  Future<UserStats> getStats();
  Future<void> saveStats(UserStats stats);

  /// Foydalanuvchi bugun faol bo'lganda chaqiriladi: streak hisoblash
  /// mantig'ini (ketma-ketlikni saqlash, uzilganda freeze ishlatish yoki
  /// streak'ni nolga tushirish) shu yerda amalga oshiramiz.
  Future<UserStats> recordActivity({required int minutesStudied});
}
