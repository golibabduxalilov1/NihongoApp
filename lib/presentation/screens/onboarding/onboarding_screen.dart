import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../shell/main_shell.dart';
import '../placement_test/placement_test_screen.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final Widget illustration;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Yapon tilini nolldan boshlang",
      subtitle:
          "Hiragana, kanji, grammatika — hammasi tarjima va o'qilishi bilan birga, qadam-baqadam.",
      illustration: _BookIllustration(),
    ),
    OnboardingPage(
      title: "Har bir so'z o'qilishi bilan birga",
      subtitle:
          "Yapon harflarini bilmasangiz ham xavotir olmang — har bir so'z va gap lotin harflarida o'qilishi bilan ko'rsatiladi.",
      illustration: _RomajiIllustration(),
    ),
    OnboardingPage(
      title: "Kunlik odat hosil qiling",
      subtitle:
          "Kichik kunlik maqsadlar va streak orqali bosqichma-bosqich, zerikmasdan rivojlaning.",
      illustration: _StreakIllustration(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  /// TZ funksiya 5: agar foydalanuvchi MNN'ni qisman o'rgangan bo'lsa,
  /// joylashtirish testiga yo'naltiramiz. Aks holda to'g'ridan-to'g'ri
  /// 1-darsdan boshlaydi.
  Future<void> _showLevelDialog() async {
    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Minna no Nihongo'ni avval o'rganganmisiz?",
                style: AppTypography.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Qisqa test orqali qaysi darsdan boshlashni aniqlab beramiz",
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Ha, testdan o'tmoqchiman", style: AppTypography.buttonPrimary),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Yo'q, 1-darsdan boshlayman", style: AppTypography.buttonSecondary.copyWith(color: AppColors.inkSoft)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PlacementTestScreen()),
      );
    } else {
      _goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 220, width: 220, child: page.illustration),
                            const SizedBox(height: 40),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: AppTypography.onboardingTitle,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _showLevelDialog();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.35),
                      ),
                      child: Text(
                        isLastPage ? "Boshlash" : "Davom etish",
                        style: AppTypography.buttonPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!isLastPage)
              Positioned(
                top: 4,
                right: 8,
                child: TextButton(
                  onPressed: _goToHome,
                  child: Text(
                    "O'tkazib yuborish",
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 1-sahifa illyustratsiyasi: ochiq kitob + qizil hinomaru doira
/// (asosiy ilova ikonkasi bilan bir xil vizual til).
class _BookIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(140, 140),
          painter: _BookPainter(),
        ),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Doira fon
    canvas.drawCircle(Offset(cx, cy), size.width / 2, Paint()..color = AppColors.peach);

    // Kitob
    final bookRect = Rect.fromCenter(center: Offset(cx, cy), width: 80, height: 60);
    final bookPaint = Paint()..color = Colors.white;
    final bookBorder = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rrect = RRect.fromRectAndRadius(bookRect, const Radius.circular(10));
    canvas.drawRRect(rrect, bookPaint);
    canvas.drawRRect(rrect, bookBorder);

    // O'rta chiziq
    canvas.drawLine(
      Offset(cx, bookRect.top),
      Offset(cx, bookRect.bottom),
      Paint()
        ..color = AppColors.peach.withOpacity(0.8)
        ..strokeWidth = 2,
    );

    // Chap tomon - matn chiziqlari
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 30, cy - 12), Offset(cx - 10, cy - 12), linePaint);
    canvas.drawLine(Offset(cx - 30, cy), Offset(cx - 15, cy), linePaint..color = AppColors.primary.withOpacity(0.6));
    canvas.drawLine(Offset(cx - 30, cy + 12), Offset(cx - 10, cy + 12), linePaint..color = AppColors.primary.withOpacity(0.4));

    // O'ng tomon - hinomaru doira
    canvas.drawCircle(Offset(cx + 20, cy + 5), 16, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2-sahifa illyustratsiyasi: kana ustida romaji - onboardingning eng
/// muhim vizual va'dasi ("o'qilishi doim ko'rinadi").
class _RomajiIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "ARIGATOU",
                style: AppTypography.vocabRomajiTop.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "ありがとう",
              style: AppTypography.vocabKana.copyWith(fontSize: 26, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text("rahmat", style: AppTypography.vocabTranslation.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// 3-sahifa illyustratsiyasi: olov + streak raqami.
class _StreakIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.gold, size: 72),
            const SizedBox(height: 8),
            Text(
              "12 kun",
              style: AppTypography.onboardingTitle.copyWith(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
