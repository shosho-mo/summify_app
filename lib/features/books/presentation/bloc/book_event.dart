import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();
  @override
  List<Object> get props => [];
}

class FetchAllBooksEvent extends BookEvent {}
