import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';

abstract class BookSearchState extends Equatable {
  const BookSearchState();

  @override
  List<Object?> get props => [];
}

class BookSearchInitial extends BookSearchState {}

class BookSearchLoading extends BookSearchState {}

class BookSearchLoaded extends BookSearchState {
  final List<Book> books;
  final String? lastQuery; // اختياري: لتذكر آخر نص بحث
  final String? searchType; // اختياري: لتذكر نوع البحث

  const BookSearchLoaded(this.books, {this.lastQuery, this.searchType});

  @override
  List<Object?> get props => [books, lastQuery, searchType];
}

class BookSearchError extends BookSearchState {
  final String message;
  const BookSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
