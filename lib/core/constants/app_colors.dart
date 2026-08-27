import 'package:flutter/material.dart';

/// Nihongo Manzil dizayn tizimi.
/// Manba: "kitob + yapon bayrog'i" mockup dizayni (2026-08).
/// Har bir rang mockupdagi CSS o'zgaruvchisiga mos keladi (izohlarga qarang).
class AppColors {
  // --- Asosiy fon va sirtlar ---
  static const cream = Color(0xFFFAF7F0); // --cream (asosiy fon)
  static const white = Color(0xFFFFFFFF); // --white (kartalar)
  static const background = cream; // eski nom bilan moslik uchun

  // --- Qizil (asosiy aksent) ---
  static const primary = Color(0xFFE1483F); // --red
  static const primaryDark = Color(0xFFC63831); // --red-dark
  static const primaryLight = Color(0xFFFFE4E1); // --red-light (yumshoq fon)

  // --- Ikkinchi darajali fonlar ---
  static const peach = Color(0xFFFFEEE2); // --peach (onboarding, joriy dars ikonkasi)
  static const lavender = Color(0xFFEDEBFB); // --lavender
  static const mint = Color(0xFFE1F5EE); // --mint (yakunlangan holat)

  // --- Matn ---
  static const ink = Color(0xFF2B2B2B); // --ink (asosiy matn)
  static const inkSoft = Color(0xFF6B6B6B); // --ink-soft (ikkinchi darajali matn)
  static const inkFaint = Color(0xFFA8A49C); // --ink-faint (qulflangan/passiv)

  // --- Semantik ranglar ---
  static const gold = Color(0xFFF5A623); // --gold (joriy bosqich, yulduzcha)
  static const green = Color(0xFF4CAF50); // --green (bajarilgan)
  static const border = Color(0xFFEDE8DF); // --border

  // Eski nomlar bilan moslik (mavjud kodni buzmaslik uchun)
  static const secondary = Color(0xFF2E4057);
  static const success = green;
  static const warning = gold;
  static const error = Color(0xFFE53935);
  static const locked = inkFaint;

  // Grammatika misollarida so'z turlarini rang bilan ajratish uchun
  static const grammarVerb = Color(0xFF1976D2);
  static const grammarParticle = Color(0xFF7B1FA2);
  static const grammarNoun = Color(0xFF388E3C);
}

