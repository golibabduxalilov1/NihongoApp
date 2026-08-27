import '../entities/user_stats.dart';
import '../repositories/user_stats_repository.dart';

/// Foydalanuvchi biror mashq/dars bilan shug'ullanganda chaqiriladi
/// (masalan flashcard yoki quiz tugagach). Streak va kunlik daqiqa
/// hisoblagichini yangilaydi.
class RecordStudyActivityUseCase {
  final UserStatsRepository repository;
  RecordStudyActivityUseCase(this.repository);

  Future<UserStats> call({required int minutesStudied}) {
    return repository.recordActivity(minutesStudied: minutesStudied);
  }
}
