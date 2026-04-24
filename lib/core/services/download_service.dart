import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'
    show kIsWeb; // الاستيراد المطلوب للتحقق من الويب

class DownloadService {
  final Dio _dio = Dio();

  /// الدالة الرئيسية لتحميل الملفات الثلاثة مع دعم الويب والموبايل
  Future<Map<String, String?>> downloadFullPackage({
    required String bookId,
    required String audioUrl,
    required String videoUrl,
    required String textUrl,
  }) async {
    try {
      // 1. التحقق إذا كان التطبيق يعمل على المتصفح (Chrome/Edge)
      if (kIsWeb) {
        print('Summify Web: يتم استخدام الروابط المباشرة (محاكاة التحميل)');
        return {
          'audio':
              audioUrl, // في الويب نستخدم الرابط مباشرة لأن الـ File System غير مدعوم بنفس الطريقة
          'video': videoUrl,
          'text': textUrl,
        };
      }

      // 2. الكود الخاص بالموبايل (Android / iOS)
      // تحديد المسار الرئيسي للتخزين
      final directory = await getApplicationDocumentsDirectory();
      final bookFolderPath = p.join(directory.path, 'books', bookId);

      // إنشاء المجلد إذا لم يكن موجوداً
      final bookFolder = Directory(bookFolderPath);
      if (!await bookFolder.exists()) {
        await bookFolder.create(recursive: true);
      }

      // تحديد مسارات الحفظ المحلية للملفات
      final String audioSavePath = p.join(bookFolderPath, 'audio.mp3');
      final String videoSavePath = p.join(bookFolderPath, 'video.mp4');
      final String textSavePath = p.join(bookFolderPath, 'summary.pdf');

      // تنفيذ التحميل الفعلي للملفات الثلاثة
      String? localAudio = await _downloadFile(audioUrl, audioSavePath);
      String? localVideo = await _downloadFile(videoUrl, videoSavePath);
      String? localText = await _downloadFile(textUrl, textSavePath);

      return {
        'audio': localAudio,
        'video': localVideo,
        'text': localText,
      };
    } catch (e) {
      print('Main Download Error: $e');
      throw Exception('فشل في معالجة حزمة الكتاب: $e');
    }
  }

  /// دالة مساعدة للتحميل الفعلي (تُستخدم في الموبايل فقط)
  Future<String?> _downloadFile(String url, String savePath) async {
    try {
      if (url.isEmpty) return null;

      final file = File(savePath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // يمكن إضافة Logic لعرض النسبة المئوية هنا لاحقاً
          }
        },
      );

      return savePath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
}
