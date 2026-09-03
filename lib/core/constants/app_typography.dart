import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Nihongo Comet tipografiya tizimi.
/// Baloo 2 - do'stona, yumaloq sarlavha shrifti (mockupdagi "Baloo 2").
/// Nunito - o'qishga qulay matn shrifti (mockupdagi "Nunito").
///
/// Ikkala shrift ham assets/fonts ostida offline paketlangan (internetga
/// bog'liq emas), shu sababli oddiy TextStyle(fontFamily: ...) orqali
/// ishlatiladi.
class AppTypography {
  static TextStyle onboardingTitle = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  static TextStyle sectionTitle = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle screenTitle = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle greetingName = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle goalPercent = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle body = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    height: 1.6,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.inkFaint,
  );

  static TextStyle buttonPrimary = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
  );

  static TextStyle buttonSecondary = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static TextStyle navLabel = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
  );

  static TextStyle lessonTitle = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static TextStyle lessonSubtitle = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
  );

  // --- Vokabulyar (lug'at) kartasi uchun maxsus stillar ---

  static TextStyle vocabRomajiTop = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.gold,
    letterSpacing: 0.5,
  );

  static TextStyle vocabKanji = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 56,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle vocabKana = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
  );

  static TextStyle vocabTranslation = const TextStyle(
    fontFamily: 'Baloo2',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static TextStyle vocabExample = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    height: 1.6,
  );

  static TextStyle vocabExampleRomaji = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.inkFaint,
  );
}
