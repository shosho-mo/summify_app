import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioSummaryWidget extends StatefulWidget {
  final String audioUrl;
  const AudioSummaryWidget({super.key, required this.audioUrl});

  @override
  State<AudioSummaryWidget> createState() => _AudioSummaryWidgetState();
}

class _AudioSummaryWidgetState extends State<AudioSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // إعدادات الفقاعات الذهبية
  late AnimationController _bubblesController;
  final List<GoldenBubble> _bubbles = [];
  final int _numberOfBubbles = 40; // عدد مناسب لحجم ويدجت الصوت

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // 1. منطق الأنيميشن للفقاعات
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(GoldenBubble());
    }

    // 2. منطق الصوت
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => position = newPosition);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bubblesController.dispose(); // إغلاق الأنيميشن
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black, // الأسود الملكي
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // طبقة الفقاعات في الخلفية
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

          // واجهة التحكم بالصوت
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط التقدم (Slider)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds
                      .toDouble()
                      .clamp(0, duration.inSeconds.toDouble()),
                  activeColor: const Color(0xFFFACC15), // ذهبي
                  inactiveColor: Colors.white12,
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
              ),

              // عداد الوقت
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(position),
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                    Text(_formatTime(duration),
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeekButton(Icons.replay_10, () {
                    _audioPlayer.seek(position - const Duration(seconds: 10));
                  }),
                  const SizedBox(width: 30),

                  // زر التشغيل المركزي
                  GestureDetector(
                    onTap: () async {
                      if (isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play(UrlSource(widget.audioUrl));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFACC15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66FACC15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 45,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 30),
                  _buildSeekButton(Icons.forward_10, () {
                    _audioPlayer.seek(position + const Duration(seconds: 10));
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeekButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 32),
      onPressed: onPressed,
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// --- كلاسات رسم الفقاعات (تأكد من وجودها أو تعريفها هنا) ---

class GoldenBubble {
  late double x, y, size, speed, opacity;
  GoldenBubble() {
    randomize();
  }

  void randomize() {
    final r = math.Random();
    x = r.nextDouble();
    y = r.nextDouble();
    size = r.nextDouble() * 5.0 + 1.0;
    speed = r.nextDouble() * 0.002 + 0.001;
    opacity = r.nextDouble() * 0.5 + 0.1;
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
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
    for (var b in bubbles) {
      b.update();
      final paint = Paint()
        ..color = const Color(0xFFFACC15).withOpacity(b.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
          Offset(b.x * size.width, b.y * size.height), b.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}
