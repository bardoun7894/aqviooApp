import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/creation/domain/models/creation_config.dart';

class KieAIService {
  final String _apiKey;
  final String _baseUrl = 'https://api.kie.ai';

  KieAIService({required String apiKey}) : _apiKey = apiKey;

  // ==================== TEXT GENERATION (GPT for prompt enhancement) ====================

  /// Enhances a user prompt based on the selected video style
  Future<String> enhancePrompt({
    required String originalPrompt,
    required VideoStyle style,
  }) async {
    try {
      final styleModifier = style.promptModifier;
      final enhancedPrompt = '$styleModifier: $originalPrompt';

      // TODO: If you want to use Kie AI's text generation API for enhancement, uncomment below
      // final response = await http.post(...);

      return enhancedPrompt;
    } catch (e) {
      debugPrint('Error enhancing prompt: $e');
      return originalPrompt; // Fallback to original
    }
  }

  // ==================== SORA 2 API (Text-to-Video) ====================

  /// Generate video using Sora 2 (text-to-video only, no image input)
  Future<String> generateVideoWithSora2({
    required String prompt,
    required String aspectRatio, // "landscape" or "portrait"
    required String nFrames, // "10" or "15"
    bool removeWatermark = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/jobs/createTask'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'sora-2-text-to-video',
          'input': {
            'prompt': prompt,
            'aspect_ratio': aspectRatio,
            'n_frames': nFrames,
            'remove_watermark': removeWatermark,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return data['data']['taskId'];
        } else {
          throw Exception('Sora 2 API error: ${data['msg']}');
        }
      } else {
        throw Exception(
            'Sora 2 HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error generating video with Sora 2: $e');
      rethrow;
    }
  }

  // ==================== VEO3 API (Image-to-Video) ====================

  /// Generate video using Veo3 (supports image-to-video)
  /// NOTE: Currently disabled - requires cloud storage for image URLs
  Future<String> generateVideoWithVeo3({
    required String prompt,
    List<String>? imageUrls, // 1 or 2 images
    String model = 'veo3_fast', // or 'veo3' for quality
    String aspectRatio = '16:9', // or '9:16' or 'Auto'
    int? seeds,
    bool enableTranslation = true,
  }) async {
    try {
      final requestBody = {
        'prompt': prompt,
        'model': model,
        'aspectRatio': aspectRatio,
        'enableTranslation': enableTranslation,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (seeds != null) 'seeds': seeds,
      };

      // Determine generation type based on image count
      if (imageUrls != null && imageUrls.isNotEmpty) {
        if (imageUrls.length == 1) {
          requestBody['generationType'] = 'FIRST_AND_LAST_FRAMES_2_VIDEO';
        } else if (imageUrls.length == 2) {
          requestBody['generationType'] = 'FIRST_AND_LAST_FRAMES_2_VIDEO';
        } else if (imageUrls.length <= 3) {
          requestBody['generationType'] = 'REFERENCE_2_VIDEO';
        }
      } else {
        requestBody['generationType'] = 'TEXT_2_VIDEO';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/veo/generate'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return data['data']['taskId'];
        } else {
          throw Exception('Veo3 API error: ${data['msg']}');
        }
      } else {
        throw Exception(
            'Veo3 HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error generating video with Veo3: $e');
      rethrow;
    }
  }

  // ==================== TASK STATUS POLLING ====================

  /// Check the status of a Sora 2 task
  Future<Map<String, dynamic>> checkSora2TaskStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/jobs/recordInfo?taskId=$taskId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final state = taskData['state']; // waiting, success, fail

