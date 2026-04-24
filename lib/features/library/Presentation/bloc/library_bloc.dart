import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/download_service.dart';
import 'library_event.dart';
import 'library_state.dart';
import '../../domain/usecases/add_to_library_usecase.dart';
import '../../domain/repositories/library_repository.dart';
import '../../data/models/library_book_model.dart'; // نحتاج الموديل لإنشاء كائن Hive

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;
  final AddToLibraryUseCase addToLibraryUseCase;
  final DownloadService downloadService; // إضافة الخدمة هنا

  LibraryBloc({
    required this.repository,
    required this.addToLibraryUseCase,
    required this.downloadService,
  }) : super(LibraryInitial()) {
    // 1. حدث تحميل الكتب المحملة
    on<LoadLibraryBooks>((event, emit) async {
      emit(LibraryLoading());
      try {
        final books = await repository.getDownloadedBooks();
        emit(LibraryLoaded(books));
      } catch (e) {
        emit(const LibraryError('فشل في تحميل الكتب المحلية'));
      }
    });

    // 2. حدث إضافة كتاب جديد (يدوي)
    on<AddBookToLibrary>((event, emit) async {
      try {
        await addToLibraryUseCase(event.book);
        final updatedBooks = await repository.getDownloadedBooks();
        emit(LibraryLoaded(updatedBooks));
      } catch (e) {
        emit(const LibraryError('حدث خطأ أثناء حفظ الكتاب محلياً'));
      }
    });

    // 3. حدث حذف كتاب من المكتبة
    on<RemoveBookFromLibrary>((event, emit) async {
      try {
        await repository.removeBook(event.bookId);
        final updatedBooks = await repository.getDownloadedBooks();
        emit(LibraryLoaded(updatedBooks));
      } catch (e) {
        emit(const LibraryError('لم نتمكن من حذف الكتاب'));
      }
    });

    // 4. حدث تحميل محتوى الكتاب الشامل (التحديث الجديد)
    on<DownloadBookContent>(_onDownloadBookContent);
  }

  // الدالة التي تعالج منطق التحميل الثلاثي
  Future<void> _onDownloadBookContent(
    DownloadBookContent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      // 1. استدعاء خدمة التحميل لتحميل الملفات الثلاثة (صوت، فيديو، نص)
      final resultPaths = await downloadService.downloadFullPackage(
        bookId: event.book.id,
        audioUrl: event.audioUrl,
        videoUrl: event.videoUrl,
        textUrl: event.textUrl,
      );

      // 2. إنشاء كائن الموديل مع المسارات المحلية التي تم إرجاعها
      final libraryModel = LibraryBookModel(
        id: event.book.id,
        title: event.book.title,
        author: event.book.author,
        coverUrl: event.book.coverUrl,
        addedAt: DateTime.now(),
        localAudioPath: resultPaths['audio'],
        localVideoPath: resultPaths['video'],
        localTextPath: resultPaths['text'],
      );

      // 3. حفظ الموديل في Hive عبر المستودع
      // ملاحظة: تأكد أن repository لديه دالة addBook تقبل LibraryBookModel
      await repository.addBook(libraryModel);

      // 4. تحديث القائمة في الواجهة لإظهار الكتاب فوراً
      final updatedBooks = await repository.getDownloadedBooks();
      emit(LibraryLoaded(updatedBooks));
    } catch (e) {
      emit(LibraryError('فشل تحميل محتوى الكتاب: $e'));
    }
  }
}
