import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/safe_api_caller.dart';

class OpenAIService with SafeApiCaller {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> enhancePrompt(String userPrompt,
      {String languageCode = 'en'}) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in environment variables');
    }

    final isArabic = languageCode == 'ar';

    final systemPrompt = isArabic
        ? '''أنت مهندس محترف في تصميم النصوص (Prompts) لتطبيق توليد الفيديو بالذكاء الاصطناعي يسمى Aqvioo.
مهمتك هي تحسين نصوص المستخدم لإنشاء نصوص أفضل وأكثر تفصيلاً لتوليد الفيديو.

الإرشادات:
- حافظ على الفكرة الأساسية لنص المستخدم
- أضف تفاصيل سينمائية (زوايا الكاميرا، الإضاءة، المزاج)
- قم بتضمين وصف للأسلوب البصري (واقعي، رسوم متحركة، فني)
- حدد تفاصيل الحركة والأكشن
- أضف عناصر جوية (وقت من اليوم، الطقس، البيئة)
- كن موجزاً وواضحاً (2-3 جمل كحد أقصى)
- اجعل النص احترافياً وجاهزاً للإنتاج
- ركز على العناصر المرئية التي تعمل بشكل جيد في الفيديو
- رد باللغة العربية حصراً

مثال:
المستخدم: "قطة تلعب بالكرة"
محسن: "قطة برتقالية منفوشة تلعب بمرح بكرة صوف حمراء على أرضية خشبية مشمسة، بلقطة من زاوية منخفضة ديناميكية تتبع حركة الكرة. ضوء الظهيرة الدافئ يتدفق عبر النوافذ القريبة، مما يخلق ظلالاً ناعمة ويبرز شوارب القطة بحركة بطيئة."

الآن قم بتحسين هذا النص:'''
        : '''You are a professional video prompt engineer for an AI video generation app called Aqvioo.
Your task is to enhance user prompts to create better, more detailed prompts for AI video generation.

Guidelines:
- Keep the core idea of the user's prompt
- Add cinematic details (camera angles, lighting, mood)
- Include visual style descriptions (realistic, animated, artistic style)
- Specify movement and action details
- Add atmospheric elements (time of day, weather, environment)
- Keep it concise but vivid (2-3 sentences max)
- Make it professional and production-ready
- Focus on visual elements that work well in video
- Respond in English only

Example:
User: "A cat playing with a ball"
Enhanced: "A fluffy orange tabby cat playfully batting a red yarn ball across a sunlit hardwood floor, shot with a dynamic low-angle camera that follows the ball's movement. Warm afternoon light streams through nearby windows, creating soft shadows and highlighting the cat's whiskers in slow motion."

Now enhance this prompt:''';

    try {
      final response = await safeApiCall(() => http.post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'system',
                  'content': systemPrompt,
                },
                {
                  'role': 'user',
                  'content': userPrompt,
                },
              ],
              'temperature': 0.8,
              'max_tokens': 200,
            }),
          ));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final enhancedPrompt =
            data['choices'][0]['message']['content'] as String;
        return enhancedPrompt.trim();
      } else {
        // SafeApiCall handles 429, 500, etc. This catches other non-200s
        final errorData = jsonDecode(response.body);
        throw ApiException(
            'OpenAI API Error: ${errorData['error']['message'] ?? 'Unknown error'}',
            statusCode: response.statusCode);
      }
    } catch (e) {
      // Re-throw localized/friendly error message
      throw Exception(getUserFriendlyError(e));
    }
  }
}
