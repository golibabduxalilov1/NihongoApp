import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../domain/entities/vocabulary.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Eshitish (listening) mashqi: so'z flutter_tts orqali ovoz chiqarib
/// o'qiladi, foydalanuvchi tarjimasini 4 variantdan tanlaydi.
///
/// flutter_tts butunlay qurilmada (on-device) ishlaydi — internetga
/// so'rov yubormaydi, offline-first tamoyiliga mos. Android'da alohida
/// sozlash shart emas; iOS'da ham qo'shimcha Info.plist sozlamasi talab
/// qilinmaydi (mikrofon emas, faqat ovoz chiqarish). Agar qurilmada
/// yapon tili ovoz paketi o'rnatilmagan bo'lsa, tizim shunchaki mavjud
/// eng yaqin ovozni ishlatadi yoki xato bermay davom etadi — bu holat
/// pastda SnackBar orqali foydalanuvchiga bildiriladi.
class ListeningPracticeScreen extends ConsumerStatefulWidget {
  final int lessonId;

  const ListeningPracticeScreen({super.key, required this.lessonId});

  @override
  ConsumerState<ListeningPracticeScreen> createState() => _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends ConsumerState<ListeningPracticeScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  List<VocabularyItem>? _items;
  int _currentIndex = 0;
  int _score = 0;
  List<VocabularyItem> _currentOptions = [];
  String? _selectedAnswerId;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadItems();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.4);
      final languages = await _tts.getLanguages;
      final hasJapanese = languages is List && languages.any((l) => l.toString().toLowerCase().contains('ja'));
      setState(() => _ttsReady = true);
      if (!hasJapanese && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Qurilmada yaponcha ovoz topilmadi, mavjud eng yaqin ovoz ishlatiladi"),
              ),
            );
          }
        });
      }
    } catch (_) {
      // TTS ishga tushmasa ham ilova ishlashda davom etadi —
      // foydalanuvchi shunchaki ovozsiz, faqat yozma savol ko'radi.
      setState(() => _ttsReady = false);
    }
  }

  Future<void> _loadItems() async {
    final repo = ref.read(lessonRepositoryProvider);
    final vocab = await repo.getVocabularyForLesson(widget.lessonId);
    if (!mounted) return;
    setState(() {
      _items = vocab;
      if (vocab.isNotEmpty) _prepareOptions();
    });
  }

  /// getSmartDistractors mantig'iga o'xshash: bir xil darsdan tasodifiy
  /// 3 ta chalg'ituvchi tanlanadi, to'g'ri javob bilan aralashtiriladi.
  void _prepareOptions() {
    final current = _items![_currentIndex];
    final pool = _items!.where((w) => w.id != current.id).toList()..shuffle();
    final distractors = pool.take(3).toList();
    _currentOptions = [current, ...distractors]..shuffle(Random());
    _selectedAnswerId = null;
    _answered = false;
  }

  Future<void> _speak() async {
    if (!_ttsReady || _items == null || _currentIndex >= _items!.length) return;
    final word = _items![_currentIndex];
    try {
      await _tts.stop();
      await _tts.speak(word.kanji ?? word.kana);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ovoz ijro etilmadi, qurilma sozlamalarini tekshiring")),
        );
      }
    }
  }

  void _selectAnswer(VocabularyItem option) {
    if (_answered) return;
    final current = _items![_currentIndex];
    final isCorrect = option.id == current.id;

    setState(() {
      _selectedAnswerId = option.kana;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  Future<void> _next() async {
    if (_currentIndex + 1 >= _items!.length) {
      // Mashq tugadi: motivatsiya tizimiga faollik yozamiz (mavjud
      // RecordStudyActivityUseCase orqali, boshqa rejimlar bilan bir xil).
      final recordActivity = ref.read(recordStudyActivityUseCaseProvider);
      await recordActivity.call(minutesStudied: 3);
      ref.invalidate(userStatsProvider);
    }

    setState(() {
      _currentIndex++;
      if (_items != null && _currentIndex < _items!.length) {
        _prepareOptions();
      }
    });
    if (_currentIndex < (_items?.length ?? 0)) {
      await Future.delayed(const Duration(milliseconds: 200));
      _speak();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
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
                  Text('Eshitish mashqi', style: AppTypography.screenTitle),
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
          child: Text("Bu darsda lug'at topilmadi", style: AppTypography.body),
        ),
      );
    }
    if (_currentIndex >= _items!.length) {
      return _buildSummary();
    }

    return _buildQuestion();
  }

  Widget _buildSummary() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: AppColors.gold, size: 56),
          const SizedBox(height: 16),
          Text('$_score / ${_items!.length} to\'g\'ri', style: AppTypography.sectionTitle),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Yopish', style: AppTypography.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final current = _items![_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _items!.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${_currentIndex + 1} / ${_items!.length}', style: AppTypography.caption),
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: _speak,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 44),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _speak,
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Yana tinglash'),
          ),
          const SizedBox(height: 24),
          Text("Eshitgan so'zingizning tarjimasini tanlang:", style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _currentOptions.length,
              itemBuilder: (context, i) {
                final opt = _currentOptions[i];
                final isSelected = _selectedAnswerId == opt.kana;
                final isCorrectOption = opt.id == current.id;

                Color? bg;
                Color? borderColor;
                if (_answered) {
                  if (isCorrectOption) {
                    bg = AppColors.mint;
                    borderColor = AppColors.green;
                  } else if (isSelected) {
                    bg = AppColors.primaryLight;
                    borderColor = AppColors.error;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectAnswer(opt),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg ?? AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor ?? AppColors.border, width: borderColor != null ? 2 : 1),
                      ),
                      child: Text(opt.translationUz, style: AppTypography.body.copyWith(color: AppColors.ink)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
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
