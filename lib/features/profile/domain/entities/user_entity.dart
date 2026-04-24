// features/profile/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int booksRead;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.booksRead = 0,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, booksRead];
}
