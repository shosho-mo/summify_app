import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks();
  Future<List<BookModel>> searchBooks(String query);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final SupabaseClient client;

  BookRemoteDataSourceImpl(this.client);

  @override
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await client.from('books').select('''
            *,
            authors (full_name),
            categories (name),
            summaries (content, reading_time, audio_url, video_url)
          ''');

      return (response as List)
          .map((book) => BookModel.fromJson(book))
          .toList();
    } catch (e) {
      print('Supabase Fetch Error: $e');
      throw Exception('Failed to fetch books: $e');
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final cleanQuery = query.trim();
      if (cleanQuery.isEmpty) return [];

      final List<dynamic> response = await client.rpc(
        'search_books_complex',
        params: {'search_text': cleanQuery},
      );

      // تحويل البيانات المستلمة إلى BookModel
      return response.map((bookJson) => BookModel.fromJson(bookJson)).toList();
    } catch (e) {
      print('Professional Search Error: $e');
      throw Exception('فشل البحث: $e');
    }
  }
}
