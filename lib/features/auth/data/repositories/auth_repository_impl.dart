import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User?> login(String email, String password) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> register(String email, String password) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
    );
    return response.user;
  }
}
