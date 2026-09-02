import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/seed_data_loader.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // MUHIM (offline-first va oq-ekran muammosining oldini olish):
  // google_fonts paketi standart holda shriftni internetdan yuklashga
  // urinadi. Agar qurilma internetga ulanmagan bo'lsa yoki so'rov sekin
  // bo'lsa, bu birinchi render paytida ilovani "qotirib qo'yishi" mumkin
  // (oq ekran, hech narsa bosilmaydi). Shu qatorlar orqali tarmoq orqali
  // yuklashni butunlay o'chirib, faqat qurilmada mavjud shriftlarga
  // (agar assets/fonts orqali paketlangan bo'lsa) yoki standart Material
  // shriftiga tushishni majburlaymiz — ilova hech qachon shrift kutib
  // osilib qolmaydi.
  GoogleFonts.config.allowRuntimeFetching = false;

  String? startupError;

  try {
    // Birinchi ishga tushirishda namunaviy 2 ta darsni bazaga yuklaymiz.
    // Haqiqiy foydalanishda buning o'rniga foydalanuvchi o'z kontentini
    // import qiladi (Sozlamalar -> Kontent import).
    await SeedDataLoader().seedIfEmpty();
  } catch (e, stack) {
    // Seed data yuklashda xato chiqsa ham ilova oq ekranda qotib
    // qolmasin — xatoni ekranda ko'rsatib, tashxis qo'yishga imkon beramiz.
    debugPrint('Seed data yuklashda xato: $e\n$stack');
    startupError = e.toString();
  }

  runApp(ProviderScope(child: NihongoManzilApp(startupError: startupError)));
}

class NihongoManzilApp extends StatelessWidget {
  final String? startupError;
  const NihongoManzilApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo Manzil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.cream,
      ),
      // Agar ishga tushirishda xato bo'lsa, oq ekran o'rniga aniq xato
      // xabarini ko'rsatamiz — shunda foydalanuvchi ekranni screenshot
      // qilib, muammoni aniqlashtirib bo'ladi.
      home: startupError != null
          ? _StartupErrorScreen(error: startupError!)
          : const OnboardingScreen(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _StartupErrorScreen(error: details.exceptionAsString());
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Har qanday kutilmagan xato (ishga tushirishda yoki widget render
/// jarayonida) oq ekran o'rniga shu ekranga olib keladi — foydalanuvchi
/// xato matnini ko'rib, uni ishlab chiquvchiga yuborishi mumkin.
class _StartupErrorScreen extends StatelessWidget {
  final String error;
  const _StartupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Ilova ishga tushishda xato yuz berdi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Iltimos, shu ekranni screenshot qilib yuboring:",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  error,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
