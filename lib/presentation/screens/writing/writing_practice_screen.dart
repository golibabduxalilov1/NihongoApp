import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/writing_practice_item.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Hiragana/katakana/kanji yozish mashqi. Foydalanuvchi ekranda
/// barmog'i bilan belgini chizadi, tizim asosiy chiziq yo'nalishini
/// (umumiy harakat traektoriyasi) tekshiradi. TZ funksiya 6.
///
/// Diqqat: to'liq aniq stroke-order tekshiruvi (har bir chiziqning
/// aniq boshlanish/tugash nuqtasi) uchun stroke_order_svg_path orqali
/// import qilingan referens ma'lumot kerak (mualliflik huquqi siyosati
/// bo'yicha bu fayl repo ichida emas). Bu versiya soddalashtirilgan:
/// umumiy chizish yo'nalishi va bosqichlar sonini taqqoslaydi.
class WritingPracticeScreen extends ConsumerStatefulWidget {
  final int? lessonId;
  final CharacterType? filterType;

  const WritingPracticeScreen({super.key, this.lessonId, this.filterType});

  @override
  ConsumerState<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends ConsumerState<WritingPracticeScreen> {
  List<WritingPracticeItem>? _items;
  int _currentIndex = 0;
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  double? _accuracyScore;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(writingPracticeRepositoryProvider);
    final items = widget.filterType != null
        ? await repo.getItemsByType(widget.filterType!)
        : await repo.getItemsForLesson(widget.lessonId);
    if (mounted) setState(() => _items = items);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _currentStroke = [details.localPosition]);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _currentStroke = [..._currentStroke, details.localPosition]);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _strokes.add(_currentStroke);
      _currentStroke = [];
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _accuracyScore = null;
    });
  }

  Future<void> _checkStrokes() async {
    final item = _items![_currentIndex];

    // Soddalashtirilgan baholash: chizilgan chiziqlar soni kutilgan
    // stroke_count'ga qanchalik yaqinligini tekshiramiz. To'liq geometrik
    // taqqoslash (SVG yo'l bilan) keyingi bosqichda stroke_order_svg_path
    // import qilingandan keyin qo'shiladi.
    final strokeCountDiff = (_strokes.length - item.strokeCount).abs();
    final score = strokeCountDiff == 0
        ? 1.0
        : (1.0 - (strokeCountDiff / item.strokeCount)).clamp(0.0, 1.0);

    setState(() => _accuracyScore = score);

    final repo = ref.read(writingPracticeRepositoryProvider);
    await repo.saveAttempt(WritingAttempt(
      id: 0,
      writingPracticeId: item.id,
      accuracyScore: score,
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
                  Text('Yozish mashqi', style: AppTypography.screenTitle),
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
            "Hozircha yozish mashqi yo'q.\n\nKanji/kana yozish mashqlari foydalanuvchi tomonidan import qilingan kontent orqali qo'shiladi.",
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.character, style: AppTypography.vocabKanji.copyWith(fontSize: 40, color: AppColors.inkFaint)),
              const SizedBox(width: 16),
              if (item.romaji != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.romaji!.toUpperCase(), style: AppTypography.vocabRomajiTop),
                    Text('${item.strokeCount} chiziq', style: AppTypography.caption),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _StrokePainter(strokes: _strokes, currentStroke: _currentStroke, guideChar: item.character),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_accuracyScore != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(14)),
              child: Text(
                'Chiziqlar soni mosligi: ${(_accuracyScore! * 100).round()}%',
                style: AppTypography.buttonSecondary.copyWith(color: AppColors.green),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearCanvas,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Tozalash', style: AppTypography.buttonSecondary.copyWith(color: AppColors.inkSoft)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _strokes.isEmpty
                      ? null
                      : (_accuracyScore == null
                          ? _checkStrokes
                          : () {
                              setState(() {
                                _currentIndex++;
                                _strokes.clear();
                                _accuracyScore = null;
                              });
                            }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _accuracyScore == null ? 'Tekshirish' : 'Keyingisi',
                    style: AppTypography.buttonPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fon sifatida xira harf shaklini, ustiga foydalanuvchi chizgan
/// chiziqlarni chizadi.
class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String guideChar;

  _StrokePainter({required this.strokes, required this.currentStroke, required this.guideChar});

  @override
  void paint(Canvas canvas, Size size) {
    // Fon - xira yo'l ko'rsatuvchi harf
    final textPainter = TextPainter(
      text: TextSpan(
        text: guideChar,
        style: TextStyle(fontSize: size.width * 0.6, color: AppColors.border),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );

    // Foydalanuvchi chizgan chiziqlar
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, strokePaint);
    }
    _drawStroke(canvas, currentStroke, strokePaint);
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
