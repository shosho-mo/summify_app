import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/entities/book.dart';
import '../datasources/book_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Book>>> getAllBooks() async {
    try {
      final remoteBooks = await remoteDataSource.getBooks();
      return Right(remoteBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // إضافة دالة البحث داخل الكلاس
  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    try {
      final remoteBooks = await remoteDataSource.searchBooks(query);
      return Right(remoteBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getTopSummaries() async {
    try {
      // منطق بسيط لجلب الكل ثم التصفية حسب التقييم (مثلاً > 4.5)
      final remoteBooks = await remoteDataSource.getBooks();
      final topBooks = remoteBooks.where((book) => book.rating >= 4.5).toList();
      return Right(topBooks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} // هذا القوس هو الذي يغلق الكلاس ويجب أن يكون في نهاية الملف
