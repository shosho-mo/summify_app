import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../manager/chat_cubit.dart';
import '../../domain/entities/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubblesController;
  final List<GoldenBubble> _bubbles = [];
  // زيادة عدد الفقاعات لتغطية الشاشة بكثافة أعلى
  final int _numberOfBubbles = 75;

  @override
  void initState() {
    super.initState();
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < _numberOfBubbles; i++) {
      _bubbles.add(GoldenBubble());
    }
  }

  @override
  void dispose() {
    _bubblesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    const Color goldColor = Color(0xFFFFD700);
    const Color darkBg = Color(0xFF0A0A0A);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Summify Assistant',
              style: TextStyle(
                color: goldColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: goldColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: goldColor, blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'نشط الآن',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: goldColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. الخلفية السوداء الملكية
          Positioned.fill(child: Container(color: darkBg)),

          // 2. طبقة الفقاعات الذهبية (المحسنة)
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

          // 3. واجهة الدردشة
          Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    final messages = state.messages;
                    final isLoading = state is ChatLoading;

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 120, 14, 20),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isLoading) {
                          return _buildLoadingIndicator(goldColor);
                        }
                        return _buildModernBubble(
                            messages[index], context, goldColor);
                      },
                    );
                  },
                ),
              ),
              _buildEnhancedInput(context, controller, goldColor, darkBg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernBubble(
      ChatMessage message, BuildContext context, Color gold) {
    bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white10,
              backgroundImage: AssetImage('assets/images/logo1..png'),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  // تأثير الزجاج الشفاف ليظهر ما خلفه من فقاعات
                  color: isUser
                      ? gold.withOpacity(0.25)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: Border.all(
                    color: isUser ? gold.withOpacity(0.5) : Colors.white12,
                    width: 1,
                  ),
                ),
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInput(BuildContext context,
      TextEditingController controller, Color gold, Color bg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.9), // تعتيم بسيط خلف منطقة الكتابة للوضوح
        border:
            Border(top: BorderSide(color: gold.withOpacity(0.2), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'اسأل Summify عن كتابك...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ChatCubit>().sendMessage(controller.text);
                controller.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: gold.withOpacity(0.4), blurRadius: 10)
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white10,
              child: Icon(Icons.auto_awesome, size: 12, color: Colors.amber)),
          const SizedBox(width: 10),
          Text(
            'Summify يحلل النص حالياً...',
            style: TextStyle(
                color: gold.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// --- كلاس الفقاعات الذهبية المحدث (أكبر وأوضح) ---

class GoldenBubble {
  late double x, y, size, speed, opacity;

  GoldenBubble() {
    randomize();
  }

  void randomize() {
    final r = math.Random();
    x = r.nextDouble();
    y = r.nextDouble() * 1.5;
    // تم تكبير الحجم ليكون بين 2.5 و 6.5
    size = r.nextDouble() * 4.0 + 2.5;
    // سرعة عشوائية هادئة
    speed = r.nextDouble() * 0.0012 + 0.0006;
    // زيادة الشفافية لتكون واضحة (20% إلى 50%)
    opacity = r.nextDouble() * 0.3 + 0.2;
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
        ..color = const Color(0xFFFFD700).withOpacity(b.opacity)
        // إضافة توهج (Blur) ليعطي طابعاً ملكياً مضيئاً
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
          Offset(b.x * size.width, b.y * size.height), b.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}
