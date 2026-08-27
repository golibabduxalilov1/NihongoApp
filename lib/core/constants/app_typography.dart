import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Nihongo Manzil tipografiya tizimi.
/// Baloo 2 - do'stona, yumaloq sarlavha shrifti (mockupdagi "Baloo 2").
/// Nunito - o'qishga qulay matn shrifti (mockupdagi "Nunito").
class AppTypography {
  static TextStyle get onboardingTitle => GoogleFonts.baloo2(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.3,
      );

  static TextStyle get sectionTitle => GoogleFonts.baloo2(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get screenTitle => GoogleFonts.baloo2(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get greetingName => GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get goalPercent => GoogleFonts.baloo2(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSoft,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSoft,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.inkFaint,
      );

  static TextStyle get buttonPrimary => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  static TextStyle get buttonSecondary => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get navLabel => GoogleFonts.nunito(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get lessonTitle => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get lessonSubtitle => GoogleFonts.nunito(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSoft,
      );

  // --- Vokabulyar (lug'at) kartasi uchun maxsus stillar ---

  static TextStyle get vocabRomajiTop => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.gold,
        letterSpacing: 0.5,
      );

  static TextStyle get vocabKanji => GoogleFonts.nunito(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get vocabKana => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSoft,
      );

  static TextStyle get vocabTranslation => GoogleFonts.baloo2(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
      );

  static TextStyle get vocabExample => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSoft,
        height: 1.6,
      );

  static TextStyle get vocabExampleRomaji => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: AppColors.inkFaint,
      );
}
