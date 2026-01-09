import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IpLocationService {
  static const String _apiUrl = 'http://ip-api.com/json';

  /// Fetches the 2-letter country code (ISO 3166-1 alpha-2) based on IP.
  /// Returns 'SA' (Saudi Arabia) as default on error.
  static Future<String> getCountryCode() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['countryCode'] ?? 'SA';
        }
      }
    } catch (e) {
      debugPrint('⚠️ IP Location: Failed to get country code: $e');
    }

    // Default fallback
    return 'SA';
  }
}
