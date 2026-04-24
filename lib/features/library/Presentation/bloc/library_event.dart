import '../../domain/entities/library_book.dart';

abstract class LibraryEvent {
  const LibraryEvent();
}

/// طلب تحميل كافة الكتب المخزنة في Hive
class LoadLibraryBooks extends LibraryEvent {
  const LoadLibraryBooks();
}

/// إضافة كتاب جديد
class AddBookToLibrary extends LibraryEvent {
  final LibraryBook book;
  // حذفنا const لأن الـ book قد يحتوي على DateTime.now()
  const AddBookToLibrary(this.book);
}

/// حذف كتاب
class RemoveBookFromLibrary extends LibraryEvent {
  final String bookId;
  const RemoveBookFromLibrary(this.bookId);
}

/// الحدث المسؤول عن التحميل
class DownloadBookContent extends LibraryEvent {
  final LibraryBook book;
  final String audioUrl;
  final String videoUrl;
  final String textUrl;

  // تم حذف كلمة const من هنا لحل مشكلة الـ DateTime والـ Error في الـ UI
  DownloadBookContent({
    required this.book,
    required this.audioUrl,
    required this.videoUrl,
    required this.textUrl,
  });
}
