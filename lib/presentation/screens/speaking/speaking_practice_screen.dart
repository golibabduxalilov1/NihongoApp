import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/speaking_item.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/phonetic_matcher.dart';

/// Shadowing mashqi: foydalanuvchi namunani ko'radi/eshitadi, o'zi ovoz
/// chiqarib takrorlaydi, so'ng o'z fikricha qanday aytganini matn
/// ko'rinishida kiritadi va tizim taxminiy fonetik moslikni ko'rsatadi.
///
/// ESLATMA: bu vaqtinchalik, mikrofonsiz versiya. To'liq versiyada
/// (speech_to_text paketi orqali) matn avtomatik tanilishi kerak edi,
/// lekin bu paket hozirgi CI build muhitida Gradle konfiguratsiya
/// muammosi berayotgani sababli vaqtincha o'chirilgan. Foydalanuvchi
/// o'zi eshitgan/aytgan so'zini qo'lda kiritadi, taqqoslash logikasi
/// (PhoneticMatcher) esa o'zgarishsiz ishlayveradi — faqat kirish usuli
/// mikrofondan klaviaturaga almashtirilgan. Keyingi bosqichda
/// speech_to_text qayta faollashtirilganda faqat shu ekranning kirish
/// qismini o'zgartirish kifoya, qolgan mantiq (baholash, saqlash)
/// bir xil qoladi.
class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final bool kaiwaOnly;

  const SpeakingPracticeScreen({super.key, required this.lessonId, this.kaiwaOnly = false});

  @override
  ConsumerState<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends ConsumerState<SpeakingPracticeScreen> {
  final TextEditingController _controller = TextEditingController();
  double? _score;
  int _currentIndex = 0;
  List<SpeakingItem>? _items;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final repo = ref.read(speakingRepositoryProvider);
    final items = widget.kaiwaOnly
        ? await repo.getKaiwaItemsForLesson(widget.lessonId)
        : await repo.getSpeakingItemsForLesson(widget.lessonId);
    if (mounted) setState(() => _items = items);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAnswer() async {
    final item = _items?[_currentIndex];
    if (item == null || _controller.text.trim().isEmpty) return;

    final score = PhoneticMatcher.similarity(item.promptRomaji ?? item.promptText, _controller.text);
    setState(() => _score = score);

    final repo = ref.read(speakingRepositoryProvider);
    await repo.saveAttempt(SpeakingAttempt(
      id: 0,
      speakingItemId: item.id,
      recognizedText: _controller.text,
      similarityScore: score,
      attemptedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(widget.kaiwaOnly ? "Dialog (kaiwa) mashqi" : "Talaffuz mashqi", style: AppTypography.screenTitle),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "Bu dars uchun hozircha gapirish mashqi yo'q.\n\nGapirish mashqlari foydalanuvchi tomonidan import qilingan kontent orqali qo'shiladi.",
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_currentIndex >= _items!.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.gold, size: 56),
            const SizedBox(height: 16),
            Text('Mashq tugadi!', style: AppTypography.sectionTitle),
          ],
        ),
      );
    }

    final item = _items![_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Text('${_currentIndex + 1} / ${_items!.length}', style: AppTypography.caption),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (item.isKaiwa)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(8)),
                    child: Text('会話 KAIWA', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800)),
                  ),
                Text(item.promptText, style: AppTypography.vocabKanji.copyWith(fontSize: 28), textAlign: TextAlign.center),
                if (item.promptRomaji != null) ...[
                  const SizedBox(height: 8),
                  Text(item.promptRomaji!, style: AppTypography.vocabKana),
                ],
                const SizedBox(height: 12),
                Text(item.promptTranslationUz, style: AppTypography.vocabTranslation.copyWith(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Yuqoridagi gapni ovoz chiqarib o'qing, so'ng qanday aytganingizni (romaji bilan) shu yerga yozing:",
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            enabled: _score == null,
            decoration: InputDecoration(
              hintText: 'masalan: hajimemashite',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          if (_score != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(14)),
              child: Text(
                '${PhoneticMatcher.qualitativeLabel(_score!)} (${(_score! * 100).round()}%)',
                style: AppTypography.buttonSecondary.copyWith(color: AppColors.green),
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _score == null
                  ? _checkAnswer
                  : () {
                      setState(() {
                        _currentIndex++;
                        _controller.clear();
                        _score = null;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_score == null ? 'Tekshirish' : 'Keyingisi', style: AppTypography.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
