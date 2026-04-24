import 'package:hive/hive.dart';
import '../../domain/entities/library_book.dart';

class LibraryBookModel extends LibraryBook {
  @override
  final String id;
  @override
  final String title;
  @override
  final String author;
  @override
  final String coverUrl;
  @override
  final DateTime addedAt;

  // المسارات المحلية للمحتوى الثلاثي (صوت، فيديو، نص)
  @override
  final String? localAudioPath;
  @override
  final String? localVideoPath;
  @override
  final String? localTextPath;

  const LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.addedAt,
    this.localAudioPath,
    this.localVideoPath,
    this.localTextPath,
  }) : super(
          id: id,
          title: title,
          author: author,
          coverUrl: coverUrl,
          addedAt: addedAt,
          localAudioPath: localAudioPath,
          localVideoPath: localVideoPath,
          localTextPath: localTextPath,
        );

  // تحويل الكائن إلى Map إذا احتجت ذلك (اختياري)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'addedAt': addedAt.toIso8601String(),
      'localAudioPath': localAudioPath,
      'localVideoPath': localVideoPath,
      'localTextPath': localTextPath,
    };
  }
}

// 2. الـ Adapter اليدوي (للقراءة والكتابة في Hive)
class LibraryBookAdapter extends TypeAdapter<LibraryBookModel> {
  @override
  final int typeId = 0; // تأكد أن هذا الرقم فريد في تطبيقك

  @override
  LibraryBookModel read(BinaryReader reader) {
    return LibraryBookModel(
      id: reader.read(),
      title: reader.read(),
      author: reader.read(),
      coverUrl: reader.read(),
      addedAt: DateTime.parse(reader.read()), // تحويل النص إلى تاريخ
      localAudioPath: reader.read(),
      localVideoPath: reader.read(),
      localTextPath: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, LibraryBookModel obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.author);
    writer.write(obj.coverUrl);
    writer.write(obj.addedAt.toIso8601String()); // حفظ التاريخ كنص
    writer.write(obj.localAudioPath);
    writer.write(obj.localVideoPath);
    writer.write(obj.localTextPath);
  }
}
