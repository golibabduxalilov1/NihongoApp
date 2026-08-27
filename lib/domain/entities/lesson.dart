/// Dars bosqichlarini ifodalaydi.
/// Har bir dars 7 ta ketma-ket bosqichdan iborat, ular majburiy tartibda o'tiladi.
enum LessonStage {
  vocabIntro(1, "Lug'atni tanishtirish"),
  vocabDrill(2, "Lug'atni faol mashq qilish"),
  grammarExplain(3, "Grammatikani tushuntirish"),
  controlledPractice(4, "Tuzilmani mustahkamlash"),
  semiControlledPractice(5, "Aralashtirilgan mashq"),
  freeProduction(6, "Erkin ishlatish"),
  integration(7, "Integratsiya");

  final int stageNumber;
  final String title;
  const LessonStage(this.stageNumber, this.title);

  static LessonStage fromNumber(int n) =>
      LessonStage.values.firstWhere((s) => s.stageNumber == n);
}

enum LessonCompletionStatus { notStarted, inProgress, completed }

class Lesson {
  final int id;
  final String title;
  final int orderIndex;
  final int book; // 1 yoki 2 (Minna no Nihongo I / II)
  final LessonCompletionStatus status;
  final int currentStage; // 1..7, foydalanuvchi hozir qaysi bosqichda
  final int? quizScore; // dars oxiridagi quiz natijasi (0-100), null = topshirilmagan

  const Lesson({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.book,
    this.status = LessonCompletionStatus.notStarted,
    this.currentStage = 1,
    this.quizScore,
  });

  Lesson copyWith({
    LessonCompletionStatus? status,
    int? currentStage,
    int? quizScore,
  }) {
    return Lesson(
      id: id,
      title: title,
      orderIndex: orderIndex,
      book: book,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      quizScore: quizScore ?? this.quizScore,
    );
  }

  bool get isCompleted => status == LessonCompletionStatus.completed;
}
