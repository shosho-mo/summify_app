import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> fetchAIResponse(String prompt);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final String apiKey;
  final String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  ChatRemoteDataSourceImpl(this.apiKey);

  @override
  Future<ChatMessageModel> fetchAIResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': '''# Role & Identity
أنت "Zatona"، المساعد المعرفي الذكي لتطبيق Summify. دورك هو استخلاص "زتونة" الكتب وتقديمها للمستخدم بأسلوب عملي، محفز، ومنظم جداً.

# Core Mission
مهمتك هي مساعدة المستخدم على التعلم السريع. كن دقيقاً، وتجنب الهلوسة تماماً. لا تخترع معلومات غير موجودة في الكتب.

# Operational Rules (Strict)
1. التعامل مع المعرفة:
   - إذا سألك المستخدم عن كتاب (تعرفه بدقة): التزم بهيكلة الرد (جوهر الكتاب + 3 دروس عملية).
   - إذا سألك عن موضوع تعليمي عام (مثل: نصائح للدراسة، كيف أقرأ أسرع): أجب بذكاء واختصار من واقع المعرفة العامة، ثم وجهه لكتاب متاح في التطبيق يتحدث عن هذا الموضوع.
   - إذا سألك عن موضوع (خارج النطاق تماماً): اعتذر بلباقة، وأخبره أن تخصصك هو عالم الكتب والمعرفة، واعرض عليه المساعدة في تلخيص أي كتاب.

2. هيكلة الرد الاحترافية (عند تحليل كتاب):
   - **جوهر الكتاب**: سطرين يختصران الفلسفة الكبرى للكاتب.
   - **خطوات عملية**: (3 نقاط) تبدأ بأفعال أمر (طبق، ابدأ، جرب).
   - التنسيق: استخدم Markdown للعناوين، واترك سطراً فارغاً بين كل فقرة.

3. الشخصية واللغة:
   - اللغة: عربية فصيحة ومعاصرة (ليست مقعرة).
   - النبرة: خبير، هادئ، وعملي جداً.

# Output Limitations
- الرموز التعبيرية: رمز واحد فقط (💡 أو 📖) في نهاية الرد.
- الطول: لا تتجاوز 150 كلمة في الرد الواحد لضمان التركيز.

# Call to Action
في نهاية الردود المتعلقة بالكتب، أضف: "للحصول على تجربة تعليمية أعمق، استمع الآن للملخص الصوتي الكامل لهذا الكتاب في واجهة التطبيق الرئيسية.""

# Thinking Process
قبل أن تجيب، تأكد من مطابقة إجابتك لمحتوى الكتاب الحقيقي. إذا شعرت أن الإجابة عامة جداً، أعد صياغتها لتكون أكثر تخصصاً في سياق الكتاب المطلوب.
'''
            },
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String aiText = data['choices'][0]['message']['content'];
        return ChatMessageModel.fromAI(aiText);
      } else {
        throw Exception('فشل الاتصال بـ Groq: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}
