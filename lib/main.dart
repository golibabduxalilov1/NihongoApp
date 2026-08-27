import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/seed_data_loader.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/shell/main_shell.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ESLATMA (offline-first talabi): google_fonts paketi standart holda
  // birinchi marta shriftni internetdan yuklab, keshlab qo'yadi. Agar
  // qurilma birinchi ishga tushirishda internetga ulanmagan bo'lsa,
  // shrift standart Material shriftiga tushib qoladi (funksionallik
  // buzilmaydi, faqat vizual fallback). To'liq offline kafolat kerak
  // bo'lsa, .ttf fayllarni assets/fonts/ ga qo'shib pubspec.yaml orqali
  // paketlash kerak (keyingi bosqich).

  // Birinchi ishga tushirishda namunaviy 2 ta darsni bazaga yuklaymiz.
  // Haqiqiy foydalanishda buning o'rniga foydalanuvchi o'z kontentini
  // import qiladi (Sozlamalar -> Kontent import).
  await SeedDataLoader().seedIfEmpty();

  runApp(const ProviderScope(child: NihongoManzilApp()));
}

class NihongoManzilApp extends StatelessWidget {
  const NihongoManzilApp({super.key});

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
      home: const OnboardingScreen(),
    );
  }
}
