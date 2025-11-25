import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/creation_item.dart';

class CreationRepository {
  static const String _storageKey = 'user_creations';

  Future<List<CreationItem>> getCreations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? creationsJson = prefs.getString(_storageKey);

    if (creationsJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(creationsJson);
      return decoded.map((item) => CreationItem.fromMap(item)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest
    } catch (e) {
      print('Error loading creations: $e');
      return [];
    }
  }

  Future<void> saveCreation(CreationItem creation) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CreationItem> currentList = await getCreations();

    // Check if exists and update, or add new
    final index = currentList.indexWhere((item) => item.id == creation.id);
    if (index >= 0) {
      currentList[index] = creation;
    } else {
      currentList.insert(0, creation);
    }

    await _saveList(prefs, currentList);
  }

  Future<void> deleteCreation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CreationItem> currentList = await getCreations();

    currentList.removeWhere((item) => item.id == id);
    await _saveList(prefs, currentList);
  }

  Future<void> _saveList(
      SharedPreferences prefs, List<CreationItem> list) async {
    final String encoded = json.encode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
