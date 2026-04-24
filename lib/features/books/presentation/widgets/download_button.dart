import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// استخدمي المسار الكامل دائماً لتجنب تضارب الأنواع
import 'package:summify/features/library/domain/entities/library_book.dart';
import 'package:summify/features/library/presentation/bloc/library_bloc.dart';
import 'package:summify/features/library/presentation/bloc/library_event.dart';
import 'package:summify/features/library/presentation/bloc/library_state.dart';

class DownloadButton extends StatelessWidget {
  final LibraryBook book;
  final String audioUrl;
  final String videoUrl;
  final String textUrl;

  const DownloadButton({
    super.key,
    required this.book,
    required this.audioUrl,
    required this.videoUrl,
    required this.textUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        bool isDownloaded = false;

        if (state is LibraryLoaded) {
          isDownloaded = state.books.any((b) => b.id == book.id);
        }

        if (isDownloaded) {
          return Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 21, 185, 250).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 18,
              color: Color.fromARGB(255, 21, 166, 250),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            context.read<LibraryBloc>().add(
                  DownloadBookContent(
                    book: book,
                    audioUrl: audioUrl,
                    videoUrl: videoUrl,
                    textUrl: textUrl,
                  ),
                );
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.download_for_offline_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
