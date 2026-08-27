import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/placement_test.dart';
import '../../../domain/usecases/placement_test_usecase.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../shell/main_shell.dart';

/// Onboarding oxirida "MNN'ni qisman bilaman" tanlagan foydalanuvchi
/// uchun 10-15 savoldan iborat joylashtirish testi. TZ funksiya 5.
/// Natija asosida qaysi darsdan boshlash tavsiya etiladi va
/// PlacementTestUseCase orqali user_progress oldindan to'ldiriladi.
class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  List<PlacementTestQuestion>? _questions;
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  PlacementTestSubmission? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(placementTestRepositoryProvider);
    final questions = await repo.getQuestions();
    if (mounted) setState(() => _questions = questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Darajangizni aniqlaymiz', style: AppTypography.screenTitle.copyWith(fontSize: 20)),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_questions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hozircha joylashtirish testi savollari yo'q. 1-darsdan boshlaymiz.",
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToHome,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text('Davom etish', style: AppTypography.buttonPrimary),
              ),
            ],
          ),
        ),
      );
    }

    if (_result != null) {
      return _buildResultView(_result!);
    }

    if (_currentIndex >= _questions!.length) {
      return _buildSubmitView();
    }

    return _buildQuestionView(_questions![_currentIndex]);
  }

  Widget _buildQuestionView(PlacementTestQuestion q) {
    final selected = _answers[q.id];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions!.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          Text(q.question, style: AppTypography.sectionTitle.copyWith(fontSize: 19)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, i) {
                final isSelected = selected == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _answers[q.id] = i),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                      ),
                      child: Text(q.options[i], style: AppTypography.body.copyWith(color: AppColors.ink)),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null ? null : () => setState(() => _currentIndex++),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _currentIndex == _questions!.length - 1 ? 'Yakunlash' : 'Keyingi savol',
                style: AppTypography.buttonPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Barcha savollarga javob berdingiz', style: AppTypography.sectionTitle),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitTest,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Natijani ko\'rish', style: AppTypography.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(PlacementTestSubmission result) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
              child: const Icon(Icons.flag_rounded, color: AppColors.green, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Tavsiya etilgan boshlanish nuqtasi:', style: AppTypography.bodySmall),
            const SizedBox(height: 6),
            Text(result.recommendedLessonTitle, style: AppTypography.sectionTitle.copyWith(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Test natijasi: ${result.score}%', style: AppTypography.body),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Boshlash', style: AppTypography.buttonPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTest() async {
    final useCase = ref.read(placementTestUseCaseProvider);
    final result = await useCase.call(_answers);
    setState(() => _result = result);
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }
}
