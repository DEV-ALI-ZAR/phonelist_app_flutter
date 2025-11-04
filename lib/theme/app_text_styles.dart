import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontFamily: 'BitcountGridSingle',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'BitcountGridSingle',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'BitcountGridSingle',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'BitcountGridSingle',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
