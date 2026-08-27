/// Ikki matn (kutilgan va tanilgan) orasidagi o'xshashlikni hisoblaydi.
/// Levenshtein masofasi asosida — bu klassik, sof matematik algoritm,
/// hech qanday tarmoq so'rovi yoki tashqi xizmat talab qilmaydi
/// (offline-first tamoyiliga to'liq mos).
///
/// TZ funksiya 4: "taxminiy fonetik moslikni ko'rsatadi" — bu klass
/// speech_to_text natijasi (matn) bilan kutilgan matnni taqqoslab,
/// 0.0 dan 1.0 gacha moslik ballini beradi.
class PhoneticMatcher {
  /// [expected] — kutilgan matn (masalan romaji: "arigatou gozaimasu")
  /// [recognized] — speech_to_text tomonidan tanilgan matn
  /// Qaytaradi: 0.0 (umuman mos emas) dan 1.0 (aynan bir xil) gacha.
  static double similarity(String expected, String recognized) {
    final a = _normalize(expected);
    final b = _normalize(recognized);

    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;

    return 1.0 - (distance / maxLength);
  }

  static String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  static int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          final deletion = dp[i - 1][j] + 1;
          final insertion = dp[i][j - 1] + 1;
          final substitution = dp[i - 1][j - 1] + 1;
          dp[i][j] = [deletion, insertion, substitution].reduce((x, y) => x < y ? x : y);
        }
      }
    }

    return dp[m][n];
  }

  /// Moslik ballini foydalanuvchiga tushunarli darajaga aylantiradi.
  static String qualitativeLabel(double score) {
    if (score >= 0.85) return "A'lo!";
    if (score >= 0.65) return 'Yaxshi';
    if (score >= 0.4) return "Qayta urinib ko'ring";
    return "Yana mashq qiling";
  }
}
