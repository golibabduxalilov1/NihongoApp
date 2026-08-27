import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// TZ bo'lim 11 ga muvofiq: foydalanuvchi o'zining qonuniy yo'l bilan
/// olingan darslik nusxasidan JSON formatida kontent import qiladi.
/// Bu ekran hozircha UI skeleton — real fayl parsing keyingi bosqichda
/// ContentImportRepository orqali qo'shiladi.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Kontent import qilish'),
            subtitle: const Text(
                "O'zingizning darslik JSON faylingizni yuklang"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Import funksiyasi: assets/sample_data/lesson_template.json formatiga qarang"),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Til'),
            subtitle: const Text("O'zbekcha"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Mualliflik huquqi haqida'),
            subtitle: const Text(
                "Minna no Nihongo — 3A Corporation nashri. Bu ilova faqat mashq vositasi."),
          ),
        ],
      ),
    );
  }
}
