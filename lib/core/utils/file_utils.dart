import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

class FileUtils {
  static Future<File?> downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName = url.split('/').last;
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print("Error downloading file: $e");
      return null;
    }
  }

  static Future<bool> saveVideoToGallery(String url) async {
    try {
      final file = await downloadFile(url);
      if (file != null) {
        final result = await ImageGallerySaver.saveFile(file.path);
        return result != null && result['isSuccess'];
      }
      return false;
    } catch (e) {
      print("Error saving to gallery: $e");
      return false;
    }
  }

  static Future<void> shareVideo(String url) async {
    try {
      final file = await downloadFile(url);
      if (file != null) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Check out my AI video created with Aqvioo!');
      }
    } catch (e) {
      print("Error sharing video: $e");
    }
  }
}
