import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:summify/injection_container.dart' as di;

// استيرادات المشروع
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

// تعريف المفاتيح في مستوى أعلى (Global) ليقرأها التطبيق أثناء البناء
const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
    // 1. تهيئة Hive
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LibraryBookAdapter());
    }

    // 2. تهيئة سوبابيز باستخدام القيم الممررة من GitHub Actions
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // 3. تهيئة محرك التحميل
    if (!kIsWeb) {
      await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
      FlutterDownloader.registerCallback(downloadCallback);
    }

    // 4. تهيئة حقن الاعتماديات
    await di.init();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<AuthBloc>()),
          BlocProvider(
              create: (_) => di.sl<BookBloc>()..add(FetchAllBooksEvent())),
          BlocProvider(create: (_) => di.sl<BookSearchCubit>()),
          BlocProvider(create: (_) => di.sl<LibraryBloc>()),
          BlocProvider(create: (_) => di.sl<ProfileBloc>()),
          BlocProvider(create: (_) => di.sl<ChatCubit>()),
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
