import 'package:flutter/material.dart';

// 1. ضعي التعريفات هنا (خارج الكلاس)
class CategoryModel {
  final String title;
  final IconData icon;
  final Color color;
  CategoryModel({required this.title, required this.icon, required this.color});
}

final List<CategoryModel> categories = [
  CategoryModel(
      title: 'علم النفس', icon: Icons.psychology, color: Colors.purpleAccent),
  CategoryModel(
      title: 'ريادة الأعمال',
      icon: Icons.business_center,
      color: Colors.blueAccent),
  CategoryModel(
      title: 'التكنولوجيا', icon: Icons.computer, color: Colors.cyanAccent),
  CategoryModel(
      title: 'الذكاءالأصطناعى',
      icon: Icons.memory,
      color: const Color.fromARGB(255, 62, 1, 160)),
  CategoryModel(
      title: 'تطوير الذات',
      icon: Icons.auto_awesome,
      color: Colors.orangeAccent),
  CategoryModel(
      title: 'مال واستثمار',
      icon: Icons.attach_money,
      color: const Color.fromARGB(255, 3, 104, 17)),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ... (الأجزاء السابقة مثل Header و SearchBar)

            // 2. استدعاء قسم التصنيفات هنا
            SliverToBoxAdapter(
              child: _buildCategories(),
            ),

            // ... (بقية السكاشن)
          ],
        ),
      ),
    );
  }

  // 3. الصقي الدالة الاحترافية هنا كجزء من الكلاس
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            '',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cat.color.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
