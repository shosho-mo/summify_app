import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. إعداد الأنيميشن للظهور التدريجي (Fade In)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // 2. استدعاء دالة التوجيه الذكي
    _navigateToNext();
  }

  // دالة التحقق من حالة تسجيل الدخول
  Future<void> _navigateToNext() async {
    // ننتظر 3 ثوانٍ لإظهار اللوجو والأنيميشن بالكامل
    await Future.delayed(const Duration(seconds: 3));

    // الحصول على الجلسة الحالية من سوبابيز
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // إذا وجدنا جلسة (المستخدم مسجل دخول مسبقاً) -> نذهب للهوم مباشرة
      print('تم العثور على جلسة نشطة: الانتقال إلى الهوم');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // إذا لم توجد جلسة -> نذهب لشاشة تسجيل الدخول
      print('لا توجد جلسة: الانتقال إلى تسجيل الدخول');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 7, 7, 7), // اللون الداكن الاحترافي
      body: Stack(
        children: [
          // تأثير الإضاءة الخلفية (Glow Effect)
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // محتوى الشاشة (الشعار والنص) مع تأثير الفيد
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة الكتاب (يمكنك استبدالها بـ Image.asset لو عندك لوجو جاهز)
                  Image.asset(
                    'assets/images/logo1..png',
                    errorBuilder: (context, error, stackTrace) {
                      print('ERROR: $error');
                      return const Icon(Icons.error,
                          color: Colors.red, size: 50);
                    },
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Summify',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI-Powered Book Summaries',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // مؤشر تحميل هادئ في الأسفل
                  const SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Color(0xFFFACC15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
