// features/profile/domain/repositories/profile_repository.dart

import 'package:summify/features/profile/domain/entities/user_entity.dart'
    show UserEntity;

abstract class ProfileRepository {
  Future<UserEntity> getUserProfile();
}
