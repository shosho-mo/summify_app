import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../../domain/entities/library_book.dart';

class DownloadButton extends StatelessWidget {
  final LibraryBook book;
  final bool isDownloading;
  final double progress;
  final VoidCallback
      onStartDownload; // الدالة التي تستدعي FlutterDownloader.enqueue

  const DownloadButton({
    super.key,
    required this.book,
    required this.isDownloading,
    required this.progress,
    required this.onStartDownload,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isDownloading) {
          // 1. بدء التحميل الفيزيائي للملف
          onStartDownload();

          // 2. إرسال حدث للـ Bloc لإضافة الكتاب لقاعدة بيانات المكتبة فوراً
          context.read<LibraryBloc>().add(AddBookToLibrary(book));

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('بدأ التحميل.. ستجد الكتاب في مكتبتك')));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDownloading
              ? const Color(0xFFFACC15).withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDownloading ? const Color(0xFFFACC15) : Colors.white24,
            width: 1,
          ),
        ),
        child: isDownloading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  color: const Color(0xFFFACC15),
                  backgroundColor: Colors.white10,
                ),
              )
            : const Icon(
                Icons.cloud_download_outlined,
                color: Colors.white,
                size: 20,
              ),
      ),
    );
  }
}
