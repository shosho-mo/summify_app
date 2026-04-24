import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // جعل البار طافياً فوق الحافة السفلية
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        // تعديل اللون إلى الأسود الغامق الصريح
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.5), // ظل أغمق ليناسب الخلفية السوداء
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          // إطار رقيق جداً بلون ذهبي خفيف أو أبيض شفاف لتمييز الحواف
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.library_books_rounded,
                Icons.library_books_outlined, 'Library'),
            _buildNavItem(2, Icons.chat_bubble_rounded,
                Icons.chat_bubble_outline_rounded, 'Chat'),
            _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded,
                'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = currentIndex == index;
    // اللون الذهبي للعنصر المحدد والأبيض الخافت لغير المحدد
    final color = isSelected ? const Color(0xFFFACC15) : Colors.white38;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // توهج ذهبي خفيف خلف الأيقونة المختارة لكسر حدة الأسود
          color: isSelected
              ? const Color(0xFFFACC15).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
            // النقطة السفلية (Indicator)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 2),
              height: 4,
              width: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: Color(0xFFFACC15),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
