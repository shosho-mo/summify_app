import '../repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> call(String email, String password) async {
    return await repository.register(email, password);
  }
}
