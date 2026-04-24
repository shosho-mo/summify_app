import 'package:dartz/dartz.dart';
import '/core/error/failures.dart';
import '../entities/book.dart';

// داخل ملف book_repository.dart
abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getAllBooks();
  Future<Either<Failure, List<Book>>> searchBooks(
      String query); // تأكدي من وجود هذا السطر
  Future<Either<Failure, List<Book>>> getTopSummaries();
}
