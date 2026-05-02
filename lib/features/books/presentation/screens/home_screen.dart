import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:summify/features/library/presentation/bloc/library_bloc.dart';
import 'package:summify/features/library/presentation/bloc/library_event.dart';
import 'package:summify/features/library/presentation/bloc/library_state.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/category_item.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_state.dart';
import '../bloc/book_event.dart';
import '../cubits/book_search_cubit.dart';
import '../cubits/book_search_state.dart';

import '../widgets/custom_search_bar.dart';
import '../widgets/featured_book_card.dart';
import '../widgets/custom_header.dart';

// تأكد من استيراد ويدجت الخلفية إذا كان في ملف خارجي
// import '../widgets/full_page_bubble_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BookBloc>().add(FetchAllBooksEvent());
    context.read<LibraryBloc>().add(const LoadLibraryBooks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state is LibraryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // الفقاعات تظل تسبح في الخلفية حتى عند انقطاع الإنترنت
            const Positioned.fill(
              child: FullPageBubbleBackground(
                numberOfBubbles: 80,
                maxBubbleSize: 6.0,
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: ProfessionalBookHeader()),
                  const SliverToBoxAdapter(child: CustomSearchBar()),
                  BlocBuilder<BookSearchCubit, BookSearchState>(
                    builder: (context, searchState) {
                      if (searchState is BookSearchLoading) {
                        return const SliverFillRemaining(
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFACC15))),
                        );
                      } else if (searchState is BookSearchLoaded) {
                        return _buildSearchResults(searchState.books);
                      }
                      return _buildDefaultHomeContent();
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHomeContent() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const SliverToBoxAdapter(
            child: SizedBox(
                height: 200,
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFFACC15)))),
          );
        }
        // معالجة حالة الخطأ (انقطاع الإنترنت)
        else if (state is BookError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildNoInternetWidget(context),
          );
        } else if (state is BookLoaded) {
          return SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: _buildSectionHeaderWithToggle(
                  'Top Summaries',
                  onTap: () => setState(() => isGridView = !isGridView),
                ),
              ),
              if (isGridView)
                _buildGridContent(state.books)
              else
                _buildHorizontalListContent(state.books),
              SliverToBoxAdapter(child: _buildCategories()),
            ],
          );
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildNoInternetWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFACC15).withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFACC15).withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: Color(0xFFFACC15),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'عفواً.. انقطع اتصالك بالإنترنت',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // fontFamily: 'Cairo', // فعلها إذا كان الخط مدمجاً
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'يرجى التحقق من الشبكة للمتابعة  Summify',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _loadData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent(List<Book> books) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              FeaturedBookCard(book: books[index], isGrid: true),
          childCount: books.length,
        ),
      ),
    );
  }

  Widget _buildHorizontalListContent(List<Book> books) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: books.length,
          itemBuilder: (context, index) =>
              FeaturedBookCard(book: books[index], isGrid: false),
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWithToggle(String title,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          IconButton(
            onPressed: onTap,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGridView
                    ? Icons.view_carousel_rounded
                    : Icons.grid_view_rounded,
                color: const Color(0xFFFACC15),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Book> books) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              FeaturedBookCard(book: books[index], isGrid: true),
          childCount: books.length,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(25, 35, 20, 15),
          child: Text('Explore Categories',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, color: cat.color, size: 30),
                    const SizedBox(height: 10),
                    Text(cat.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
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
