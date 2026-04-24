import 'package:flutter/material.dart';
import 'package:summify/features/library/domain/entities/library_book.dart';
import 'download_button.dart';
import '../../domain/entities/book.dart';
import '../screens/book_details_screen.dart';

class FeaturedBookCard extends StatelessWidget {
  final Book book;
  final bool isGrid; // متغير للتحكم في الحجم بناءً على نوع العرض

  const FeaturedBookCard({
    super.key,
    required this.book,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الأبعاد بناءً على نوع العرض (ليستة أفقية أم جريد)
    final double cardWidth = isGrid ? double.infinity : 170.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)),
      ),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: isGrid ? 0 : 16, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // ظل ناعم واحترافي
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. الصورة (استخدام CacheNetworkImage إذا توفر لسرعة أعلى)
              _buildCoverImage(),

              // 2. تدرج لوني سينمائي (Cinematic Overlay)
              _buildModernGradient(),

              // 3. المحتوى
              _buildInfoSection(),

              // 4. زر التحميل (موضع ذكي)
              _buildDownloadPositioned(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Hero(
      tag: 'book-image-${book.id}',
      child: Image.network(
        book.coverUrl,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
        // تحسين سرعة التحميل بالاعتماد على ذاكرة التخزين المؤقت
        filterQuality: FilterQuality.low,
      ),
    );
  }

  Widget _buildModernGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 45, // ترك مساحة لزر التحميل
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // ويدجت "Quick Summary" بشكل أنحف واحترافي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SUMMARY',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPositioned() {
    return Positioned(
      bottom: 10,
      right: 8,
      child: Transform.scale(
        scale: 0.85, // تصغير الحجم قليلاً ليكون ألطف
        child: DownloadButton(
          book: LibraryBook(
            id: book.id,
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl,
            addedAt: DateTime.now(),
          ),
          audioUrl: book.audioUrl,
          videoUrl: book.videoUrl,
          textUrl: book.summaryText,
        ),
      ),
    );
  }
}