          if (state == 'success') {
            final resultJson = jsonDecode(taskData['resultJson']);
            return {
              'state': 'success',
              'videoUrl': resultJson['resultUrls'][0],
            };
          } else if (state == 'fail') {
            return {
              'state': 'fail',
              'error': taskData['failMsg'],
            };
          } else {
            return {
              'state': 'waiting',
            };
          }
        } else {
          throw Exception('Status check error: ${data['msg']}');
        }
      } else {
        throw Exception('Status check HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking Sora 2 task status: $e');
      rethrow;
    }
  }

  /// Check the status of a Veo3 task
  Future<Map<String, dynamic>> checkVeo3TaskStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/jobs/recordInfo?taskId=$taskId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final state = taskData['state'];

          if (state == 'success') {
            final resultJson = jsonDecode(taskData['resultJson']);
            return {
              'state': 'success',
              'videoUrl': resultJson['resultUrls'][0],
            };
          } else if (state == 'fail') {
            return {
              'state': 'fail',
              'error': taskData['failMsg'],
            };
          } else {
            return {
              'state': 'waiting',
            };
          }
        } else {
          throw Exception('Status check error: ${data['msg']}');
        }
      } else {
        throw Exception('Status check HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking Veo3 task status: $e');
      rethrow;
    }
  }

  // ==================== IMAGE GENERATION (Nano Banana Pro) ====================

  /// Generate image using Nano Banana Pro
  Future<String> generateImage({
    required String prompt,
    String style = 'realistic', // realistic, cartoon, artistic
    String size = '1024x1024', // 1024x1024, 1920x1080, 1080x1920
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/nano-banana/generate'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'style': style,
          'size': size,
          'format': 'jpg',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['imageUrl'];
        } else {
          throw Exception('Nano Banana error: ${data['message']}');
        }
      } else {
        throw Exception('Nano Banana HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating image: $e');
      rethrow;
    }
  }

  // ==================== HELPER: Image Upload (Future Feature) ====================

  /// Upload image to cloud storage (for Veo3 image-to-video)
  ///
  /// NOTE: Image-to-video (Veo3) requires accessible image URLs.
  /// Kie AI stores generated content on their servers for 2 months.
  /// We just download those URLs to phone for local viewing.
  ///
  /// For future: Add cloud storage (Firebase/AWS/etc) to enable image-to-video.
  Future<String> uploadImageToStorage(File imageFile) async {
    // Image-to-video feature disabled for MVP
    // Can be enabled later by adding cloud storage
    throw UnimplementedError(
        'Image-to-video requires cloud storage for uploading input images. '
        'This feature will be available in a future update. '
        'For now, use text-only prompts or generate static images.');
  }

  // ==================== ERROR HANDLING ====================

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String technicalError) {
    if (technicalError.contains('401') ||
        technicalError.contains('Unauthorized')) {
      return 'Invalid API key. Please check your configuration.';
    } else if (technicalError.contains('402') ||
        technicalError.contains('Insufficient')) {
      return 'Insufficient credits. Please top up your account.';
    } else if (technicalError.contains('422') ||
        technicalError.contains('Validation')) {
      return 'Invalid request. Please check your settings.';
    } else if (technicalError.contains('429') ||
        technicalError.contains('Rate')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (technicalError.contains('Network') ||
        technicalError.contains('Connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (technicalError.contains('timeout')) {
      return 'Request timed out. The server is taking too long to respond.';
    } else if (technicalError.contains('Your prompt was flagged')) {
      return 'Your prompt contains inappropriate content. Please modify it.';
    }

    // Default message
    return 'Something went wrong. Please try again later.';
  }

  // ==================== UNIFIED GENERATION METHOD ====================

  /// Main method to generate content based on CreationConfig
  /// Automatically selects Sora 2 or Veo3 based on whether image exists
  Future<Map<String, dynamic>> generateContent({
    required CreationConfig config,
    File? imageFile,
  }) async {
    try {
      // Check connectivity first
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw SocketException('No internet connection');
        }
      } on SocketException catch (_) {
        throw Exception(
            'No internet connection. Please check your Wi-Fi or data.');
      }

      // Step 1: Enhance prompt
      String enhancedPrompt = config.prompt;
      if (config.outputType == OutputType.video && config.videoStyle != null) {
        enhancedPrompt = await enhancePrompt(
          originalPrompt: config.prompt,
          style: config.videoStyle!,
        );
      }

      // Step 2: Generate based on output type
      if (config.outputType == OutputType.video) {
        return await _generateVideoContent(config, enhancedPrompt, imageFile);
      } else {
        return await _generateImageContent(config, enhancedPrompt);
      }
    } catch (e) {
      debugPrint('Error in generateContent: $e');
      throw Exception(_getUserFriendlyError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _generateVideoContent(
    CreationConfig config,
    String enhancedPrompt,
    File? imageFile,
  ) async {
    String taskId;

    // For MVP: Only support text-to-video (Sora 2)
    // Image-to-video (Veo3) requires cloud storage - disabled for now
    if (imageFile == null) {
      // Use Sora 2 for text-only video
      taskId = await generateVideoWithSora2(
        prompt: enhancedPrompt,
        aspectRatio: config.videoAspectRatio ?? 'landscape',
        nFrames: config.videoDurationSeconds?.toString() ?? '10',
        removeWatermark: true,
      );

      // Return taskId immediately for persistence
      return {
        'type': 'video_task',
        'taskId': taskId,
        'status': 'processing',
      };
    } else {
      // Image-to-video is not available yet
      throw UnimplementedError('Image-to-video is coming soon! '
          'For now, please use text-only prompts. '
          'Generated videos will be saved to your phone automatically.');
    }
  }

  Future<Map<String, dynamic>> _generateImageContent(
    CreationConfig config,
    String enhancedPrompt,
  ) async {
    final imageUrl = await generateImage(
      prompt: enhancedPrompt,
      style: config.imageStyle?.name ?? 'realistic',
      size: config.imageSize ?? '1024x1024',
    );

    return {
      'type': 'image',
      'url': imageUrl,
    };
  }

  /// Public method to check status of a task
  Future<Map<String, dynamic>> checkTaskStatus(String taskId) async {
    // Currently only supporting Sora 2 for MVP
    return await checkSora2TaskStatus(taskId);
  }
}

// Provider
final kieAIServiceProvider = Provider<KieAIService>((ref) {
  // Get API key from .env file
  final apiKey = dotenv.env['KIE_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    debugPrint('Warning: KIE_API_KEY not found in .env file');
  }
  return KieAIService(apiKey: apiKey);
});
