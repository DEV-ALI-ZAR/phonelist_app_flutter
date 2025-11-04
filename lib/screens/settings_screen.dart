import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ali Zar',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkText
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'aizar@example.com',
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkHint
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Dark Mode Option
          Card(
            elevation: 3,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              title: Text(
                isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.textDark,
                ),
              ),
              subtitle: Text(
                isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                style: AppTextStyles.subtitle.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkHint
                      : AppColors.textLight,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: onThemeChanged,
                activeThumbColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}