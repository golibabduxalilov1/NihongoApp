import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../domain/entities/speaking_item.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/phonetic_matcher.dart';

/// Shadowing mashqi: foydalanuvchi namunani eshitadi (yoki matnni o'qiydi),
/// o'zi takrorlaydi, tizim mikrofon orqali tinglab, taxminiy fonetik
/// moslikni ko'rsatadi. TZ funksiya 4.
///
/// Diqqat: speech_to_text qurilmaning o'z nutqni tanish tizimidan
/// foydalanadi (Android/iOS built-in) — bu internetga serverga ma'lumot
/// yubormaydi deb kafolatlanmaydi (OS darajasida bo'lishi mumkin), lekin
/// ilovaning o'zi hech qanday tashqi API'ga so'rov yubormaydi — barcha
/// taqqoslash (PhoneticMatcher) qurilmada, offline ishlaydi.
class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final bool kaiwaOnly;

  const SpeakingPracticeScreen({super.key, required this.lessonId, this.kaiwaOnly = false});

  @override
  ConsumerState<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends ConsumerState<SpeakingPracticeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedText = '';
  double? _score;
  int _currentIndex = 0;
  List<SpeakingItem>? _items;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadItems();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mikrofon xatosi: ${error.errorMsg}")),
          );
        }
      },
    );
    if (mounted) setState(() {});
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
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mikrofonga ruxsat berilmagan yoki qurilmada nutqni tanish mavjud emas")),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _score = null;
    });

    await _speech.listen(
      localeId: 'ja_JP',
      onResult: (result) {
        setState(() => _recognizedText = result.recognizedWords);
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    final item = _items?[_currentIndex];
    if (item != null && _recognizedText.isNotEmpty) {
      final score = PhoneticMatcher.similarity(item.promptRomaji ?? item.promptText, _recognizedText);
      setState(() => _score = score);

      final saveAttempt = ref.read(speakingRepositoryProvider);
      await saveAttempt.saveAttempt(SpeakingAttempt(
        id: 0,
        speakingItemId: item.id,
        recognizedText: _recognizedText,
        similarityScore: score,
        attemptedAt: DateTime.now(),
      ));
    }
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
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? "Tinglanmoqda... bosing to'xtatish uchun" : "Ushlab gapiring",
            style: AppTypography.bodySmall,
          ),
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Siz aytdingiz: "$_recognizedText"', style: AppTypography.body, textAlign: TextAlign.center),
          ],
          if (_score != null) ...[
            const SizedBox(height: 12),
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
          if (_score != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex++;
                    _recognizedText = '';
                    _score = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Keyingisi', style: AppTypography.buttonPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
