import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppColors {
  static const Color background = Color(0xFF0F172A); // الأزرق الداكن للخلفية
  static const Color primaryGold = Color(
    0xFFFACC15,
  ); // الذهبي للأيقونات والأزرار
  static const Color cardGrey = Color(0xFF1E293B); // لون الكروت
  static const Color textWhite = Colors.white;
}

class ApiConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
