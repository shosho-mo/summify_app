import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:summify/features/profile/domain/entities/user_entity.dart'
    show UserEntity;
import '../../domain/repositories/profile_repository.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient supabase;

  ProfileRepositoryImpl(this.supabase);

  @override
  Future<UserEntity> getUserProfile() async {
    try {
      final user = supabase.auth.currentUser;

      // 1. التحقق من وجود جلسة دخول
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // 2. جلب البيانات من جدول profiles
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 3. معالجة حالة عدم وجود سجل للمستخدم
      if (response == null) {
        return UserModel(
          id: user.id,
          name: 'مستخدم جديد',
          email: user.email ?? '',
          booksRead: 0,
          avatarUrl: null, // تأكدي من إضافة الحقول الاختيارية
        );
      }

      // 4. تحويل البيانات بنجاح
      return UserModel.fromJson(response, user.email ?? '');
    } catch (e) {
      // طباعة الخطأ في الـ Console لمعرفة السبب (RLS, Table name, etc.)
      print('Error in ProfileRepository: $e');
      throw Exception('فشل جلب بيانات الحساب: $e');
    }
  }
}
