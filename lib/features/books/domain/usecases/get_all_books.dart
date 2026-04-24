import 'package:dartz/dartz.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';
import '../../../../core/error/failures.dart';

class GetAllBooks {
  final BookRepository repository;

  GetAllBooks(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getAllBooks();
  }
}
