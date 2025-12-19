import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/memory_model.dart';

class StorageService {
  static const String _storageKey = 'memories';
  static const String _categoriesKey = 'categories';

  // Load memories from SharedPreferences
  Future<List<MemoryItem>> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedMemories = prefs.getStringList(_storageKey);

    if (storedMemories == null) {
      return [];
    }

    return storedMemories
        .map((item) => MemoryItem.fromJson(jsonDecode(item)))
        .toList();
  }

  // Save memories to SharedPreferences
  Future<void> saveMemories(List<MemoryItem> memories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMemories = memories
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_storageKey, encodedMemories);
  }

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedCategories = prefs.getStringList(_categoriesKey);
    
    if (storedCategories == null || storedCategories.isEmpty) {
      return [
        Category(name: 'Shopping', emoji: '🛒'),
        Category(name: 'Work', emoji: '💼'),
        Category(name: 'Learning', emoji: '📚'),
        Category(name: 'Free time', emoji: '🎮'),
        Category(name: 'Custom', emoji: '✨'),
      ];
    }

    return storedCategories.map((item) {
      if (item.startsWith('{')) {
        return Category.fromJson(jsonDecode(item));
      } else {
        // Migration for legacy string categories
        String emoji = '📁';
        if (item == 'Shopping') emoji = '🛒';
        else if (item == 'Work') emoji = '💼';
        else if (item == 'Learning') emoji = '📚';
        else if (item == 'Free time') emoji = '🎮';
        else if (item == 'Custom') emoji = '✨';
        
        return Category(name: item, emoji: emoji);
      }
    }).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = categories
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_categoriesKey, encoded);
  }
}
