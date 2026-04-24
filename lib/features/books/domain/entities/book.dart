import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final double rating; // تأكدي من وجود هذا
  final String category; // تأكدي من وجود هذا
  final String description; // تأكدي من وجود هذا
  final String summaryText;
  final String audioUrl;
  final String videoUrl;
  final int readTimeMin;
  final bool hasAudio;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.rating,
    required this.category,
    required this.description,
    required this.summaryText,
    required this.audioUrl,
    required this.videoUrl,
    this.readTimeMin = 10,
    this.hasAudio = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    coverUrl,
    rating,
    category,
    description,
    summaryText,
    audioUrl,
    videoUrl,
  ];
}
