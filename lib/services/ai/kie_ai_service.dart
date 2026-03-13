import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/remote_config_service.dart';
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
    Object? lastException;
    final effectiveTimeout = timeout ?? _requestTimeout;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(effectiveTimeout);
        return response;
      } on SocketException catch (e) {
        lastException = e;
        debugPrint('Network error (attempt ${attempt + 1}/$maxRetries): $e');
      } on TimeoutException catch (e) {
        lastException = e;
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

  /// Generate video with automatic fallback: Sora 2 → Veo 3.1 Fast
  /// Returns a Map with 'taskId' and 'usedModel'
  Future<Map<String, String>> generateVideoWithFallback({
    required String prompt,
    required String aspectRatio,
    required String nFrames,
    bool removeWatermark = true,
  }) async {
    // Try Sora 2 first
    try {
      final taskId = await _generateVideoWithModel(
        model: MODEL_SORA2,
        prompt: prompt,
        aspectRatio: aspectRatio,
        nFrames: nFrames,
        removeWatermark: removeWatermark,
      );
      return {'taskId': taskId, 'usedModel': MODEL_SORA2};
    } catch (e) {
      // Don't fallback on permanent errors (bad API key, no credits, flagged content)
      if (e is KieAIException && !e.isRetryable) rethrow;
      debugPrint('⚠️ Sora 2 failed at creation: $e');
      debugPrint('🔄 Falling back to Veo 3.1 Fast...');
    }

    // Fallback: Veo 3.1 Fast (text-to-video)
    try {
      final veoAspect = aspectRatio == 'portrait' ? '9:16' : '16:9';
      final taskId = await generateVideoWithVeo3(
        prompt: prompt,
        model: 'veo3_fast',
        aspectRatio: veoAspect,
      );
      return {'taskId': taskId, 'usedModel': 'veo3_fast'};
    } catch (e) {
      debugPrint('❌ Veo 3.1 Fast also failed: $e');
      throw KieAIException(
        'Video generation is temporarily unavailable. Please try again later.',
        technicalDetails: 'Both Sora 2 and Veo 3.1 Fast failed: $e',
        isRetryable: true,
      );
    }
  }

  /// Generate video trying Veo 3.1 Fast first, then Sora 2 as fallback
  /// Used when Veo is the preferred model (e.g. image-to-video fallback for text)
  Future<Map<String, String>> generateVideoVeoFirstWithFallback({
    required String prompt,
    required String aspectRatio,
    List<String>? imageUrls,
  }) async {
    // Try Veo 3.1 Fast first
    try {
      final taskId = await generateVideoWithVeo3(
        prompt: prompt,
        imageUrls: imageUrls,
        model: 'veo3_fast',
        aspectRatio: aspectRatio,
      );
      return {'taskId': taskId, 'usedModel': 'veo3_fast'};
    } catch (e) {
      // Don't fallback on permanent errors (bad API key, no credits, flagged content)
      if (e is KieAIException && !e.isRetryable) rethrow;
      // Only fall back to Sora if there are no images (Sora is text-only)
      if (imageUrls != null && imageUrls.isNotEmpty) {
        debugPrint('❌ Cannot fall back to Sora for image-to-video');
        rethrow;
      }
      debugPrint('⚠️ Veo 3.1 Fast failed at creation: $e');
      debugPrint('🔄 Falling back to Sora 2...');
    }

    // Fallback: Sora 2 (text-to-video only)
    try {
      final soraAspect = aspectRatio == '9:16' ? 'portrait' : 'landscape';
      final taskId = await _generateVideoWithModel(
        model: MODEL_SORA2,
        prompt: prompt,
        aspectRatio: soraAspect,
        nFrames: '10',
        removeWatermark: true,
      );
      return {'taskId': taskId, 'usedModel': MODEL_SORA2};
    } catch (e) {
      debugPrint('❌ Sora 2 also failed: $e');
      throw KieAIException(
        'Video generation is temporarily unavailable. Please try again later.',
        technicalDetails: 'Both Veo 3.1 Fast and Sora 2 failed: $e',
        isRetryable: true,
      );
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
        debugPrint('❌ 401 Unauthorized - API key issue');
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails: 'HTTP 401: Invalid API key for $model',
        );
      } else if (response.statusCode == 402) {
        debugPrint('❌ 402 Payment Required - API credits issue');
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails: 'HTTP 402: Insufficient API credits for $model',
        );
      } else if (response.statusCode == 429) {
        debugPrint('🚫 429 Response body: ${response.body}');
        debugPrint('🚫 429 Response headers: ${response.headers}');
        throw KieAIException(
          'Too many requests. Please wait a moment and try again.',
          technicalDetails: 'HTTP 429: ${response.body}',
          isRetryable: true,
        );
      } else {
        debugPrint(
            '❌ HTTP ${response.statusCode} Response body: ${response.body}');
        throw KieAIException(
          'Something went wrong. Please try again later.',
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

      final response = await _executeWithRetry(() => http.post(
            Uri.parse('$_baseUrl/api/v1/veo/generate'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return data['data']['taskId'];
        } else {
          throw KieAIException(
            _getUserFriendlyError(data['msg'] ?? 'Unknown error'),
            technicalDetails: 'Veo3 API: ${data['msg']}',
            isRetryable: true,
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 402) {
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails: 'HTTP ${response.statusCode}: ${response.body}',
        );
      } else {
        throw KieAIException(
          'Something went wrong. Please try again later.',
          technicalDetails:
              'Veo3 HTTP ${response.statusCode}: ${response.body}',
          isRetryable: response.statusCode >= 500,
        );
      }
    } on KieAIException {
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
  /// Veo3 uses successFlag (0=processing, 1=success, -1=fail)
  /// and response.resultUrls instead of state/resultJson
  Future<Map<String, dynamic>> checkVeo3TaskStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/veo/record-info?taskId=$taskId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(
        _pollingTimeout,
        onTimeout: () {
          throw TimeoutException(
              'Task status check timed out after ${_pollingTimeout.inSeconds}s');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final taskData = data['data'];
          final successFlag = taskData['successFlag'] ?? 0;

          if (successFlag == 1) {
            // Success - extract video URL from response.resultUrls
            final responseData = taskData['response'];
            if (responseData != null && responseData['resultUrls'] != null) {
              final resultUrls = responseData['resultUrls'] as List;
              if (resultUrls.isNotEmpty) {
                return {
                  'state': 'success',
                  'videoUrl': resultUrls[0],
                };
              }
            }
            return {
              'state': 'fail',
              'error': 'Video URL not found in response',
            };
          } else if (successFlag == -1) {
            return {
              'state': 'fail',
              'error': taskData['errorMessage'] ?? 'Generation failed',
            };
          } else {
            // successFlag == 0: still processing
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
      // Return waiting state on network errors to keep polling (consistent with Sora)
      return {
        'state': 'waiting',
        'error': e.toString(),
        'isNetworkError': true,
      };
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
        debugPrint('❌ 401 Unauthorized - API key issue (image)');
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails: 'HTTP 401: Invalid API key for image generation',
        );
      } else if (response.statusCode == 402) {
        debugPrint('❌ 402 Payment Required - API credits issue (image)');
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails:
              'HTTP 402: Insufficient API credits for image generation',
        );
      } else if (response.statusCode == 429) {
        debugPrint('🚫 429 Response body: ${response.body}');
        debugPrint('🚫 429 Response headers: ${response.headers}');
        throw KieAIException(
          'Too many requests. Please wait a moment and try again.',
          technicalDetails: 'HTTP 429: ${response.body}',
          isRetryable: true,
        );
      } else {
        debugPrint(
            '❌ HTTP ${response.statusCode} Response body: ${response.body}');
        throw KieAIException(
          'Something went wrong. Please try again later.',
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

  // ==================== HELPER: Image Upload via Kie.ai File Upload API ====================

  /// Upload a local image file to Kie.ai's temporary storage.
  /// Returns a public URL that can be used with Veo 3.1 imageUrls.
  /// Primary: Firebase Storage (production). Fallback: Kie.ai temp hosting.
  Future<String> uploadImageToStorage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;

    // Primary: Firebase Storage
    try {
      final fbFileName = '${const Uuid().v4()}_$fileName';
      final ref = FirebaseStorage.instance
          .ref()
          .child('image_to_video')
          .child(fbFileName);

      debugPrint('📤 Uploading image to Firebase Storage: $fbFileName');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('✅ Image uploaded to Firebase: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('⚠️ Firebase Storage failed: $e');
      debugPrint('📤 Falling back to Kie.ai upload...');
    }

    // Fallback: Kie.ai upload
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Data = base64Encode(bytes);
      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final response = await http
          .post(
            Uri.parse('https://kieai.redpandaai.co/api/file-base64-upload'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'base64Data': 'data:$mimeType;base64,$base64Data',
              'uploadPath': fileName,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['code'] == 200) {
          final downloadUrl = data['data']['downloadUrl'];
          debugPrint('✅ Image uploaded to Kie.ai: $downloadUrl');
          return downloadUrl;
        }
      }
      throw KieAIException('Failed to upload image. Please try again.');
    } catch (e) {
      if (e is KieAIException) rethrow;
      debugPrint('❌ Image upload error: $e');
      throw KieAIException('Failed to upload image. Please try again.');
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String technicalError) {
    if (technicalError.contains('401') ||
        technicalError.contains('Unauthorized')) {
      return 'Service is temporarily unavailable. Please try again later.';
    } else if (technicalError.contains('402') ||
        technicalError.contains('Insufficient')) {
      return 'Service is temporarily unavailable. Please try again later.';
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
      // Validate API key is present
      if (_apiKey.isEmpty) {
        throw KieAIException(
          'Service is temporarily unavailable. Please try again later.',
          technicalDetails: 'KIE_API_KEY is empty or not configured',
        );
      }

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
    } on KieAIException {
      rethrow;
    } catch (e) {
      debugPrint('Error in generateContent: $e');
      if (e is UnimplementedError) {
        throw KieAIException(e.message ?? 'This feature is not available.');
      }
      throw KieAIException(
        _getUserFriendlyError(e.toString()),
        technicalDetails: e.toString(),
        isRetryable: true,
      );
    }
  }

  Future<Map<String, dynamic>> _generateVideoContent(
    CreationConfig config,
    String enhancedPrompt,
    File? imageFile,
  ) async {
    if (imageFile != null) {
      // Image-to-video: Upload image, then Veo 3.1 Fast (with Veo quality fallback)
      debugPrint('🖼️ Image-to-video: uploading image...');
      final imageUrl = await uploadImageToStorage(imageFile);
      debugPrint('🖼️ Image uploaded, URL: $imageUrl');

      final veoAspect = config.videoAspectRatio == 'portrait' ? '9:16' : '16:9';
      final result = await generateVideoVeoFirstWithFallback(
        prompt: enhancedPrompt,
        aspectRatio: veoAspect,
        imageUrls: [imageUrl],
      );

      return {
        'type': 'video_task',
        'taskId': result['taskId']!,
        'status': 'processing',
        'usedModel': result['usedModel']!,
      };
    } else {
      // Text-to-video: Sora 2 → Veo 3.1 Fast fallback
      final result = await generateVideoWithFallback(
        prompt: enhancedPrompt,
        aspectRatio: config.videoAspectRatio ?? 'landscape',
        nFrames: config.videoDurationSeconds?.toString() ?? '10',
        removeWatermark: true,
      );

      return {
        'type': 'video_task',
        'taskId': result['taskId']!,
        'status': 'processing',
        'usedModel': result['usedModel']!,
      };
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
  Future<Map<String, dynamic>> checkTaskStatus(String taskId,
      {String? model}) async {
    // If we know the model, go directly to the right endpoint
    if (model != null && model.startsWith('veo')) {
      return await checkVeo3TaskStatus(taskId);
    }

    // For known non-veo models, skip veo endpoint
    if (model != null && !model.startsWith('veo')) {
      try {
        return await checkSora2TaskStatus(taskId);
      } catch (_) {
        try {
          return await checkImageTaskStatus(taskId);
        } catch (e) {
          rethrow;
        }
      }
    }

    // Unknown model - try all endpoints
    try {
      return await checkVeo3TaskStatus(taskId);
    } catch (_) {}

    try {
      return await checkSora2TaskStatus(taskId);
    } catch (_) {}

    try {
      return await checkImageTaskStatus(taskId);
    } catch (e) {
      debugPrint('Error checking task status (all endpoints failed): $e');
      rethrow;
    }
  }
}

// Provider - uses RemoteConfigService for API key (fetched from Firestore)
final kieAIServiceProvider = Provider<KieAIService>((ref) {
  final config = ref.watch(remoteConfigServiceProvider);
  final apiKey = config.kieApiKey;
  if (apiKey.isEmpty) {
    debugPrint(
        '⚠️ Warning: KIE_API_KEY not configured. Admin must set it in Settings.');
  } else if (kDebugMode) {
    debugPrint(
        '✅ KIE_API_KEY loaded (${apiKey.length} chars, starts with: ${apiKey.substring(0, 4)}...)');
  }
  return KieAIService(apiKey: apiKey);
});
