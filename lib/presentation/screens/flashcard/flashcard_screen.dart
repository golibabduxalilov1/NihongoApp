import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/vocabulary.dart';
import '../../../domain/entities/srs_state.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';

/// Ikki rejimda ishlaydi:
/// - isIntroMode = true (1-bosqich): so'zlarni faqat ko'rsatadi, baholamaydi
/// - isIntroMode = false (2-bosqich): SRS flashcard, foydalanuvchi baholaydi
class FlashcardScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final int stage;
  final bool isIntroMode;

  const FlashcardScreen({
    super.key,
    required this.lessonId,
    required this.stage,
    required this.isIntroMode,
  });

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabularyForLessonProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isIntroMode
            ? "Yangi so'zlar"
            : "Lug'atni mashq qilish"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: vocabAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (vocabList) {
          if (vocabList.isEmpty) {
            return const Center(child: Text("Bu darsda lug'at topilmadi"));
          }
          if (_currentIndex >= vocabList.length) {
            return _buildCompletionView(context, vocabList.length);
          }
          return _buildCard(context, vocabList[_currentIndex], vocabList.length);
        },
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, int total) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text('$total ta so\'z ko\'rib chiqildi!',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _completeStage(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Davom etish', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, VocabularyItem item, int total) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / total,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text('${_currentIndex + 1} / $total'),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.displayText,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (item.kanji != null) ...[
                          const SizedBox(height: 8),
                          Text(item.kana,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade600)),
                        ],
                        if (widget.isIntroMode || _showAnswer) ...[
                          const Divider(height: 40),
                          Text(
                            item.translationUz,
                            style: const TextStyle(
                                fontSize: 22, color: AppColors.secondary),
                          ),
                          if (item.exampleSentence != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              item.exampleSentence!,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              "(tarjimani ko'rish uchun bosing)",
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.isIntroMode)
            ElevatedButton(
              onPressed: () => _nextCard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Keyingisi', style: TextStyle(color: Colors.white)),
            )
          else if (_showAnswer)
            _buildRecallButtons(item)
          else
            OutlinedButton(
              onPressed: () => setState(() => _showAnswer = true),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text("Javobni ko'rsatish"),
            ),
        ],
      ),
    );
  }

  Widget _buildRecallButtons(VocabularyItem item) {
    return Row(
      children: [
        Expanded(
          child: _recallButton(
            "Bilmadim",
            AppColors.error,
            () => _submitRecall(item, RecallQuality.again),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _recallButton(
            "Qiynaldim",
            AppColors.warning,
            () => _submitRecall(item, RecallQuality.hard),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _recallButton(
            "Bildim",
            AppColors.success,
            () => _submitRecall(item, RecallQuality.good),
          ),
        ),
      ],
    );
  }

  Widget _recallButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Future<void> _submitRecall(VocabularyItem item, RecallQuality quality) async {
    // SRS algoritmi shu yerda haqiqatan ishlaydi: use case orqali
    // yangi ease factor va keyingi takrorlash sanasi hisoblanadi va saqlanadi.
    final useCase = ref.read(reviewFlashcardUseCaseProvider);
    await useCase.call(item.id, quality);
    _nextCard();
  }

  void _nextCard() {
    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }

  Future<void> _completeStage(BuildContext context) async {
    final advanceUseCase = ref.read(advanceLessonStageUseCaseProvider);
    await advanceUseCase.call(widget.lessonId, widget.stage);
    ref.invalidate(lessonByIdProvider(widget.lessonId));
    if (context.mounted) Navigator.pop(context);
  }
}
