class Checkpoint {
  final int id;
  final int fromLesson;
  final int toLesson;
  final int passScore; // foiz, standart 70

  const Checkpoint({
    required this.id,
    required this.fromLesson,
    required this.toLesson,
    this.passScore = 70,
  });
}

class CheckpointResult {
  final int id;
  final int checkpointId;
  final int score;
  final bool passed;
  final DateTime attemptedAt;

  const CheckpointResult({
    required this.id,
    required this.checkpointId,
    required this.score,
    required this.passed,
    required this.attemptedAt,
  });
}
