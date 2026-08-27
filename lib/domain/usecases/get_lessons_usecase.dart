import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsUseCase {
  final LessonRepository repository;
  GetLessonsUseCase(this.repository);

  Future<List<Lesson>> call({int? book}) {
    return repository.getAllLessons(book: book);
  }
}
