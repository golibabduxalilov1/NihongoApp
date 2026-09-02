import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/practice_item.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';

/// Bitta PracticeItem uchun mos widget'ni turi bo'yicha tanlaydi.
/// Public qilingan, chunki TargetedPracticeScreen ham shu widget'larni
/// qayta ishlatadi (kod takrorlanishining oldini olish uchun).
Widget buildPracticeItemWidget(PracticeItem item, void Function(bool wasCorrect) onAnswered) {
  return switch (item.type) {
    PracticeType.multipleChoice => _MultipleChoiceWidget(item: item, onAnswered: onAnswered),
    PracticeType.fillBlank => _FillBlankWidget(item: item, onAnswered: onAnswered),
    PracticeType.rearrange => _RearrangeWidget(item: item, onAnswered: onAnswered),
    PracticeType.openEnded => _OpenEndedWidget(item: item, onAnswered: onAnswered),
    PracticeType.flashcard => const Text('Bu turdagi mashq bu yerda qo\'llab-quvvatlanmaydi'),
  };
}

class PracticeScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final int stage;
  final String stageName;

  const PracticeScreen({
    super.key,
    required this.lessonId,
    required this.stage,
    required this.stageName,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _currentIndex = 0;
  final Map<int, bool> _answeredCorrectly = {};

  @override
  Widget build(BuildContext context) {
    final params = PracticeParams(widget.lessonId, widget.stage);
    final itemsAsync = ref.watch(practiceItemsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stageName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (items) {
          if (items.isEmpty) {
            // Bu bosqichda mashq bo'lmasa, avtomatik o'tkazib yuboramiz
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _completeStage(context);
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentIndex >= items.length) {
            return _buildSummary(context, items.length);
          }

          return _buildPracticeItem(items[_currentIndex], items.length);
        },
      ),
    );
  }

  Widget _buildSummary(BuildContext context, int total) {
    final correctCount = _answeredCorrectly.values.where((v) => v).length;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: AppColors.warning, size: 64),
          const SizedBox(height: 16),
          Text('Mashq tugadi: $correctCount / $total to\'g\'ri',
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

  Widget _buildPracticeItem(PracticeItem item, int total) {
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
            child: buildPracticeItemWidget(item, _handleAnswered),
          ),
        ],
      ),
    );
  }

  void _handleAnswered(bool wasCorrect) {
    setState(() {
      _answeredCorrectly[_currentIndex] = wasCorrect;
      _currentIndex++;
    });
  }

  Future<void> _completeStage(BuildContext context) async {
    final advanceUseCase = ref.read(advanceLessonStageUseCaseProvider);
    await advanceUseCase.call(widget.lessonId, widget.stage);
    ref.invalidate(lessonByIdProvider(widget.lessonId));
    if (context.mounted) Navigator.pop(context);
  }
}

// ---------------------------------------------------------------------
// A-daraja: Ko'p tanlovli savol
// ---------------------------------------------------------------------
class _MultipleChoiceWidget extends StatefulWidget {
  final PracticeItem item;
  final void Function(bool) onAnswered;
  const _MultipleChoiceWidget({required this.item, required this.onAnswered});

  @override
  State<_MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<_MultipleChoiceWidget> {
  String? _selected;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.item.content['question'] as String;
    final options = (widget.item.content['options'] as List).cast<String>();
    final isWrong = _submitted && _selected != widget.item.correctAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        RadioGroup<String>(
          groupValue: _selected,
          onChanged: (value) => setState(() => _selected = value),
          child: Column(
            children: options.map((opt) {
              final isCorrect = opt == widget.item.correctAnswer;
              Color? bgColor;
              if (_submitted && _selected == opt) {
                bgColor = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
              } else if (_submitted && isCorrect) {
                bgColor = Colors.green.shade100;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  value: opt,
                  title: Text(opt),
                  tileColor: bgColor,
                  enabled: !_submitted,
                ),
              );
            }).toList(),
          ),
        ),
        // Mikro-feedback: xato bo'lsa, nega xato ekanini tushuntiramiz
        // (TZ funksiya 2, mistake_explanation maydoni orqali).
        if (isWrong && _selected != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.explanationFor(_selected!),
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (!_submitted)
          ElevatedButton(
            onPressed: _selected == null ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tekshirish', style: TextStyle(color: Colors.white)),
          )
        else
          ElevatedButton(
            onPressed: () =>
                widget.onAnswered(_selected == widget.item.correctAnswer),
            child: const Text('Keyingisi'),
          ),
      ],
    );
  }

  void _submit() => setState(() => _submitted = true);
}

