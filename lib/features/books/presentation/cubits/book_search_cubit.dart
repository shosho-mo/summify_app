import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/book_repository.dart';
import 'book_search_state.dart';

class BookSearchCubit extends Cubit<BookSearchState> {
  final BookRepository repository;

  BookSearchCubit(this.repository) : super(BookSearchInitial());

  // دالة البحث المحدثة
  Future<void> searchBooks(String query, {String type = 'Title'}) async {
    if (query.trim().isEmpty) {
      emit(BookSearchInitial());
      return;
    }

    emit(BookSearchLoading());

    // نرسل الـ query والـ type للمستودع (Repository)
    // ملاحظة: تأكدي من تحديث دالة searchBooks في الـ Repository لتقبل النوع إذا كنتِ تبحثين من الـ Server
    final result = await repository.searchBooks(query);

    result.fold(
      (failure) => emit(BookSearchError(failure.message)),
      (books) {
        // ذكاء إضافي: تصفية النتائج محلياً بناءً على النوع المختار
        final filteredBooks = books.where((book) {
          final q = query.toLowerCase();
          switch (type) {
            case 'Author':
              return book.author.toLowerCase().contains(q);
            case 'Category':
              // افترضنا أن الكيان book يحتوي على حقل category أو tags
              return (book.category).toLowerCase().contains(q);
            case 'Title':
            default:
              return book.title.toLowerCase().contains(q);
          }
        }).toList();

        emit(BookSearchLoaded(filteredBooks));
      },
    );
  }

  // دالة مسح البحث للعودة للحالة الابتدائية (إظهار المحتوى الرئيسي للهوم)
  void clearSearch() {
    emit(BookSearchInitial());
  }
}
