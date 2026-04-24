import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Core Services ---
import 'core/services/download_service.dart';
// تم حذف ChatGeminiService لأنه لم يعد مطلوباً

// --- Auth Features ---
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// --- Books Features ---
import 'features/books/data/datasources/book_remote_data_source.dart';
import 'features/books/data/repositories/book_repository_impl.dart';
import 'features/books/domain/repositories/book_repository.dart';
import 'features/books/domain/usecases/get_all_books.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/cubits/book_search_cubit.dart';

// --- Library Features ---
import 'features/library/data/datasources/library_local_data_source.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/domain/usecases/add_to_library_usecase.dart';
import 'features/library/presentation/bloc/library_bloc.dart';

// --- Profile Features ---
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// --- Chatbot Feature (Clean Architecture) ---
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/presentation/manager/chat_cubit.dart';

// تعريف الـ Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //! 1. External & Core Services
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => DownloadService());

  // =========================================================================
  // --- Auth Feature ---
  // =========================================================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(loginUseCase: sl(), registerUseCase: sl()),
  );

  // =========================================================================
  // --- Books Feature ---
  // =========================================================================
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAllBooks(sl()));
  sl.registerFactory(() => BookBloc(getAllBooks: sl()));
  sl.registerFactory(() => BookSearchCubit(sl()));

  // =========================================================================
  // --- Library Feature ---
  // =========================================================================
  sl.registerLazySingleton<LibraryLocalDataSource>(
    () => LibraryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => AddToLibraryUseCase(sl()));
  sl.registerFactory(
    () => LibraryBloc(
      repository: sl(),
      addToLibraryUseCase: sl(),
      downloadService: sl(),
    ),
  );

  // =========================================================================
  // --- Profile Feature ---
  // =========================================================================
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerFactory(
    () => ProfileBloc(getUserProfile: sl()),
  );

  // =========================================================================
  // --- Chatbot Feature (Updated to Groq API) ---
  // =========================================================================

  // 1. Data Source
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
        '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'),
  );

  // 2. Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // 3. Use Case
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // 4. Presentation (Cubit)
  sl.registerFactory(() => ChatCubit(sl()));
}
