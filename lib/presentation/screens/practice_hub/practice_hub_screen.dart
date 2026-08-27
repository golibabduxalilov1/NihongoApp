import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lesson_providers.dart';
import '../../providers/user_stats_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../flashcard/flashcard_screen.dart';
import '../speaking/speaking_practice_screen.dart';
import '../writing/writing_practice_screen.dart';
import '../listening/listening_practice_screen.dart';
import '../practice/targeted_practice_screen.dart';

/// Barcha erkin mashq turlarini birlashtiruvchi markaz:
/// lug'at takrorlash, gapirish (shadowing), yozish (stroke order),
/// va zaif tomonlar bo'yicha maqsadli mashq.
class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakPointsAsync = ref.watch(weakPointsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Text('Mashq', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text("Qaysi ko'nikmani mashq qilmoqchisiz?", style: AppTypography.bodySmall),
          const SizedBox(height: 20),

          // Zaif tomon bo'yicha tezkor tavsiya
          weakPointsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (weakPoints) {
              if (weakPoints.isEmpty) return const SizedBox.shrink();
              final top = weakPoints.first;
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tavsiya etilgan mashq', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                          Text(top.displayName, style: AppTypography.lessonTitle.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TargetedPracticeScreen(topicTag: top.topicTag, topicName: top.displayName),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
                      child: const Text('Boshlash'),
                    ),
                  ],
                ),
              );
            },
          ),

          Text('Ko\'nikma turlari', style: AppTypography.sectionTitle),
          const SizedBox(height: 12),
          _SkillTile(
            icon: Icons.style_rounded,
            title: "Lug'at takrorlash",
            subtitle: 'Yakunlangan darslar lug\'atini SRS orqali mashq qiling',
            color: AppColors.mint,
            iconColor: AppColors.green,
            onTap: () => _openVocabPractice(context, ref),
          ),
          _SkillTile(
            icon: Icons.mic_rounded,
            title: 'Talaffuz (shadowing)',
            subtitle: 'Eshiting, takrorlang, moslikni ko\'ring',
            color: AppColors.peach,
            iconColor: AppColors.primaryDark,
            onTap: () => _openSpeakingPractice(context, ref),
          ),
          _SkillTile(
            icon: Icons.brush_rounded,
            title: 'Yozish (hiragana/katakana)',
            subtitle: 'Chiziq tartibi bilan yozishni mashq qiling',
            color: AppColors.lavender,
            iconColor: AppColors.secondary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WritingPracticeScreen()));
            },
          ),
          _SkillTile(
            icon: Icons.headphones_rounded,
            title: 'Eshitish',
            subtitle: "So'zni tinglang, tarjimasini tanlang",
            color: AppColors.mint,
            iconColor: AppColors.green,
            onTap: () => _openListeningPractice(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _openListeningPractice(BuildContext context, WidgetRef ref) async {
    final lessons = await ref.read(lessonsListProvider.future);
    if (lessons.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hozircha dars yo'q")),
        );
      }
      return;
    }
    final lessonId = lessons.first.id;
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ListeningPracticeScreen(lessonId: lessonId)));
    }
  }

  Future<void> _openVocabPractice(BuildContext context, WidgetRef ref) async {
    final lessons = await ref.read(lessonsListProvider.future);
    final completed = lessons.where((l) => l.isCompleted).toList();

    if (completed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avval bitta darsni tugating")),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlashcardScreen(lessonId: completed.first.id, stage: 2, isIntroMode: false),
        ),
      );
    }
  }

  Future<void> _openSpeakingPractice(BuildContext context, WidgetRef ref) async {
    final lessons = await ref.read(lessonsListProvider.future);
    final completed = lessons.where((l) => l.isCompleted).toList();
    final lessonId = completed.isNotEmpty ? completed.first.id : (lessons.isNotEmpty ? lessons.first.id : 1);

    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SpeakingPracticeScreen(lessonId: lessonId)));
    }
  }
}

class _SkillTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _SkillTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.lessonTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.lessonSubtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
