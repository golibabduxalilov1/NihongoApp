import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/vocabulary.dart';
import '../../../domain/entities/srs_state.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Ikki rejimda ishlaydi:
/// - isIntroMode = true (1-bosqich): so'zlarni faqat ko'rsatadi, baholamaydi
/// - isIntroMode = false (2-bosqich): SRS flashcard, foydalanuvchi baholaydi
///
/// Dizayn qarori: romaji HAR DOIM eng tepada, alohida rangli belgida
/// ko'rsatiladi — foydalanuvchi yapon yozuvini hali bilmasa ham, so'zni
/// qanday o'qishni darhol ko'radi (mockup: ".vocab-romaji-top").
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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isIntroMode ? "Yangi so'zlar" : "Lug'atni mashq qilish",
                    style: AppTypography.screenTitle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: vocabAsync.when(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, int total) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.green, size: 44),
          ),
          const SizedBox(height: 20),
          Text('$total ta so\'z ko\'rib chiqildi!', style: AppTypography.sectionTitle),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () => _completeStage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Davom etish', style: AppTypography.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, VocabularyItem item, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${_currentIndex + 1} / $total', style: AppTypography.caption),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: AppColors.ink.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.romaji != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6E5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              item.romaji!.toUpperCase(),
                              style: AppTypography.vocabRomajiTop,
                            ),
                          ),
                        const SizedBox(height: 18),
                        Text(item.displayText, style: AppTypography.vocabKanji, textAlign: TextAlign.center),
                        if (item.kanji != null) ...[
                          const SizedBox(height: 6),
                          Text(item.kana, style: AppTypography.vocabKana),
                        ],
                        if (widget.isIntroMode || _showAnswer) ...[
                          Container(
                            width: 60,
                            height: 2,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            color: AppColors.border,
                          ),
                          Text(item.translationUz, style: AppTypography.vocabTranslation, textAlign: TextAlign.center),
                          if (item.exampleSentence != null) ...[
                            const SizedBox(height: 16),
                            Text(item.exampleSentence!, style: AppTypography.vocabExample, textAlign: TextAlign.center),
                            if (item.exampleSentenceRomaji != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.exampleSentenceRomaji!,
                                style: AppTypography.vocabExampleRomaji,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              "(tarjimani ko'rish uchun bosing)",
                              style: AppTypography.caption,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nextCard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Keyingisi', style: AppTypography.buttonPrimary),
              ),
            )
          else if (_showAnswer)
            _buildRecallButtons(item)
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showAnswer = true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Javobni ko'rsatish", style: AppTypography.buttonSecondary.copyWith(color: AppColors.inkSoft)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecallButtons(VocabularyItem item) {
    return Row(
      children: [
        Expanded(
          child: _recallButton("Bilmadim", AppColors.error, Colors.white, () => _submitRecall(item, RecallQuality.again)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _recallButton("Qiynaldim", AppColors.gold, Colors.white, () => _submitRecall(item, RecallQuality.hard)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _recallButton("Bildim", AppColors.primaryDark, AppColors.primaryLight, () => _submitRecall(item, RecallQuality.good), filled: true),
        ),
      ],
    );
  }

  Widget _recallButton(String label, Color textColor, Color bg, VoidCallback onTap, {bool filled = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? AppColors.primaryLight : bg.withOpacity(0.12),
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: AppTypography.buttonSecondary.copyWith(color: textColor, fontSize: 12.5)),
    );
  }

  Future<void> _submitRecall(VocabularyItem item, RecallQuality quality) async {
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

    // Motivatsiya tizimi: dars bosqichi tugatilganda faollik yozib boriladi
    // (taxminiy 3 daqiqa har bir flashcard bosqichi uchun).
    final recordActivity = ref.read(recordStudyActivityUseCaseProvider);
    await recordActivity.call(minutesStudied: 3);
    ref.invalidate(userStatsProvider);

    ref.invalidate(lessonByIdProvider(widget.lessonId));
    if (context.mounted) Navigator.pop(context);
  }
}
