import '../entities/library_book.dart';

abstract class LibraryRepository {
  Future<void> addBook(LibraryBook book);
  Future<List<LibraryBook>> getDownloadedBooks();
  Future<void> removeBook(String id);
  Future<bool> isBookDownloaded(String id);
}
