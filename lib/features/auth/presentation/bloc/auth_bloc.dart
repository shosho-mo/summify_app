import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase})
      : super(AuthInitial()) {
    // معالجة حدث تسجيل الدخول
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthFailure('فشل تسجيل الدخول، حاول مرة أخرى.'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // معالجة حدث إنشاء حساب جديد
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await registerUseCase(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthFailure('فشل إنشاء الحساب.'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
