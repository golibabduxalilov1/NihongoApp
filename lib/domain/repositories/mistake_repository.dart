import '../entities/mistake_log_entry.dart';

abstract class MistakeRepository {
  Future<void> logMistake(MistakeLogEntry entry);

  /// Barcha xatolarni topic bo'yicha guruhlab, eng ko'p xato qilingandan
  /// kamigacha tartiblab qaytaradi.
  Future<List<WeakPoint>> getWeakPoints({int limit = 10});

  Future<List<MistakeLogEntry>> getMistakesForLesson(int lessonId);
}
