import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';

// --- Events ---
abstract class ProfileEvent extends Equatable {
  const ProfileEvent(); // إضافة const هنا
  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends ProfileEvent {
  const FetchUserProfile();
}

// --- States ---
abstract class ProfileState extends Equatable {
  const ProfileState(); // ضروري جداً لكي تعمل الـ subclasses بـ const

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;

  ProfileBloc({required this.getUserProfile}) : super(const ProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await getUserProfile();
      // أزيلي const من هنا إذا كانت تسبب مشكلة مع الـ dynamic data
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(const ProfileError(
          'فشل جلب بيانات الحساب، تأكد من اتصالك بالإنترنت'));
    }
  }
}
