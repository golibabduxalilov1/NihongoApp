import '../entities/practice_item.dart';
import '../entities/mistake_log_entry.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/mistake_repository.dart';

/// Foydalanuvchi "Practice Hub"da bitta zaif mavzuni (masalan "は
/// zarrachasi") tanlaganda, o'sha mavzuga tegishli barcha mashqlarni
/// (turli darslardan) yig'ib, bitta maqsadli mashq to'plami hosil qiladi.
///
/// Bu GetWeakPointsUseCase bilan birga ishlaydi: avval zaif mavzu
/// aniqlanadi, keyin shu use case orqali o'sha mavzu bo'yicha mashqlar
/// generatsiya qilinadi.
class GenerateTargetedPracticeUseCase {
  final LessonRepository lessonRepository;
  final MistakeRepository mistakeRepository;

  GenerateTargetedPracticeUseCase(this.lessonRepository, this.mistakeRepository);

  /// [topicTag] — masalan "particle_wa". Barcha darslardagi shu tag'ga
  /// mos practice_item'larni topib, foydalanuvchi eng ko'p xato qilgan
  /// tartibda emas, tasodifiy aralashtirilgan holda qaytaradi (takrorlash
  /// samaradorligi uchun).
  Future<List<PracticeItem>> call(String topicTag, {int maxItems = 10}) async {
    await mistakeRepository.getMistakesForLesson(0); // barcha darslar bo'yicha filtrlanadi pastda
    final relevantLessonIds = <int>{};

    // Xato jurnalidan shu mavzuga tegishli darslarni topamiz
    final allMistakesForTopic = await _getAllMistakesForTopic(topicTag);
    for (final m in allMistakesForTopic) {
      relevantLessonIds.add(m.lessonId);
    }

    final items = <PracticeItem>[];
    for (final lessonId in relevantLessonIds) {
      final lessonItems = await lessonRepository.getPracticeItemsForLesson(lessonId, 4);
      items.addAll(lessonItems.where((item) => item.topicTag == topicTag));

      final lessonItemsStage5 = await lessonRepository.getPracticeItemsForLesson(lessonId, 5);
      items.addAll(lessonItemsStage5.where((item) => item.topicTag == topicTag));
    }

    items.shuffle();
    return items.take(maxItems).toList();
  }

  Future<List<MistakeLogEntry>> _getAllMistakesForTopic(String topicTag) async {
    // Hozirgi MistakeRepository interfeysi faqat lessonId bo'yicha
    // filtrlaydi; shuning uchun getWeakPoints orqali topic->lesson
    // xaritasini olamiz.
    final weakPoints = await mistakeRepository.getWeakPoints(limit: 100);
    final matching = weakPoints.where((wp) => wp.topicTag == topicTag);
    final result = <MistakeLogEntry>[];
    for (final wp in matching) {
      result.addAll(await mistakeRepository.getMistakesForLesson(wp.lessonId));
    }
    return result;
  }
}
