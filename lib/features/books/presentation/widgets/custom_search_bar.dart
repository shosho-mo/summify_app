import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/book_search_cubit.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  // المتغير الذي يحدد نوع البحث الذكي
  String _searchType = 'Title';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        context.read<BookSearchCubit>().clearSearch();
      } else {
        // نرسل الـ query مع الـ searchType للـ Cubit ليكون البحث أدق
        context.read<BookSearchCubit>().searchBooks(query, type: _searchType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: const Color(0xFFFACC15),
              decoration: InputDecoration(
                // النص يتغير ديناميكياً حسب نوع البحث المختار
                hintText: 'Search by $_searchType...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFFACC15), size: 24),

                // الجزء الأيمن (الذكاء الإضافي)
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showClearButton)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54, size: 20),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      ),

                    // زر الخيارات المتقدمة (Tune Icon)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.tune_rounded,
                          color: Color(0xFFFACC15), size: 22),
                      offset: const Offset(0, 50),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onSelected: (String value) {
                        setState(() {
                          _searchType = value; // تغيير نوع البحث
                        });
                        // إعادة البحث فوراً إذا كان هناك نص مكتوب
                        if (_controller.text.isNotEmpty) {
                          _onSearchChanged(_controller.text);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        _buildPopupItem('Title', Icons.title_rounded),
                        _buildPopupItem('Author', Icons.person_rounded),
                        _buildPopupItem('Category', Icons.category_rounded),
                      ],
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              color: _searchType == value
                  ? const Color(0xFFFACC15)
                  : Colors.white70,
              size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color:
                  _searchType == value ? const Color(0xFFFACC15) : Colors.white,
              fontWeight:
                  _searchType == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
