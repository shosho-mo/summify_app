import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:summify/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

// استيرادات المشروع
import 'package:summify/injection_container.dart' as di;
import 'core/utils/constants.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/bloc/book_event.dart';
import 'features/books/presentation/cubits/book_search_cubit.dart';
import 'features/books/presentation/screens/main_wrapper.dart';
import 'features/chat/presentation/manager/chat_cubit.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/library/presentation/screens/library_screen.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'package:summify/features/library/presentation/bloc/library_bloc.dart';
import 'package:summify/features/library/data/models/library_book_model.dart';
// 2. أضف هذا السطر
// 1. أضف هذا السطر

/// دالة الـ Callback الخاصة بالتحميل
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  try {
    WidgetsFlutterBinding.ensureInitialized();
    // 1. تحميل الإعدادات من ملف الـ .env
    await dotenv.load(fileName: '.env');

    // 2. تهيئة Hive لقاعدة البيانات المحلية
    await Hive.initFlutter();

    // 3. تسجيل الـ Adapter الخاص بمكتبة الكتب
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LibraryBookAdapter());
    }

    // 4. تهيئة سوبابيز (Supabase)
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );

    // 5. تهيئة محرك التحميل (Flutter Downloader)
    if (!kIsWeb) {
      await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
      FlutterDownloader.registerCallback(downloadCallback);
    }

    // 6. تهيئة حقن الاعتماديات (Dependency Injection)
    await di.init();

    // تشغيل التطبيق مع توفير الـ Blocs على مستوى التطبيق بالكامل
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<AuthBloc>()),
          BlocProvider(
            create: (_) => di.sl<BookBloc>()..add(FetchAllBooksEvent()),
          ),
          BlocProvider(create: (_) => di.sl<BookSearchCubit>()),
          BlocProvider(create: (_) => di.sl<LibraryBloc>()),
          // تم إضافة ProfileBloc هنا بشكل صحيح ومنظم
          BlocProvider(create: (_) => di.sl<ProfileBloc>()),
          BlocProvider(
            create: (context) =>
                sl<ChatCubit>(), // sl هو الـ Service Locator (GetIt)
            child: const ChatPage(),
          ),
        ],
        child: const SummifyApp(),
      ),
    );
  } catch (e) {
    debugPrint('CRITICAL INITIALIZATION ERROR: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('حدث خطأ أثناء التشغيل: $e')),
      ),
    ));
  }
}

class SummifyApp extends StatelessWidget {
  const SummifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Summify',
      theme: _buildThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainWrapper(),
        '/library': (context) => const LibraryScreen(),
      },
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      primaryColor: const Color(0xFFFACC15),
      fontFamily: 'Poppins',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
