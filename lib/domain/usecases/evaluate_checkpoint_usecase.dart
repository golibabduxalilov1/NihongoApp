import '../entities/checkpoint.dart';
import '../repositories/checkpoint_repository.dart';

class CheckpointSubmissionResult {
  final int score;
  final bool passed;
  final int correctCount;
  final int totalCount;

  const CheckpointSubmissionResult({
    required this.score,
    required this.passed,
    required this.correctCount,
    required this.totalCount,
  });
}

/// Checkpoint (davriy, bir necha darsni birlashtiruvchi) imtihonni baholaydi.
/// TZ bo'lim 7: o'tish balli sozlanadigan (standart 70%), o'tmasa
/// keyingi bo'lim darslari bloklangan holda qoladi.
class EvaluateCheckpointUseCase {
  final CheckpointRepository repository;
  EvaluateCheckpointUseCase(this.repository);

  Future<CheckpointSubmissionResult> call({
    required Checkpoint checkpoint,
    required Map<int, int> answers,
    required Map<int, int> correctAnswers,
  }) async {
    int correctCount = 0;
    for (final entry in answers.entries) {
      if (correctAnswers[entry.key] == entry.value) {
        correctCount++;
      }
    }

    final total = correctAnswers.length;
    final score = total == 0 ? 0 : ((correctCount / total) * 100).round();
    final passed = score >= checkpoint.passScore;

    await repository.saveResult(
      CheckpointResult(
        id: 0, // autoincrement, DB tomonidan beriladi
        checkpointId: checkpoint.id,
        score: score,
        passed: passed,
        attemptedAt: DateTime.now(),
      ),
    );

    return CheckpointSubmissionResult(
      score: score,
      passed: passed,
      correctCount: correctCount,
      totalCount: total,
    );
  }
}
