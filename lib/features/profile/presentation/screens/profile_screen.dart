import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math; // مطلوب للفقاعات
// مطلوب لتأثيرات الفلتر الزجاجي
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // 1. إعدادات الأنيميشن للفقاعات
  late AnimationController _bubblesController;
  final List<GoldenBubble> _bubbles = [];
  final int _numberOfBubbles = 30; // عدد معقول للشاشة كاملة

  @override
  void initState() {
    super.initState();
    // جلب البيانات
    context.read<ProfileBloc>().add(const FetchUserProfile());

    // 2. تشغيل أنيميشن الفقاعات
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // حركة بطيئة وناعمة
    )..repeat();

    // توليد الفقاعات
    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(GoldenBubble());
    }
  }

  @override
  void dispose() {
    _bubblesController.dispose(); // تنظيف الذاكرة
    super.dispose();
  }

  // دالة عرض نافذة "عن التطبيق" بتصميم عصري (تم تعديل الألوان لتناسب الأسود)
  void _showAboutSummify(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A), // أسود داكن
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        side: BorderSide(color: Colors.white10, width: 0.5), // إطار رقيق
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.auto_stories,
                  size: 50, color: Color(0xFFFFD700)), // ذهبي بريميوم
              const SizedBox(height: 15),
              const Text(
                'Summify',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              const Text(
                '  هو رفيقك الذكي للقراءة. نسعى لتوفير ملخصات صوتية ومكتوبة لأهم الكتب العالمية، لمساعدتك على التعلم وتطوير ذاتك في وقت أقل بكفاءة وموثوقية عالية.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),
              const Text(
                'إصدار التطبيق 1.0.0',
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0A0A0A); // اللون الأسود الملكي

    return Scaffold(
      backgroundColor: darkBg,
      // جعل الـ body يمتد خلف AppBar لشفافية أفضل
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('الملف الشخصي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // شفاف
        elevation: 0,
        centerTitle: true,
      ),
      // استخدام Stack لوضع الفقاعات في الخلفية والمحتوى فوقها
      body: Stack(
        children: [
          // 3. طبقة الفقاعات الذهبية في الخلفية
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bubblesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BubblePainter(
                    bubbles: _bubbles,
                    animationValue: _bubblesController.value,
                  ),
                );
              },
            ),
          ),

          // 4. طبقة المحتوى الرئيسي
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                );
              } else if (state is ProfileLoaded) {
                final user = state.user;
                return SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(user.name, user.email, user.avatarUrl),
                        const SizedBox(height: 30),
                        _buildStatsSection(user.booksRead),
                        const SizedBox(height: 30),
                        _buildProfileMenu(context),
                        const SizedBox(height: 50), // مساحة سفلية
                      ],
                    ),
                  ),
                );
              } else if (state is ProfileError) {
                return _buildErrorWidget(context, state.message);
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  // --- ويدجت مساعدة لبناء الأجزاء المختلفة ---

  Widget _buildHeader(String name, String email, String? avatarUrl) {
    const Color gold = Color(0xFFFFD700);
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: gold.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2)
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.grey[900],
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: gold)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration:
                    const BoxDecoration(color: gold, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(name,
            style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        Text(email,
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsSection(int booksCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // تأثير زجاجي خفيف (Glassmorphism)
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(booksCount.toString(), 'كتاب قرأته'),
          Container(width: 1, height: 30, color: Colors.white10),
          _statItem('0', 'دقيقة استماع'),
          Container(width: 1, height: 30, color: Colors.white10),
          _statItem('0', 'أوسمة'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700))), // ذهبي
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
        ),
        child: Column(
          children: [
            _menuItem(Icons.settings_outlined, 'الإعدادات', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: الإعدادات')));
            }),
            _menuItem(Icons.favorite_outline, 'المفضلة والمكتبة', onTap: () {
              Navigator.pushNamed(context, '/library');
            }),
            _menuItem(Icons.info_outline, 'عن تطبيق Summify', onTap: () {
              _showAboutSummify(context);
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(color: Colors.white10, height: 30),
            ),
            _menuItem(Icons.logout_rounded, 'تسجيل الخروج', isLogout: true,
                onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title,
      {bool isLogout = false, VoidCallback? onTap}) {
    Color primaryColor = isLogout ? Colors.redAccent : Colors.white;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.redAccent.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryColor.withOpacity(0.8), size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
      onTap: onTap,
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 70, color: Colors.redAccent.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(message,
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () =>
                context.read<ProfileBloc>().add(const FetchUserProfile()),
            child: const Text('إعادة المحاولة',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// ==============================================================================
// --- كلاسات الأنيميشن والرسم الخاصة بالفقاعات الذهبية (كما في الشاشات السابقة) ---
// ==============================================================================

class GoldenBubble {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;

  GoldenBubble() {
    randomize();
  }

  void randomize() {
    final random = math.Random();
    x = random.nextDouble(); // موقع أفقي عشوائي
    y = random.nextDouble() * 1.2; // ابدأ من أسفل الشاشة قليلاً
    size = random.nextDouble() * 3.0 + 0.8; // أحجام صغيرة ومتنوعة
    speed = random.nextDouble() * 0.001 + 0.0003; // سرعة صعود بطيئة
    opacity = random.nextDouble() * 0.4 + 0.1; // شفافية خفيفة
  }

  void update() {
    y -= speed; // الصعود للأعلى
    if (y < -0.1) {
      // إعادة التدوير عند الخروج من الأعلى
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

class BubblePainter extends CustomPainter {
  final List<GoldenBubble> bubbles;
  final double animationValue;

  BubblePainter({required this.bubbles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      bubble.update(); // تحديث موقع النقطة

      // استخدام لون ذهبي بريميوم
      paint.color = const Color(0xFFFFD700).withOpacity(bubble.opacity);

      // تأثير ضبابي خفيف لتبدو كأنها تتوهج
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        bubble.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
