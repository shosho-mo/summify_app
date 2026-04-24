import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_books.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetAllBooks getAllBooks;

  BookBloc({required this.getAllBooks}) : super(BookInitial()) {
    on<FetchAllBooksEvent>((event, emit) async {
      emit(BookLoading());

      final result = await getAllBooks();

      result.fold(
        (failure) => emit(BookError(failure.message)),
        (books) => emit(BookLoaded(books)),
      );
    });
  }
}
