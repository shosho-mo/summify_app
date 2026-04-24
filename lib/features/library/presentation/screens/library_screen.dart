import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:summify/features/library/presentation/bloc/library_bloc.dart';
import 'package:summify/features/library/presentation/bloc/library_event.dart';
import 'package:summify/features/library/presentation/bloc/library_state.dart';
import 'package:summify/features/library/domain/entities/library_book.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(const LoadLibraryBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // الخلفية الأساسية خلف الفقاعات
      body: Stack(
        children: [
          // 1. طبقة الفقاعات (تم زيادة العدد والحجم هنا)
          const Positioned.fill(
            child: FullPageBubbleBackground(
              numberOfBubbles: 80, // عدد أكبر (كان 50 في الهوم)
              maxBubbleSize: 6.0, // حجم أكبر (كان 3.0 في الهوم)
            ),
          ),

          // 2. المحتوى الأصلي للشاشة
          SafeArea(
            child: Column(
              children: [
                // AppBar مخصص شفاف
                _buildCustomAppBar(),

                Expanded(
                  child: BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      if (state is LibraryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFD700)),
                        );
                      } else if (state is LibraryLoaded) {
                        if (state.books.isEmpty) {
                          return _buildEmptyState();
                        }
                        return isGridView
                            ? _buildGridView(state.books)
                            : _buildListView(state.books);
                      } else if (state is LibraryError) {
                        return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.redAccent)),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'مكتبتي',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            onPressed: () => setState(() => isGridView = !isGridView),
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- بقية الـ Widgets (ListView, GridView, OptionTile) كما هي مع التأكد من شفافية الألوان ---

  Widget _buildListView(List<LibraryBook> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) =>
          _buildLibraryListTile(context, books[index]),
    );
  }

  Widget _buildGridView(List<LibraryBook> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) =>
          _buildLibraryGridTile(context, books[index]),
    );
  }

  Widget _buildLibraryListTile(BuildContext context, LibraryBook book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), // جعلها شبه شفافة
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(book.coverUrl,
              width: 50, height: 70, fit: BoxFit.cover),
        ),
        title: Text(book.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(book.author,
            style: TextStyle(color: Colors.white.withOpacity(0.6))),
        trailing: IconButton(
          icon:
              const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => _showDeleteConfirmation(context, book),
        ),
        onTap: () => _showContentOptions(context, book),
      ),
    );
  }

  Widget _buildLibraryGridTile(BuildContext context, LibraryBook book) {
    return GestureDetector(
      onTap: () => _showContentOptions(context, book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                        image: NetworkImage(book.coverUrl), fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3), blurRadius: 10)
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (book.localAudioPath != null)
                        _buildSmallIcon(Icons.headset),
                      if (book.localVideoPath != null)
                        _buildSmallIcon(Icons.play_circle_fill),
                      if (book.localTextPath != null)
                        _buildSmallIcon(Icons.description),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(book.author,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(2),
      decoration:
          const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 12),
    );
  }

  // ميثودز الحذف والخيارات (تبقى كما هي في كودك الأصلي)
  void _showContentOptions(BuildContext context, LibraryBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(book.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (book.localTextPath != null)
              _buildOptionTile(
                  Icons.description, 'قراءة الملخص النصي', Colors.blue, () {}),
            if (book.localAudioPath != null)
              _buildOptionTile(
                  Icons.headset, 'الاستماع للملخص الصوتي', Colors.green, () {}),
            if (book.localVideoPath != null)
              _buildOptionTile(Icons.play_circle_fill, 'مشاهدة ملخص الفيديو',
                  Colors.redAccent, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: onTap);
  }

  void _showDeleteConfirmation(BuildContext parentContext, LibraryBook book) {
    final libraryBloc = parentContext.read<LibraryBloc>();
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('حذف الكتاب', style: TextStyle(color: Colors.white)),
        content: Text("هل أنت متأكد من حذف '${book.title}' من المكتبة؟",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  const Text('إلغاء', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              libraryBloc.add(RemoveBookFromLibrary(book.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('مكتبتك فارغة حالياً',
              style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
}

// --- محرك الخلفية مع خيارات التخصيص (عدد وحجم الفقاعات) ---
class FullPageBubbleBackground extends StatefulWidget {
  final int numberOfBubbles;
  final double maxBubbleSize;

  const FullPageBubbleBackground({
    super.key,
    this.numberOfBubbles = 80,
    this.maxBubbleSize = 6.0,
  });

  @override
  State<FullPageBubbleBackground> createState() =>
      _FullPageBubbleBackgroundState();
}

class _FullPageBubbleBackgroundState extends State<FullPageBubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<LibraryBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    for (int i = 0; i < widget.numberOfBubbles; i++) {
      _bubbles.add(LibraryBubble(maxSize: widget.maxBubbleSize));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: LibraryBubblePainter(bubbles: _bubbles));
      },
    );
  }
}

class LibraryBubble {
  late double x, y, size, speed, opacity;
  final double maxSize;

  LibraryBubble({required this.maxSize}) {
    randomize();
  }

  void randomize() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble() * 1.2;
    size = random.nextDouble() * maxSize + 1.0; // حجم أكبر قليلاً
    speed = random.nextDouble() * 0.0015 + 0.0005;
    opacity = random.nextDouble() * 0.4 + 0.1;
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

class LibraryBubblePainter extends CustomPainter {
  final List<LibraryBubble> bubbles;
  LibraryBubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD700);
    for (var bubble in bubbles) {
      bubble.update();
      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        bubble.size,
        paint..color = const Color(0xFFFFD700).withOpacity(bubble.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
