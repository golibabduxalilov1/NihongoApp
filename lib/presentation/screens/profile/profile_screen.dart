import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Text('Profil', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: AppColors.primaryDark, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Do'stim", style: AppTypography.lessonTitle),
                    const SizedBox(height: 2),
                    Text('N5 darajasi · 12 kunlik streak', style: AppTypography.lessonSubtitle),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Sozlamalar', style: AppTypography.sectionTitle),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.file_upload_outlined,
            title: 'Kontent import qilish',
            subtitle: "O'zingizning darslik JSON faylingizni yuklang",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Import formati: assets/sample_data/lesson_template.json',
                  ),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: 'Kunlik maqsad',
            subtitle: '20 daqiqa',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Til',
            subtitle: "O'zbekcha",
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Mualliflik huquqi haqida',
            subtitle: '3A Corporation nashri, bu ilova mustaqil mashq vositasi',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.ink),
        title: Text(title, style: AppTypography.lessonTitle.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: AppTypography.lessonSubtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.inkFaint),
        onTap: onTap,
      ),
    );
  }
}
