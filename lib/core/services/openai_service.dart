import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'remote_config_service.dart';
import '../utils/safe_api_caller.dart';

class OpenAIService with SafeApiCaller {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => RemoteConfigService().openaiApiKey;

  Future<String> enhancePrompt(String userPrompt,
      {String languageCode = 'en', File? imageFile}) async {
    if (_apiKey.isEmpty) {
      throw ApiException(
          'Prompt enhancement is temporarily unavailable. Please try again later.');
    }

    final isArabic = languageCode == 'ar';
    final hasImage = imageFile != null && await imageFile.exists();

    final systemPrompt = isArabic
        ? '''أنت مهندس محترف في تصميم النصوص (Prompts) لتطبيق توليد الفيديو بالذكاء الاصطناعي يسمى Aqvioo.
مهمتك هي تحسين نصوص المستخدم لإنشاء نصوص أفضل وأكثر تفصيلاً لتوليد الفيديو.

الإرشادات:
- حافظ على الفكرة الأساسية لنص المستخدم${hasImage ? '\n- حلل الصورة المرفقة واستخدم تفاصيلها لتحسين النص (الألوان، الأشياء، المشهد، الأسلوب)\n- ادمج العناصر المرئية من الصورة مع نص المستخدم' : ''}
- أضف تفاصيل سينمائية (زوايا الكاميرا، الإضاءة، المزاج)
- قم بتضمين وصف للأسلوب البصري (واقعي، رسوم متحركة، فني)
- حدد تفاصيل الحركة والأكشن
- أضف عناصر جوية (وقت من اليوم، الطقس، البيئة)
- كن موجزاً وواضحاً (2-3 جمل كحد أقصى)
- اجعل النص احترافياً وجاهزاً للإنتاج
- ركز على العناصر المرئية التي تعمل بشكل جيد في الفيديو
- رد باللغة العربية حصراً

الآن قم بتحسين هذا النص:'''
        : '''You are a professional video prompt engineer for an AI video generation app called Aqvioo.
Your task is to enhance user prompts to create better, more detailed prompts for AI video generation.

Guidelines:
- Keep the core idea of the user's prompt${hasImage ? '\n- Analyze the attached image and use its details to enhance the prompt (colors, objects, scene, style)\n- Blend the visual elements from the image with the user\'s text prompt' : ''}
- Add cinematic details (camera angles, lighting, mood)
- Include visual style descriptions (realistic, animated, artistic style)
- Specify movement and action details
- Add atmospheric elements (time of day, weather, environment)
- Keep it concise but vivid (2-3 sentences max)
- Make it professional and production-ready
- Focus on visual elements that work well in video
- Respond in English only

Now enhance this prompt:''';

    // Build user message content
    final List<Map<String, dynamic>> userContent = [];

    if (hasImage) {
      // GPT-4o vision: include image as base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      userContent.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:$mimeType;base64,$base64Image',
          'detail': 'low',
        },
      });
    }

    userContent.add({
      'type': 'text',
      'text': userPrompt.isEmpty && hasImage
          ? 'Describe this image and create a cinematic video prompt based on it.'
          : userPrompt,
    });

    try {
      final response = await safeApiCall(
        () => http.post(
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
                'content': hasImage ? userContent : userPrompt,
              },
            ],
            'temperature': 0.8,
            'max_tokens': 200,
          }),
        ),
        serviceName: 'OpenAI',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final enhancedPrompt =
            data['choices'][0]['message']['content'] as String;
        return enhancedPrompt.trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
            'OpenAI API Error: ${errorData['error']['message'] ?? 'Unknown error'}',
            statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(getUserFriendlyError(e));
    }
  }

  Future<String> generateScript(String prompt) async {
    // Using the same structure as enhancePrompt but with a script generation persona
    return enhancePrompt(
        prompt); // Re-using for now to unblock, or implement distinct prompt
  }
}

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});
