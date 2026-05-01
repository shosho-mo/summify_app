import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F172A); // الأزرق الداكن للخلفية
  static const Color primaryGold =
      Color(0xFFFACC15); // الذهبي للأيقونات والأزرار
  static const Color cardGrey = Color(0xFF1E293B); // لون الكروت
  static const Color textWhite = Colors.white;
}

class ApiConstants {
  // نقوم بتعريف المفاتيح هنا باستخدام String.fromEnvironment
  // لتكون متاحة عبر المشروع بالكامل بدون الحاجة لملف .env
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String groqApiKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
}
