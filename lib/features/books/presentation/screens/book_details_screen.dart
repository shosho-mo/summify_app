import 'package:flutter/material.dart';
import 'dart:math' as math; // مطلوب للفقاعات
import 'dart:ui'; // مطلوب لتأثيرات الـ Blur
import '../../domain/entities/book.dart';
import '../widgets/audio_summary_widget.dart';
import '../widgets/video_summary_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  // 1. إعدادات الأنيميشن للفقاعات
  late AnimationController _bubblesController;
  final List<GoldenBubble> _bubbles = [];
  final int _numberOfBubbles = 25; // عدد أقل لأنها كبيرة

  @override
  void initState() {
    super.initState();
    // تشغيل أنيميشن الفقاعات
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // حركة بطيئة وناعمة
    )..repeat();

    // توليد الفقاعات الكبيرة
    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(GoldenBubble());
    }
  }

  @override
  void dispose() {
    _bubblesController.dispose(); // تنظيف الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFFFD700);
    const Color darkBg = Color(0xFF0A0A0A); // الأسود الملكي

    return DefaultTabController(
      length: 3, // نص، صوت، فيديو
      child: Scaffold(
        backgroundColor: darkBg,
        // جعل الـ body يمتد خلف AppBar لشفافية أفضل
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {
                // سنبرمج نظام المفضلة لاحقاً هنا
              },
            ),
          ],
        ),
        // استخدام Stack لوضع الفقاعات في الخلفية
        body: Stack(
          children: [
            // 2. طبقة الفقاعات الذهبية الكبيرة في الخلفية
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

            // 3. محتوى الشاشة الرئيسي (فوق الفقاعات)
            SafeArea(
              child: Column(
                children: [
                  // 1. الجزء العلوي (صورة وبيانات الكتاب)
                  _buildBookHeader(),

                  const SizedBox(height: 10),

                  // 2. شريط التبديل (TabBar) بتصميم زجاجي خفيف
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const TabBar(
                      indicatorColor: goldColor,
                      labelColor: goldColor,
                      unselectedLabelColor: Colors.white60,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(icon: Icon(Icons.article_rounded), text: 'Read'),
                        Tab(
                            icon: Icon(Icons.audiotrack_rounded),
                            text: 'Listen'),
                        Tab(icon: Icon(Icons.play_circle_fill), text: 'Watch'),
                      ],
                    ),
                  ),

                  // 3. محتوى التبويبات (TabBarView)
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildReadSection(), // النص
                        _buildListenSection(), // الصوت
                        _buildWatchSection(), // الفيديو
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دوال بناء الأقسام (Widgets) ---

  Widget _buildBookHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Hero(
            tag: 'book-image-${widget.book.id}',
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.book.coverUrl,
                  height: 140,
                  width: 95,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'by ${widget.book.author}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(Icons.star, widget.book.rating.toString(),
                        const Color(0xFFFFD700)),
                    const SizedBox(width: 10),
                    _buildBadge(Icons.access_time,
                        '${widget.book.readTimeMin} min', Colors.white70),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildReadSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      // تأثير الزجاج لتقليل تشتيت الفقاعات الخلفية
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 10, sigmaY: 10), // تنعيم الخلفية خلف النص
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة توضيحية بسيطة
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ملخص الكتاب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // النص الفعلي
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    widget.book.summaryText.isNotEmpty
                        ? widget.book.summaryText
                        : 'لا يوجد ملخص متاح حالياً لهذا الكتاب.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily:
                          'Poppins', // تأكد من إضافة خط عربي مريح مثل 'Tajawal' إذا أمكن
                      color: Colors.white
                          .withOpacity(0.9), // أبيض مطفي قليلاً لراحة العين
                      fontSize: 17,
                      height: 1.8, // مسافة عمودية مريحة بين الأسطر
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 40), // مساحة إضافية في النهاية لراحة التمرير
              ],
            ),
          ),
        ),
      ),
    );
  }

  // قسم الاستماع (الصوت)
  Widget _buildListenSection() {
    return Center(
      child: widget.book.audioUrl.isNotEmpty
          ? AudioSummaryWidget(audioUrl: widget.book.audioUrl)
          : const Text('No audio available.',
              style: TextStyle(color: Colors.white54)),
    );
  }

  // قسم المشاهدة (الفيديو)
  Widget _buildWatchSection() {
    return Center(
      child: widget.book.videoUrl.isNotEmpty
          ? VideoSummaryWidget(videoUrl: widget.book.videoUrl)
          : const Text('No video available.',
              style: TextStyle(color: Colors.white54)),
    );
  }
}

// ==============================================================================
// --- كلاسات الأنيميشن والرسم الخاصة بالفقاعات الذهبية الكبيرة ---
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
    y = random.nextDouble() * 1.5; // ابدأ من أماكن مختلفة عمودياً
    // تكبير الحجم ليكون بين 5 و 15 لتبدو كبيرة
    size = random.nextDouble() * 10.0 + 5.0;
    speed = random.nextDouble() * 0.001 + 0.0005; // سرعة صعود بطيئة ناعمة
    opacity = random.nextDouble() * 0.3 + 0.1; // شفافية خفيفة جداً للعمق
  }

  void update() {
    y -= speed; // الصعود للأعلى
    if (y < -0.2) {
      // إعادة التدوير عند الخروج من الأعلى
      y = 1.2;
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

      // استخدام لون ذهبي بريميوم مع الشفافية الخاصة بالفقاعة
      paint.color = const Color(0xFFFFD700).withOpacity(bubble.opacity);

      // تأثير ضبابي (Blur) لتبدو كأنها أضواء خلفية ناعمة وتأثير زجاجي
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

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
