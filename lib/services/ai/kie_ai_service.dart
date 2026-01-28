import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/creation/domain/models/creation_config.dart';

/// Custom exception for Kie AI errors with user-friendly messages
class KieAIException implements Exception {
  final String message;
  final String? technicalDetails;
  final bool isRetryable;

  KieAIException(this.message,
      {this.technicalDetails, this.isRetryable = false});

  @override
  String toString() => message;
}

class KieAIService {
  final String _apiKey;
  final String _baseUrl = 'https://api.kie.ai';

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _pollingTimeout = Duration(
      seconds: 60); // Longer timeout for polling when app may be backgrounded

  // Model Constants
  static const String MODEL_SORA2 = 'sora-2-text-to-video';
  static const String MODEL_KLING = 'kling';
  static const String MODEL_HAILUO = 'hailuo';

  KieAIService({required String apiKey}) : _apiKey = apiKey;

  // ==================== RETRY HELPER ====================

  /// Execute an HTTP request with automatic retry on transient failures
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    int maxRetries = _maxRetries,
    Duration? timeout,
  }) async {
    int attempt = 0;
    Exception? lastException;
    final effectiveTimeout = timeout ?? _requestTimeout;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(effectiveTimeout);
        return response;
      } on SocketException catch (e) {
        lastException = e;
        debugPrint('Network error (attempt ${attempt + 1}/$maxRetries): $e');
      } on TimeoutException catch (e) {
        lastException = e as Exception;
        debugPrint('Timeout (attempt ${attempt + 1}/$maxRetries): $e');
      } on http.ClientException catch (e) {
        lastException = e;
        debugPrint('Client error (attempt ${attempt + 1}/$maxRetries): $e');
      } catch (e) {
        // Non-retryable error, throw immediately
        rethrow;
      }

      attempt++;
      if (attempt < maxRetries) {
        // Exponential backoff
        final delay = _initialRetryDelay * (1 << (attempt - 1));
        debugPrint('Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    // All retries exhausted
    throw KieAIException(
      'Connection failed. Please check your internet and try again.',
      technicalDetails: lastException?.toString(),
      isRetryable: true,
    );
  }

  /// Check internet connectivity
  Future<void> _checkConnectivity() async {
    // Skip connectivity check on web platform as InternetAddress is not available
    if (kIsWeb) return;

    try {
      final result = await InternetAddress.lookup('api.kie.ai')
          .timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw KieAIException(
          'No internet connection. Please check your Wi-Fi or mobile data.',
          isRetryable: true,
        );
      }
    } on SocketException catch (_) {
      throw KieAIException(
        'No internet connection. Please check your Wi-Fi or mobile data.',
        isRetryable: true,
      );
    } on TimeoutException catch (_) {
      throw KieAIException(
        'Network is slow. Please try again.',
        isRetryable: true,
      );
    }
  }

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

  // ==================== VIDEO GENERATION (Sora 2 / Fallback) ====================

  /// Generate video with automatic fallback if primary model is unavailable
  /// Returns a Map with 'taskId' and 'usedModel'
  Future<Map<String, String>> generateVideoWithFallback({
    required String prompt,
    required String aspectRatio,
    required String nFrames,
    bool removeWatermark = true,
  }) async {
    try {
      // Try Sora 2 first
      final taskId = await _generateVideoWithModel(
        model: MODEL_SORA2,
        prompt: prompt,
        aspectRatio: aspectRatio,
        nFrames: nFrames,
        removeWatermark: removeWatermark,
      );
      return {'taskId': taskId, 'usedModel': MODEL_SORA2};
    } catch (e) {
      // Check for specific error indicating unavailability
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('temporarily unavailable') ||
          errorMsg.contains('maintenance') ||
          errorMsg.contains('sora') || // Broad check for Sora issues
          errorMsg.contains('503') ||
          errorMsg.contains('404')) {
        debugPrint(
            '⚠️ Sora 2 unavailable, switching to fallback model: $MODEL_KLING');

        try {
          // Fallback to Kling
          final taskId = await _generateVideoWithModel(
            model: MODEL_KLING,
            prompt: prompt,
            aspectRatio: aspectRatio,
            nFrames: nFrames,
            removeWatermark: removeWatermark,
          );
          return {'taskId': taskId, 'usedModel': MODEL_KLING};
        } catch (fallbackError) {
          debugPrint('❌ Fallback to Kling failed: $fallbackError');
          // If Kling fails, try Hailuo as last resort
          debugPrint(
              '⚠️ Kling unavailable, switching to second fallback: $MODEL_HAILUO');
          try {
            final taskId = await _generateVideoWithModel(
              model: MODEL_HAILUO,
              prompt: prompt,
              aspectRatio: aspectRatio,
              nFrames: nFrames,
              removeWatermark: removeWatermark,
            );
            return {'taskId': taskId, 'usedModel': MODEL_HAILUO};
          } catch (secondFallbackError) {
            debugPrint(
                '❌ Second fallback (Hailuo) failed: $secondFallbackError');
            rethrow; // Throw original error if all fail, or maybe the last one?
            // Throwing the last error might be more confusing if the user expects Sora.
            // But usually best to show the last attempt's error.
          }
        }
      }
      rethrow;
    }
  }

  /// Internal method to generate video with a specific model
  Future<String> _generateVideoWithModel({
    required String model,
    required String prompt,
    required String aspectRatio, // "landscape" or "portrait"
    required String nFrames, // "10" or "15"
    bool removeWatermark = true,
  }) async {
    try {
      // Check connectivity first
      await _checkConnectivity();

      final response = await _executeWithRetry(() => http.post(
            Uri.parse('$_baseUrl/api/v1/jobs/createTask'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'input': {
                'prompt': prompt,
                'aspect_ratio': aspectRatio,
                'n_frames': nFrames,
                'remove_watermark': removeWatermark,
              },
            }),
          ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return data['data']['taskId'];
        } else {
          throw KieAIException(
            _getUserFriendlyError(data['msg'] ?? 'Unknown error'),
            technicalDetails: '$model API: ${data['msg']}',
          );
        }
      } else if (response.statusCode == 401) {
        throw KieAIException('Invalid API key. Please contact support.');
      } else if (response.statusCode == 402) {
        throw KieAIException(
            'Insufficient credits. Please top up your account.');
      } else if (response.statusCode == 429) {
        throw KieAIException(
          'Too many requests. Please wait a moment and try again.',
          isRetryable: true,
        );
      } else {
        throw KieAIException(
          'Server error. Please try again later.',
          technicalDetails: 'HTTP ${response.statusCode}: ${response.body}',
          isRetryable: response.statusCode >= 500,
        );
      }
    } on KieAIException {
      rethrow;
    } catch (e) {
      debugPrint('Error generating video with $model: $e');
      throw KieAIException(
        _getUserFriendlyError(e.toString()),
        technicalDetails: e.toString(),
        isRetryable: true,
      );
    }
  }

  /// DEPRECATED: Use generateVideoWithFallback instead
  Future<String> generateVideoWithSora2({
    required String prompt,
    required String aspectRatio,
    required String nFrames,
    bool removeWatermark = true,
  }) async {
    return _generateVideoWithModel(
        model: MODEL_SORA2,
        prompt: prompt,
        aspectRatio: aspectRatio,
        nFrames: nFrames,
        removeWatermark: removeWatermark);
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

  /// Check the status of a Sora 2 task with retry logic
  Future<Map<String, dynamic>> checkSora2TaskStatus(String taskId) async {
    try {
      final response = await _executeWithRetry(
        () => http.get(
          Uri.parse('$_baseUrl/api/v1/jobs/recordInfo?taskId=$taskId'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        maxRetries: 2, // Fewer retries for status checks
        timeout: _pollingTimeout, // Longer timeout for background polling
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final state = taskData['state']; // waiting, success, fail

          if (state == 'success') {
            // Safely parse resultJson
            try {
              final resultJson = jsonDecode(taskData['resultJson']);
              final resultUrls = resultJson['resultUrls'];
              if (resultUrls != null &&
                  resultUrls is List &&
                  resultUrls.isNotEmpty) {
                return {
                  'state': 'success',
                  'videoUrl': resultUrls[0],
                };
              } else {
                return {
                  'state': 'fail',
                  'error': 'Video URL not found in response',
                };
              }
            } catch (parseError) {
              debugPrint('Error parsing result JSON: $parseError');
              return {
                'state': 'fail',
                'error': 'Failed to parse video result',
              };
            }
          } else if (state == 'fail') {
            return {
              'state': 'fail',
              'error': taskData['failMsg'] ?? 'Generation failed',
            };
          } else {
            return {
              'state': 'waiting',
            };
          }
        } else {
          throw KieAIException(
            'Failed to check status',
            technicalDetails: 'API error: ${data['msg']}',
            isRetryable: true,
          );
        }
      } else {
        throw KieAIException(
          'Failed to check status',
          technicalDetails: 'HTTP ${response.statusCode}',
          isRetryable: response.statusCode >= 500,
        );
      }
    } on KieAIException {
      rethrow;
    } catch (e) {
      debugPrint('Error checking Sora 2 task status: $e');
      // Return waiting state on network errors to keep polling
      return {
        'state': 'waiting',
        'error': e.toString(),
        'isNetworkError': true,
      };
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
      ).timeout(
        _pollingTimeout, // Duration(seconds: 60)
        onTimeout: () {
          throw TimeoutException('Task status check timed out after ${_pollingTimeout.inSeconds}s');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final state = taskData['state'];

          if (state == 'success') {
            // Safely parse resultJson with try-catch
            try {
              final resultJson = jsonDecode(taskData['resultJson']);
              final resultUrls = resultJson['resultUrls'];
              if (resultUrls != null && resultUrls is List && resultUrls.isNotEmpty) {
                return {
                  'state': 'success',
                  'videoUrl': resultUrls[0],
                };
              } else {
                return {
                  'state': 'fail',
                  'error': 'Video URL not found in response',
                };
              }
            } catch (parseError) {
              debugPrint('Error parsing Veo3 result JSON: $parseError');
              return {
                'state': 'fail',
                'error': 'Failed to parse video result',
              };
            }
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

  /// Check the status of a Nano Banana Pro image generation task with retry logic
  Future<Map<String, dynamic>> checkImageTaskStatus(String taskId) async {
    try {
      final response = await _executeWithRetry(
        () => http.get(
          Uri.parse('$_baseUrl/api/v1/jobs/recordInfo?taskId=$taskId'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        maxRetries: 2,
        timeout: _pollingTimeout, // Longer timeout for background polling
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final state = taskData['state'];

          if (state == 'success') {
            try {
              final resultJson = jsonDecode(taskData['resultJson']);
              final resultUrls = resultJson['resultUrls'];
              if (resultUrls != null &&
                  resultUrls is List &&
                  resultUrls.isNotEmpty) {
                return {
                  'state': 'success',
                  'imageUrl': resultUrls[0],
                  'videoUrl': resultUrls[
                      0], // Also provide as videoUrl for unified handling
                };
              } else {
                return {
                  'state': 'fail',
                  'error': 'Image URL not found in response',
                };
              }
            } catch (parseError) {
              debugPrint('Error parsing result JSON: $parseError');
              return {
                'state': 'fail',
                'error': 'Failed to parse image result',
              };
            }
          } else if (state == 'fail') {
            return {
              'state': 'fail',
              'error': taskData['failMsg'] ?? 'Generation failed',
            };
          } else {
            return {
              'state': 'waiting',
            };
          }
        } else {
          throw KieAIException(
            'Failed to check status',
            technicalDetails: 'API error: ${data['msg']}',
            isRetryable: true,
          );
        }
      } else {
        throw KieAIException(
          'Failed to check status',
          technicalDetails: 'HTTP ${response.statusCode}',
          isRetryable: response.statusCode >= 500,
        );
      }
    } on KieAIException {
      rethrow;
    } catch (e) {
      debugPrint('Error checking image task status: $e');
      // Return waiting state on network errors to keep polling
      return {
        'state': 'waiting',
        'error': e.toString(),
        'isNetworkError': true,
      };
    }
  }

  // ==================== IMAGE GENERATION (Nano Banana Pro) ====================

  /// Generate image using Nano Banana Pro with retry logic
  /// Returns a taskId that needs to be polled for results
  Future<String> generateImage({
    required String prompt,
    List<String>? imageInput, // Optional: up to 8 input images (URLs)
    String aspectRatio =
        '1:1', // 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9
    String resolution = '1K', // 1K, 2K, 4K
    String outputFormat = 'png', // png, jpg
  }) async {
    try {
      // Check connectivity first
      await _checkConnectivity();

      final response = await _executeWithRetry(() => http.post(
            Uri.parse('$_baseUrl/api/v1/jobs/createTask'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'nano-banana-pro',
              'input': {
                'prompt': prompt,
                'image_input': imageInput ?? [],
                'aspect_ratio': aspectRatio,
                'resolution': resolution,
                'output_format': outputFormat,
              },
            }),
          ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return data['data']['taskId'];
        } else {
          throw KieAIException(
            _getUserFriendlyError(data['msg'] ?? 'Unknown error'),
            technicalDetails: 'Nano Banana API: ${data['msg']}',
          );
        }
      } else if (response.statusCode == 401) {
        throw KieAIException('Invalid API key. Please contact support.');
      } else if (response.statusCode == 402) {
        throw KieAIException(
            'Insufficient credits. Please top up your account.');
      } else if (response.statusCode == 429) {
        throw KieAIException(
          'Too many requests. Please wait a moment and try again.',
          isRetryable: true,
        );
      } else {
        throw KieAIException(
          'Server error. Please try again later.',
          technicalDetails: 'HTTP ${response.statusCode}: ${response.body}',
          isRetryable: response.statusCode >= 500,
        );
      }
    } on KieAIException {
      rethrow;
    } catch (e) {
      debugPrint('Error generating image: $e');
      throw KieAIException(
        _getUserFriendlyError(e.toString()),
        technicalDetails: e.toString(),
        isRetryable: true,
      );
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
      // Check connectivity first (skip for web platform as InternetAddress is not available)
      if (!kIsWeb) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isEmpty || result[0].rawAddress.isEmpty) {
            throw SocketException('No internet connection');
          }
        } on SocketException catch (_) {
          throw Exception(
              'No internet connection. Please check your Wi-Fi or data.');
        }
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
      if (e is UnimplementedError) {
        throw Exception(e.message ?? 'This feature is coming soon.');
      }
      throw Exception(_getUserFriendlyError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _generateVideoContent(
    CreationConfig config,
    String enhancedPrompt,
    File? imageFile,
  ) async {
    String taskId;

    // For MVP: Only support text-to-video (Sora 2 / Fallback)
    // Image-to-video (Veo3) requires cloud storage - disabled for now
    if (imageFile == null) {
      // Use Sora 2 with fallback to Kling/Hailuo
      final result = await generateVideoWithFallback(
        prompt: enhancedPrompt,
        aspectRatio: config.videoAspectRatio ?? 'landscape',
        nFrames: config.videoDurationSeconds?.toString() ?? '10',
        removeWatermark: true,
      );

      taskId = result['taskId']!;
      final usedModel = result['usedModel'];

      // Return taskId immediately for persistence
      return {
        'type': 'video_task',
        'taskId': taskId,
        'status': 'processing',
        'usedModel': usedModel,
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
    // Convert size string (e.g., "1024x1024") to aspect ratio and resolution
    String aspectRatio = '1:1';
    String resolution = '1K';

    if (config.imageSize != null) {
      // Map common sizes to aspect ratios
      if (config.imageSize == '1920x1080' || config.imageSize == '16:9') {
        aspectRatio = '16:9';
        resolution = '2K';
      } else if (config.imageSize == '1080x1920' ||
          config.imageSize == '9:16') {
        aspectRatio = '9:16';
        resolution = '2K';
      } else {
        aspectRatio = '1:1';
        resolution = '1K';
      }
    }

    final taskId = await generateImage(
      prompt: enhancedPrompt,
      aspectRatio: aspectRatio,
      resolution: resolution,
      outputFormat: 'png',
    );

    // Return taskId immediately for persistence (similar to video)
    return {
      'type': 'image_task',
      'taskId': taskId,
      'status': 'processing',
    };
  }

  /// Public method to check status of a task (works for both video and image)
  /// Attempts to check status using both video and image endpoints
  Future<Map<String, dynamic>> checkTaskStatus(String taskId) async {
    try {
      // Try checking as a video task first (Sora 2)
      final result = await checkSora2TaskStatus(taskId);
      return result;
    } catch (e) {
      // If it fails, try checking as an image task (Nano Banana)
      try {
        final result = await checkImageTaskStatus(taskId);
        return result;
      } catch (imageError) {
        // If both fail, rethrow the original error
        debugPrint('Error checking task status: $e');
        rethrow;
      }
    }
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
