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
        if (item == 'Shopping') {
          emoji = '🛒';
        }
        else if (item == 'Work') {
          emoji = '💼';
        }
        else if (item == 'Learning') {
          emoji = '📚';
        }
        else if (item == 'Free time') {
          emoji = '🎮';
        }
        else if (item == 'Custom') {
          emoji = '✨';
        }
        
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

  // Advanced Mode Settings
  static const String _advModeKey = 'advanced_mode';
  static const String _advSeenKey = 'advanced_mode_seen';
  static const String _themeCustomKey = 'custom_theme';
  static const String _themeAccentKey = 'custom_theme_accent';
  static const String _themeModeKey = 'theme_mode_pref'; // 'system', 'light', 'dark'


  Future<bool> loadAdvancedMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_advModeKey) ?? false;
  }

  Future<void> saveAdvancedMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_advModeKey, enabled);
  }

  Future<bool> hasSeenAdvancedDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_advSeenKey) ?? false;
  }

  Future<void> markAdvancedDialogSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_advSeenKey, true);
  }

  // Custom Theme Colors (Stored as int ARGB)
  Future<int?> loadCustomBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeCustomKey);
  }

  Future<void> saveCustomBackgroundColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeCustomKey, colorValue);
  }

  Future<int?> loadCustomAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeAccentKey);
  }

  Future<void> saveCustomAccentColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeAccentKey, colorValue);
  }
  
  Future<void> clearCustomTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeCustomKey);
    await prefs.remove(_themeAccentKey);
  }

  // Font Settings
  static const String _fontKey = 'app_font_family';

  Future<String?> loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontKey);
  }

  Future<void> saveFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, fontFamily);
  }

  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }
}
