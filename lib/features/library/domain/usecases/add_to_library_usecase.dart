import '../entities/library_book.dart';
import '../repositories/library_repository.dart';

class AddToLibraryUseCase {
  final LibraryRepository repository;

  AddToLibraryUseCase(this.repository);

  Future<void> call(LibraryBook book) async {
    return await repository.addBook(book);
  }
}
