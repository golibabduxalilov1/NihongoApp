import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/practice_item.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'practice_screen.dart' show buildPracticeItemWidget;

/// Statistika ekranidagi "Zaif tomon" kartasidan kelinadi. Bitta aniq
/// mavzu (masalan "は zarrachasi") bo'yicha barcha darslardan yig'ilgan
/// mashqlarni ketma-ket ko'rsatadi (TZ funksiya 2: xato tahlilidan
/// to'g'ridan-to'g'ri Practice Hub'ga o'tish).
class TargetedPracticeScreen extends ConsumerStatefulWidget {
  final String topicTag;
  final String topicName;

  const TargetedPracticeScreen({super.key, required this.topicTag, required this.topicName});

  @override
  ConsumerState<TargetedPracticeScreen> createState() => _TargetedPracticeScreenState();
}

class _TargetedPracticeScreenState extends ConsumerState<TargetedPracticeScreen> {
  int _currentIndex = 0;
  List<PracticeItem>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final useCase = ref.read(generateTargetedPracticeUseCaseProvider);
    final items = await useCase.call(widget.topicTag);
    if (mounted) setState(() => _items = items);
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
                  Expanded(child: Text(widget.topicName, style: AppTypography.screenTitle)),
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
            "Bu mavzu bo'yicha hozircha mashq topilmadi.",
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Yopish', style: AppTypography.buttonPrimary),
            ),
          ],
        ),
      );
    }

    final item = _items![_currentIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('${_currentIndex + 1} / ${_items!.length}', style: AppTypography.caption),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: buildPracticeItemWidget(item, (wasCorrect) {
              setState(() => _currentIndex++);
            }),
          ),
        ],
      ),
    );
  }
}
