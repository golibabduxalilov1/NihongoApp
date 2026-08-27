import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/checkpoint.dart';
import '../../../domain/entities/practice_item.dart';
import '../../../domain/usecases/evaluate_checkpoint_usecase.dart';
import '../../providers/repository_providers.dart';
import '../../providers/lesson_providers.dart';
import '../../../core/constants/app_colors.dart';

/// Har N darsdan keyin chiqadigan bloklovchi checkpoint imtihoni.
/// O'tilmasa, keyingi bo'lim darslari qulflangan holda qoladi
/// (LessonRepositoryImpl.isLessonUnlocked orqali ta'minlanadi).
class CheckpointScreen extends ConsumerStatefulWidget {
  final Checkpoint checkpoint;
  const CheckpointScreen({super.key, required this.checkpoint});

  @override
  ConsumerState<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends ConsumerState<CheckpointScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  CheckpointSubmissionResult? _result;
  List<QuizQuestion>? _questions;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = ref.read(checkpointRepositoryProvider);
    final questions = await repo.getCheckpointQuestions(widget.checkpoint.id);
    setState(() => _questions = questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkpoint imtihon'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: _result == null,
      ),
      body: _questions == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final questions = _questions!;

    if (_result != null) {
      return _buildResultView(_result!);
    }

    if (_currentIndex >= questions.length) {
      return _buildSubmitView(questions);
    }

    return _buildQuestionView(questions[_currentIndex], questions.length);
  }

  Widget _buildQuestionView(QuizQuestion q, int total) {
    final selected = _answers[q.id];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${widget.checkpoint.fromLesson}-${widget.checkpoint.toLesson}-darslar bo'yicha aralash test",
              style: const TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / total,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          Text('Savol ${_currentIndex + 1} / $total'),
          const SizedBox(height: 20),
          Text(q.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, i) {
                return RadioListTile<int>(
                  value: i,
                  groupValue: selected,
                  title: Text(q.options[i]),
                  onChanged: (value) => setState(() => _answers[q.id] = value!),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selected == null
                ? null
                : () => setState(() => _currentIndex++),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              _currentIndex == total - 1 ? 'Yakunlash' : 'Keyingi savol',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitView(List<QuizQuestion> questions) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Barcha savollarga javob berdingiz.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _submit(questions),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Natijani ko\'rish', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(CheckpointSubmissionResult result) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.passed ? Icons.workspace_premium : Icons.lock_clock,
              color: result.passed ? AppColors.success : AppColors.warning,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text('${result.score}%',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${result.correctCount} / ${result.totalCount} to\'g\'ri'),
            const SizedBox(height: 8),
            Text(
              result.passed
                  ? "Checkpoint muvaffaqiyatli o'tildi! Keyingi darslar ochildi."
                  : "O'tish balli ${widget.checkpoint.passScore}%. Keyingi darslar hali qulflangan, qayta urinib ko'ring.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: result.passed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (result.passed) {
                  ref.invalidate(lessonsListProvider);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  setState(() {
                    _currentIndex = 0;
                    _answers.clear();
                    _result = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  result.passed ? 'Darslar ro\'yxatiga qaytish' : 'Qayta urinish',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(List<QuizQuestion> questions) async {
    final correctAnswers = {
      for (final q in questions) q.id: q.correctOptionIndex,
    };

    final useCase = ref.read(evaluateCheckpointUseCaseProvider);
    final result = await useCase.call(
      checkpoint: widget.checkpoint,
      answers: _answers,
      correctAnswers: correctAnswers,
    );

    setState(() => _result = result);
  }
}
