import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Custom exception for API errors with user-friendly messages
class ApiException implements Exception {
  final String message;
  final String? technicalDetails;
  final int? statusCode;
  final bool isRetryable;

  ApiException(
    this.message, {
    this.technicalDetails,
    this.statusCode,
    this.isRetryable = false,
  });

  @override
  String toString() => message;
}

/// Mixin to provide robust API calling capabilities
mixin SafeApiCaller {
  // Retry configuration
  static const int _defaultMaxRetries = 3;
  static const Duration _defaultInitialRetryDelay = Duration(seconds: 2);
  static const Duration _defaultRequestTimeout = Duration(seconds: 30);

  /// Execute an HTTP request with automatic retry on transient failures
  Future<http.Response> safeApiCall(
    Future<http.Response> Function() request, {
    int maxRetries = _defaultMaxRetries,
    Duration? timeout,
    String? serviceName,
  }) async {
    // Check connectivity first
    await _checkConnectivity();

    int attempt = 0;
    Exception? lastException;
    final effectiveTimeout = timeout ?? _defaultRequestTimeout;

    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(effectiveTimeout);

        // Check for specific status codes that might need retry (e.g., 429, 5xx)
        if (response.statusCode == 429) {
          throw ApiException(
            'Too many requests. Please wait a moment and try again.',
            statusCode: 429,
            isRetryable: true,
          );
        } else if (response.statusCode >= 500) {
          throw ApiException(
            'Server error. Please try again later.',
            statusCode: response.statusCode,
            technicalDetails: 'HTTP ${response.statusCode}: ${response.body}',
            isRetryable: true,
          );
        } else if (response.statusCode == 401) {
          final servicePrefix = serviceName != null ? '$serviceName: ' : '';
          throw ApiException(
            '${servicePrefix}Unauthorized. Please check your API key.',
            statusCode: 401,
            isRetryable: false, // Usually not retryable without auth fix
          );
        }

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
      } on ApiException catch (e) {
        if (!e.isRetryable) rethrow;
        lastException = e;
        debugPrint('API error (attempt ${attempt + 1}/$maxRetries): $e');
      } catch (e) {
        // Non-retryable error, throw immediately
        rethrow;
      }

      attempt++;
      if (attempt < maxRetries) {
        // Exponential backoff
        final delay = _defaultInitialRetryDelay * (1 << (attempt - 1));
        debugPrint('Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    // All retries exhausted
    int? finalStatusCode;
    if (lastException is ApiException) {
      finalStatusCode = lastException.statusCode;
    }

    throw ApiException(
      'Connection failed after $maxRetries attempts. Please check your internet and try again.',
      technicalDetails: lastException?.toString(),
      statusCode: finalStatusCode,
      isRetryable: true,
    );
  }

  /// Check internet connectivity
  Future<void> _checkConnectivity() async {
    // Skip connectivity check on web platform as InternetAddress is not available
    if (kIsWeb) return;

    try {
      // Try multiple reliable hosts to avoid false negatives
      final List<String> hosts = [
        'google.com',
        'cloudflare.com',
        '1.1.1.1',
      ];

      bool isConnected = false;
      for (final host in hosts) {
        try {
          final result = await InternetAddress.lookup(host)
              .timeout(const Duration(seconds: 3));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isConnected = true;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (!isConnected) {
        throw ApiException(
          'No internet connection. Please check your Wi-Fi or mobile data.',
          isRetryable: true,
        );
      }
    } catch (_) {
      throw ApiException(
        'No internet connection. Please check your Wi-Fi or mobile data.',
        isRetryable: true,
        technicalDetails: 'Failed to lookup reliable hosts',
      );
    }
  }

  /// Convert technical errors to user-friendly messages
  String getUserFriendlyError(dynamic error) {
    final String errorMsg = error.toString();

    if (error is ApiException) {
      return error.message;
    }

    if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
      return 'Invalid API key. Please check your configuration.';
    } else if (errorMsg.contains('402') || errorMsg.contains('Insufficient')) {
      return 'Insufficient credits. Please top up your account.';
    } else if (errorMsg.contains('429') || errorMsg.contains('Rate')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (errorMsg.contains('SocketException') ||
        errorMsg.contains('Network') ||
        errorMsg.contains('Connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMsg.contains('Timeout')) {
      return 'Request timed out. The server is taking too long to respond.';
    }

    // Default message
    return 'Something went wrong. Please try again later.';
  }
}
