import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/grammar_point.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';

class GrammarScreen extends ConsumerWidget {
  final int lessonId;
  const GrammarScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(grammarForLessonProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammatika'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Xatolik: $err')),
        data: (grammarPoints) {
          if (grammarPoints.isEmpty) {
            return const Center(child: Text('Grammatika topilmadi'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grammarPoints.length + 1,
            itemBuilder: (context, index) {
              if (index == grammarPoints.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () => _completeStage(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Tushundim, davom etish',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              }
              return _GrammarCard(point: grammarPoints[index]);
            },
          );
        },
      ),
    );
  }

  Future<void> _completeStage(BuildContext context, WidgetRef ref) async {
    final advanceUseCase = ref.read(advanceLessonStageUseCaseProvider);
    await advanceUseCase.call(lessonId, 3); // 3 = grammarExplain stage
    ref.invalidate(lessonByIdProvider(lessonId));
    if (context.mounted) Navigator.pop(context);
  }
}

class _GrammarCard extends StatelessWidget {
  final GrammarPoint point;
  const _GrammarCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              point.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              point.explanation,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            if (point.examples.isNotEmpty) ...[
              const Divider(height: 28),
              const Text(
                'Misollar:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...point.examples.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.jp,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.grammarVerb,
                          ),
                        ),
                        Text(
                          ex.translation,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
