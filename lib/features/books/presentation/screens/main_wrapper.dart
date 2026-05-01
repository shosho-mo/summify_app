import 'package:flutter/material.dart';
import '../../../library/presentation/screens/library_screen.dart';
import 'home_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/pages/chat_page.dart'; // 1. استيراد صفحة المحادثة الجديدة

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // 2. تحديث قائمة الصفحات
  final List<Widget> _pages = [
    const HomeScreen(),
    // صفحة المحادثة الجديدة

    // استبدال النص بصفحة المكتبة التي أنشأناها بالـ Bloc
    const LibraryScreen(),
    const ChatPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      // IndexedStack يضمن عدم إعادة تحميل الكتب عند التنقل
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
