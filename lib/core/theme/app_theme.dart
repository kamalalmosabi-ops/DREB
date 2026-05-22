import 'package:flutter/material.dart';

class AppTheme {
  // اللون الذهبي الملكي المعتمد من قِبلكِ لمشروع درب
  static const Color primaryColor = Color(0xFFE6A440);

  // 1. الثيم الفاتح (Light Theme) متناسق مع لونكِ الأساسي
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Tajawal',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
      ),
      
      // تنسيق الأزرار في الوضع الفاتح
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // نص أبيض على زر ذهبي
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
      ),
    );
  }

  // 2. الثيم الداكن (Dark Theme) الخاص بكِ تماماً بعد ترتيبه
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // تنسيق الأزرار في الوضع الداكن ليظهر بشكل فخم ومقروء
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black, // نص أسود على زر ذهبي يطلع شكله بطل في الـ Dark Mode
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
      ),
    );
  }
}