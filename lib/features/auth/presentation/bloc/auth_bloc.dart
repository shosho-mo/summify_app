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
        emit(AuthFailure(_mapExceptionToMessage(e)));
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
        emit(AuthFailure(_mapExceptionToMessage(e)));
      }
    });
  }

  // دالة خاصة لترجمة الأخطاء التقنية إلى رسائل مفهومة للمستخدم
  String _mapExceptionToMessage(dynamic e) {
    String error = e.toString().toLowerCase();

    if (error.contains('user-not-found')) {
      return 'عذراً، البريد الإلكتروني غير مسجل لدينا.';
    } else if (error.contains('wrong-password')) {
      return 'كلمة المرور غير صحيحة.';
    } else if (error.contains('email-already-in-use')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل.';
    } else if (error.contains('network-request-failed') ||
        error.contains('socketexception')) {
      return 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.';
    } else if (error.contains('invalid-email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة.';
    }

    // رسالة افتراضية لأي خطأ غير معروف
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.';
  }
}
