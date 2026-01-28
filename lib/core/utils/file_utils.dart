import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:akvioo/core/utils/safe_api_caller.dart';
import 'package:gal/gal.dart';

// Helper class to access SafeApiCaller
class _ApiHelper with SafeApiCaller {}

class FileUtils {
  static final _ApiHelper _api = _ApiHelper();
  static Future<File?> downloadFile(String url) async {
    // File operations not supported on web platform
    if (kIsWeb) {
      debugPrint('File download not supported on web platform');
      return null;
    }

    try {
      final response = await _api.safeApiCall(() => http.get(Uri.parse(url)));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName = url.split('/').last;
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      debugPrint("Error downloading file: $e");
      // Optionally rethrow or handle user-friendly error if this was UI-facing
      return null;
    }
  }

  static Future<void> shareVideo(String url) async {
    // On web, share the URL directly instead of downloading file
    if (kIsWeb) {
      try {
        await Share.share(
          url,
          subject: 'Check out my AI video created with Aqvioo!',
        );
      } catch (e) {
        debugPrint("Error sharing video on web: $e");
      }
      return;
    }

    try {
      final file = await downloadFile(url);
      if (file != null) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Check out my AI video created with Aqvioo!');
      }
    } catch (e) {
      debugPrint("Error sharing video: $e");
    }
  }

  static Future<bool> saveToGallery(String filePath,
      {bool isVideo = true}) async {
    // Gallery save not supported on web platform
    if (kIsWeb) {
      debugPrint('Gallery save not supported on web platform');
      return false;
    }

    try {
      // Check for access permission
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        // Request permission and verify it was granted
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          debugPrint('Gallery permission denied by user');
          return false;
        }
      }

      // Save to gallery
      if (isVideo) {
        await Gal.putVideo(filePath);
      } else {
        await Gal.putImage(filePath);
      }
      return true;
    } catch (e) {
      debugPrint("Error saving to gallery: $e");
      return false;
    }
  }
}
