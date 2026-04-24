import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  // تأكدي أن الاسم هنا getChatResponse كما يطلب الخطأ
  Future<ChatMessage> getChatResponse(String text) async {
    try {
      // مناداة الـ DataSource
      return await remoteDataSource.fetchAIResponse(text);
    } catch (e) {
      throw Exception('خطأ في المستودع: $e');
    }
  }
}
