import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.coverUrl,
    required super.rating,
    required super.category,
    required super.description,
    required super.summaryText,
    required super.audioUrl,
    required super.videoUrl,
    super.readTimeMin,
    super.hasAudio,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // 1. استخراج اسم المؤلف من جدول authors المرتبط
    // سوبابيز يعيد البيانات المرتبطة كـ Map (كائن) داخل الـ JSON
    final authorData = json['authors'] as Map<String, dynamic>?;
    final authorName = authorData?['full_name']?.toString() ?? 'Unknown Author';

    // 2. استخراج بيانات الملخص والميديا من جدول summaries المرتبط
    final summaryData = json['summaries'] as Map<String, dynamic>?;

    return BookModel(
      id: json['id']?.toString() ?? '0',
      title: json['title']?.toString() ?? 'Unknown Title',
      author: authorName, // القيمة المسحوبة من جدول authors
      coverUrl: json['cover_url']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',

      // جلب البيانات من كائن الملخص المتداخل
      summaryText: summaryData?['content']?.toString() ?? '',
      audioUrl: summaryData?['audio_url']?.toString() ?? '',
      videoUrl: summaryData?['video_url']?.toString() ?? '',
      readTimeMin: summaryData?['reading_time'] as int? ?? 10,
      hasAudio: (summaryData?['audio_url'] != null &&
          summaryData?['audio_url']?.toString().isNotEmpty == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_url': coverUrl,
      'rating': rating,
      'description': description,
      // ملاحظة: الحقول الأخرى (المؤلف والملخص) يتم التعامل معها في جداولها الخاصة في سوبابيز
    };
  }
}
