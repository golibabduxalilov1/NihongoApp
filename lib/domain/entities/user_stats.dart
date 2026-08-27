/// Foydalanuvchining motivatsiya holati: kunlik maqsad, streak, streak freeze.
/// TZ funksiya 1: "Motivatsiya va odat shakllantirish tizimi".
class UserStats {
  final int dailyGoalMinutes;
  final int currentStreak;
  final int longestStreak;
  final bool streakFreezeAvailable;
  final DateTime? lastActiveDate;
  final int minutesStudiedToday;

  const UserStats({
    required this.dailyGoalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezeAvailable,
    this.lastActiveDate,
    required this.minutesStudiedToday,
  });

  factory UserStats.initial() => const UserStats(
        dailyGoalMinutes: 20,
        currentStreak: 0,
        longestStreak: 0,
        streakFreezeAvailable: true,
        lastActiveDate: null,
        minutesStudiedToday: 0,
      );

  double get todayProgress =>
      dailyGoalMinutes == 0 ? 0 : (minutesStudiedToday / dailyGoalMinutes).clamp(0.0, 1.0);

  bool get goalReachedToday => minutesStudiedToday >= dailyGoalMinutes;

  UserStats copyWith({
    int? dailyGoalMinutes,
    int? currentStreak,
    int? longestStreak,
    bool? streakFreezeAvailable,
    DateTime? lastActiveDate,
    int? minutesStudiedToday,
  }) {
    return UserStats(
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezeAvailable: streakFreezeAvailable ?? this.streakFreezeAvailable,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      minutesStudiedToday: minutesStudiedToday ?? this.minutesStudiedToday,
    );
  }
}
