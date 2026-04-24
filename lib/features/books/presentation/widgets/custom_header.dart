import 'package:flutter/material.dart';
import 'dart:math' as math;

// مطلوب من أجل ImageFilter

class ProfessionalBookHeader extends StatefulWidget {
  const ProfessionalBookHeader({super.key});

  @override
  State<ProfessionalBookHeader> createState() => _ProfessionalBookHeaderState();
}

class _ProfessionalBookHeaderState extends State<ProfessionalBookHeader>
    with TickerProviderStateMixin {
  late AnimationController _bubblesController;
  late AnimationController _iconsAnimationController; // متحكم لأيقونات الكتاب
  final List<GoldenBubble> _bubbles = [];
  final int _numberOfBubbles = 45;

  @override
  void initState() {
    super.initState();
    // 1. متحكم الفقاعات (كما هو)
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 2. متحكم حركة الأيقونات الخارجة من الكتاب (حركة ترددية لطيفة)
    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // تعاد الحركة بشكل عكسي لتبدو كالتحليق

    // توليد الفقاعات
    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(GoldenBubble());
    }
  }

  @override
  void dispose() {
    _bubblesController.dispose();
    _iconsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تدرج لوني ذهبي لاستخدامه في الأيقونات
    const double iconSize = 22.0;

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. الخلفية السوداء الداكنة
          Positioned.fill(
            child: Container(color: const Color(0xFF0A0A0A)),
          ),

          // 2. طبقة الفقاعات الذهبية الصغيرة
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

          // 3. المحتوى العلوي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // النصوص بتنسيق فاخر
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Smart Book',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                        ).createShader(bounds),
                        child: const Text(
                          'Summaries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- التعديل هنا: تصميم الكتاب الذهبي والأيقونات الخارجة ---
                  // نستخدم Stack هنا لترتيب الأيقونات فوق الكتاب
                  SizedBox(
                    width: 80, // عرض مخصص للمنطقة اليمنى
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // أ) الكتاب الذهبي المفتوح (الأساس)
                        const Positioned(
                          bottom: 10, // رفعه قليلاً للأعلى
                          child: Icon(
                            Icons.menu_book_rounded, // أيقونة كتاب مفتوح
                            color: Color(0xFFFFD700), // لون ذهبي خالص
                            size: 40,
                          ),
                        ),

                        // ب) الأيقونات المتحركة الخارجة من الكتاب
                        AnimatedBuilder(
                          animation: _iconsAnimationController,
                          builder: (context, child) {
                            // قيمة الحركة من 0.0 إلى 1.0
                            final value = _iconsAnimationController.value;
                            // مسافة التحليق العمودي
                            final double hoverOffset = value * 8.0;

                            return Stack(
                              children: [
                                // 1. أيقونة السماعة (يسار)
                                Positioned(
                                  bottom: 40 + hoverOffset, // ترتفع وتنخفض
                                  left: 0,
                                  child: _buildDynamicIcon(
                                    Icons.headset_mic_rounded,
                                    iconSize,
                                    value, // تمرير القيمة لعمل تأثير شفافية متذبذب
                                  ),
                                ),
                                // 2. أيقونة الفيديو (وسط)
                                Positioned(
                                  bottom:
                                      55 + (value * 12.0), // ترتفع أكثر قليلاً
                                  left: 28,
                                  child: _buildDynamicIcon(
                                    Icons.play_circle_fill_rounded,
                                    iconSize,
                                    value,
                                  ),
                                ),
                                // 3. أيقونة النص (يمين)
                                Positioned(
                                  bottom: 40 + hoverOffset,
                                  right: 0,
                                  child: _buildDynamicIcon(
                                    Icons.description_rounded,
                                    iconSize,
                                    value,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // --- نهاية التعديل ---
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء الأيقونات الصغيرة بتأثير تدرج وشفافية متحركة
  Widget _buildDynamicIcon(IconData icon, double size, double animationValue) {
    return Opacity(
      // تجعل الأيقونة تختفي قليلاً وتظهر أثناء الحركة (بين 0.6 و 1.0)
      opacity: 0.6 + (animationValue * 0.4),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFECB3), // ذهبي فاتح جداً (توهج)
            Color(0xFFFFD700), // ذهبي
            Color(0xFFB8860B), // ذهبي داكن
          ],
        ).createShader(bounds),
        child: Icon(
          icon,
          color: Colors.white, // اللون الأبيض مطلوب لعمل ShaderMask
          size: size,
        ),
      ),
    );
  }
}

// كلاس إدارة بيانات الفقاعات الصغيرة (كما هو بدون تغيير)
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
    x = random.nextDouble();
    y = random.nextDouble() * 1.2;
    size = random.nextDouble() * 2.5 + 0.5;
    speed = random.nextDouble() * 0.0012 + 0.0004;
    opacity = random.nextDouble() * 0.5 + 0.2;
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

// الرسام الخاص بالخلفية (كما هو بدون تغيير)
class BubblePainter extends CustomPainter {
  final List<GoldenBubble> bubbles;
  final double animationValue;

  BubblePainter({required this.bubbles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      bubble.update();
      paint.color = const Color(0xFFFFD700).withOpacity(bubble.opacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
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
