import 'package:hive/hive.dart';
import '../models/library_book_model.dart';

abstract class LibraryLocalDataSource {
  Future<void> saveBook(LibraryBookModel book);
  Future<List<LibraryBookModel>> getSavedBooks();
  Future<void> deleteBook(String id);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final String boxName = 'library_box';

  // دالة داخلية تضمن فتح الـ Box لمرة واحدة فقط وسهولة الوصول إليه
  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<void> saveBook(LibraryBookModel book) async {
    final box = await _getBox();
    // تخزين الكائن مباشرة أسرع وأفضل من الـ JSON إذا كان لديك Adapter
    await box.put(book.id, book);
  }

  @override
  Future<List<LibraryBookModel>> getSavedBooks() async {
    final box = await _getBox();
    // تحويل القيم مباشرة إلى List من نوع LibraryBookModel
    return box.values.cast<LibraryBookModel>().toList();
  }

  @override
  Future<void> deleteBook(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
