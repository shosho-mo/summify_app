import 'package:equatable/equatable.dart';

class LibraryBook extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final DateTime addedAt;
  final String? localAudioPath;
  final String? localVideoPath;
  final String? localTextPath;

  const LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.addedAt,
    this.localAudioPath,
    this.localVideoPath,
    this.localTextPath,
  });

  // هذه القائمة تخبر Flutter متى يعتبر أن كتابين متطابقين
  @override
  List<Object?> get props => [
        id,
        title,
        author,
        coverUrl,
        addedAt,
        localAudioPath,
        localVideoPath,
        localTextPath,
      ];
}
