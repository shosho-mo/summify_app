import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_data_source.dart';
import '../models/library_book_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource localDataSource;

  LibraryRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addBook(LibraryBook book) async {
    // تحديث بناء الموديل ليدعم المسارات الثلاثة الجديدة
    final model = LibraryBookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      coverUrl: book.coverUrl,
      addedAt: book.addedAt,
      // تمرير المسارات الجديدة من الـ Entity إلى الـ Model
      localAudioPath: book.localAudioPath,
      localVideoPath: book.localVideoPath,
      localTextPath: book.localTextPath,
    );

    await localDataSource.saveBook(model);
  }

  @override
  Future<List<LibraryBook>> getDownloadedBooks() async {
    // جلب الموديلات من مصدر البيانات المحلي
    final List<LibraryBookModel> models = await localDataSource.getSavedBooks();

    // تحويل القائمة من List<LibraryBookModel> إلى List<LibraryBook>
    // استخدام map أفضل وأضمن من cast في بعض الحالات
    return models.map((model) => model as LibraryBook).toList();
  }

  @override
  Future<void> removeBook(String id) async {
    await localDataSource.deleteBook(id);
  }

  @override
  Future<bool> isBookDownloaded(String id) async {
    // تحقق مما إذا كان الكتاب موجوداً في القائمة المحلية
    final books = await localDataSource.getSavedBooks();
    return books.any((b) => b.id == id);
  }
}
