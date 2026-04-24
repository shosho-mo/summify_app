// features/profile/data/models/user_model.dart

import 'package:summify/features/profile/domain/entities/user_entity.dart'
    show UserEntity;

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.booksRead,
  });

  // تحويل JSON القادم من Supabase إلى Model
  factory UserModel.fromJson(Map<String, dynamic> json, String email) {
    return UserModel(
      id: json['id'],
      name: json['full_name'] ?? 'No Name',
      email: email, // الإيميل يأتي من auth.user وليس من جدول البروفايل غالباً
      avatarUrl: json['avatar_url'],
      booksRead: json['books_count'] ?? 0,
    );
  }
}