// ---------------------------------------------------------------------
// A-daraja: Bo'sh joyni to'ldirish
// ---------------------------------------------------------------------
class _FillBlankWidget extends StatefulWidget {
  final PracticeItem item;
  final void Function(bool) onAnswered;
  const _FillBlankWidget({required this.item, required this.onAnswered});

  @override
  State<_FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<_FillBlankWidget> {
  final _controller = TextEditingController();
  bool? _isCorrect;

  @override
  Widget build(BuildContext context) {
    final sentence = widget.item.content['sentence'] as String;
    final hint = widget.item.content['hint'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sentence, style: const TextStyle(fontSize: 20)),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text('Maslahat: $hint',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          enabled: _isCorrect == null,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Javobingiz',
            filled: _isCorrect != null,
            fillColor: _isCorrect == true
                ? Colors.green.shade50
                : (_isCorrect == false ? Colors.red.shade50 : null),
          ),
        ),
        const SizedBox(height: 12),
        if (_isCorrect == null)
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tekshirish', style: TextStyle(color: Colors.white)),
          )
        else ...[
          if (!_isCorrect!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text("To'g'ri javob: ${widget.item.correctAnswer}",
                  style: const TextStyle(color: AppColors.error)),
            ),
          ElevatedButton(
            onPressed: () => widget.onAnswered(_isCorrect!),
            child: const Text('Keyingisi'),
          ),
        ],
      ],
    );
  }

  void _submit() {
    final correct = _controller.text.trim() == widget.item.correctAnswer?.trim();
    setState(() => _isCorrect = correct);
  }
}

// ---------------------------------------------------------------------
// B-daraja: So'zlarni tartibga solish
// ---------------------------------------------------------------------
class _RearrangeWidget extends StatefulWidget {
  final PracticeItem item;
  final void Function(bool) onAnswered;
  const _RearrangeWidget({required this.item, required this.onAnswered});

  @override
  State<_RearrangeWidget> createState() => _RearrangeWidgetState();
}

class _RearrangeWidgetState extends State<_RearrangeWidget> {
  late List<String> _availableWords;
  final List<String> _selectedWords = [];
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _availableWords = (widget.item.content['words'] as List).cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.item.content['instruction'] as String? ??
        "So'zlarni to'g'ri tartibga tering";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(instruction, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(minHeight: 60),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords
                .map((w) => ActionChip(
                      label: Text(w),
                      onPressed: _isCorrect == null
                          ? () => setState(() {
                                _selectedWords.remove(w);
                                _availableWords.add(w);
                              })
                          : null,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableWords
              .map((w) => ActionChip(
                    label: Text(w),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    onPressed: _isCorrect == null
                        ? () => setState(() {
                              _availableWords.remove(w);
                              _selectedWords.add(w);
                            })
                        : null,
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        if (_isCorrect == null)
          ElevatedButton(
            onPressed: _availableWords.isEmpty ? _submit : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Tekshirish', style: TextStyle(color: Colors.white)),
          )
        else ...[
          if (!_isCorrect!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text("To'g'ri javob: ${widget.item.correctAnswer}",
                  style: const TextStyle(color: AppColors.error)),
            ),
          ElevatedButton(
            onPressed: () => widget.onAnswered(_isCorrect!),
            child: const Text('Keyingisi'),
          ),
        ],
      ],
    );
  }

  void _submit() {
    final result = _selectedWords.join(' ');
    setState(() => _isCorrect = result == widget.item.correctAnswer);
  }
}

// ---------------------------------------------------------------------
// C-daraja: Erkin ishlatish (o'z-o'zini baholash)
// ---------------------------------------------------------------------
class _OpenEndedWidget extends StatefulWidget {
  final PracticeItem item;
  final void Function(bool) onAnswered;
  const _OpenEndedWidget({required this.item, required this.onAnswered});

  @override
  State<_OpenEndedWidget> createState() => _OpenEndedWidgetState();
}

class _OpenEndedWidgetState extends State<_OpenEndedWidget> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final prompt = widget.item.content['prompt'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(prompt, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLines: 4,
          enabled: !_submitted,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "O'z javobingizni shu yerga yozing...",
          ),
        ),
        const SizedBox(height: 12),
        // Ochiq savollarda avtomatik "to'g'ri/noto'g'ri" tekshirilmaydi —
        // maqsad erkin ishlatish, shuning uchun foydalanuvchi o'zi baholaydi.
        if (!_submitted)
          ElevatedButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => setState(() => _submitted = true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Yuborish', style: TextStyle(color: Colors.white)),
          )
        else
          ElevatedButton(
            onPressed: () => widget.onAnswered(true),
            child: const Text('Keyingisi'),
          ),
      ],
    );
  }
}
