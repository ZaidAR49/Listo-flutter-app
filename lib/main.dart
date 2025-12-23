import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/memory_model.dart';
import 'package:my_app/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_app/app_translations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_app/ad_service.dart';
import 'package:my_app/settings_page.dart';
import 'package:my_app/about_page.dart';
import 'package:my_app/how_to_use_page.dart';
import 'package:my_app/error_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'package:my_app/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:linkify/linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Custom Phone Number Linkifier
final _phoneRegex = RegExp(r'\b(?:\d[\d\-\(\) ]{4,}\d)\b', multiLine: true);

class PhoneNumberLinkifier extends Linkifier {
  const PhoneNumberLinkifier();

  @override
  List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        var text = element.text;
        var match = _phoneRegex.firstMatch(text);

        if (match == null) {
          list.add(element);
        } else {
          // Iterate through matches
          var currentText = text;
          var matches = _phoneRegex.allMatches(currentText);

          int lastMatchEnd = 0;
          for (var match in matches) {
            // Add pre-match text
            if (match.start > lastMatchEnd) {
              list.add(TextElement(currentText.substring(lastMatchEnd, match.start)));
            }
            
            // Add phone number link
            final phoneNumber = match.group(0)!;
            list.add(LinkableElement(
              phoneNumber,
              'tel:${phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '')}',
              phoneNumber,
            ));
            
            lastMatchEnd = match.end;
          }
          
          // Add remaining text
          if (lastMatchEnd < currentText.length) {
            list.add(TextElement(currentText.substring(lastMatchEnd)));
          }
        }
      } else {
        list.add(element);
      }
    }
    return list;
  }
}

// Toggle this to TRUE to allow users to turn off ads.
// Set to FALSE to make ads mandatory (hides the toggle).
const bool canRemoveAds = true; 

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      await AdService().initialize();
    } catch (e) {
      debugPrint('Error initializing ads: $e');
    }
  }
  ErrorWidget.builder = (FlutterErrorDetails details) => ErrorPage(details: details);
  runApp(const ZarMemoryApp());
}

class ZarMemoryApp extends StatefulWidget {
  const ZarMemoryApp({super.key});

  @override
  State<ZarMemoryApp> createState() => _ZarMemoryAppState();
}

class _ZarMemoryAppState extends State<ZarMemoryApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  // If canRemoveAds is false, force ads to be shown (true).
  bool _showAds = true;

  // Pro Mode State
  bool _isProMode = false;
  Color? _customBackgroundColor;
  Color? _customAccentColor;
  String? _fontFamily;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = StorageService();
    final isPro = await storage.loadAdvancedMode();
    final customBg = await storage.loadCustomBackgroundColor();
    final customAccent = await storage.loadCustomAccentColor();
    final fontFamily = await storage.loadFontFamily();
    final themeStr = await storage.loadThemeMode();

    if (mounted) {
       setState(() {
         _isProMode = isPro;
         if (customBg != null) _customBackgroundColor = Color(customBg);
         if (customAccent != null) _customAccentColor = Color(customAccent);
         _fontFamily = fontFamily;
         
          if (themeStr == 'dark') {
            _themeMode = ThemeMode.dark;
          } else if (themeStr == 'light') {
            _themeMode = ThemeMode.light;
          } else {
            _themeMode = ThemeMode.system;
          }
       });
    }
  }

  void _updateThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    String themeStr = 'system';
    if (mode == ThemeMode.dark) {
      themeStr = 'dark';
    } else if (mode == ThemeMode.light) {
      themeStr = 'light';
    }
    await StorageService().saveThemeMode(themeStr);
  }

  void _toggleTheme() {
    _updateThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleAds(bool value) {
    setState(() {
      _showAds = value;
    });
  }

  void _toggleProMode(bool value) async {
    setState(() {
      _isProMode = value;
    });
    
    await StorageService().saveAdvancedMode(value);
  }

  void _updateCustomTheme(Color? bg, Color? accent) async {
     // Check if background color specifically changed
     final bool bgChanged = bg != _customBackgroundColor;

     setState(() {
       _customBackgroundColor = bg;
       _customAccentColor = accent;
     });
     
     final storage = StorageService();
     if (bg != null) await storage.saveCustomBackgroundColor(bg.toARGB32());
     if (accent != null) await storage.saveCustomAccentColor(accent.toARGB32());
     if (bg == null && accent == null) {
       await storage.clearCustomTheme();
     }
     
     // Update theme mode after state update and storage operations
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
         // Only switch to Light mode if background color was specifically changed to a new non-null value
         if (bgChanged && bg != null) {
           _updateThemeMode(ThemeMode.light);
         } else if (bg == null && accent == null) {
           // Reset to system theme if fully cleared
           _updateThemeMode(ThemeMode.system);
         }
       }
     });
  }

  void _updateFontFamily(String? font) async {
     setState(() {
       _fontFamily = font;
     });
     if (font != null) {
       await StorageService().saveFontFamily(font);
     }
  }

  TextTheme _getThemeTextTheme(ThemeData base) {
    switch (_fontFamily) {
      case 'Cairo':
        return GoogleFonts.cairoTextTheme(base.textTheme);
      case 'Tajawal':
        return GoogleFonts.tajawalTextTheme(base.textTheme);
      case 'Comic':
        return GoogleFonts.comicNeueTextTheme(base.textTheme);
      default:
        return GoogleFonts.outfitTextTheme(base.textTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Effective dark mode status (either explicit or system-inherited)
    final isActualDark = _themeMode == ThemeMode.dark || 
        (_themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Accent color applies to both modes if set
    final seedColor = _customAccentColor ?? const Color(0xFF6200EE);
    
    // Background color only applies in Light mode
    final effectiveBackgroundColor = (!isActualDark && _customBackgroundColor != null)
        ? _customBackgroundColor!
        : null;
    
    return MaterialApp(
      title: 'LISTO',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
        Locale('fr', ''),
        Locale('es', ''),
        Locale('de', ''),
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: _getThemeTextTheme(ThemeData(brightness: Brightness.light)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: effectiveBackgroundColor ?? Colors.white,
          surfaceContainerHighest: const Color(0xFFF0F0F3),
          primary: seedColor,
        ),
        scaffoldBackgroundColor: effectiveBackgroundColor ?? const Color(0xFFF2F2F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F0F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: _getThemeTextTheme(ThemeData(brightness: Brightness.dark)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          surfaceContainerHighest: const Color(0xFF2C2C2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF1C1C1E),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: seedColor, // Use custom accent color here too
          foregroundColor: Colors.black,
          elevation: 4,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: MemoryHomePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: isActualDark,
        onToggleLanguage: _changeLanguage,
        currentLocale: _locale,
        showAds: _showAds,
        onToggleAds: _toggleAds,
        isProMode: _isProMode,
        onToggleProMode: _toggleProMode,
        customBackgroundColor: _customBackgroundColor,
        customAccentColor: _customAccentColor,
        onUpdateCustomTheme: _updateCustomTheme,
        currentFontFamily: _fontFamily,
        onUpdateFontFamily: _updateFontFamily,
      ),
    );
  }
}

class MemoryHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final Function(Locale) onToggleLanguage;
  final Locale currentLocale;
  final bool showAds;
  final Function(bool) onToggleAds;
  final bool isProMode;
  final Function(bool) onToggleProMode;
  final Color? customBackgroundColor;
  final Color? customAccentColor;
  final Function(Color?, Color?) onUpdateCustomTheme;
  final String? currentFontFamily;
  final Function(String?) onUpdateFontFamily;

  const MemoryHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onToggleLanguage,
    required this.currentLocale,
    required this.showAds,
    required this.onToggleAds,
    required this.isProMode,
    required this.onToggleProMode,
    required this.customBackgroundColor,
    required this.customAccentColor,
    required this.onUpdateCustomTheme,
    required this.currentFontFamily,
    required this.onUpdateFontFamily,
  });

  @override
  State<MemoryHomePage> createState() => _MemoryHomePageState();
}

class _MemoryHomePageState extends State<MemoryHomePage> {
  final StorageService _storageService = StorageService();
  List<MemoryItem> _memories = [];
  List<Category> _categories = [];
  String _selectedCategoryName = 'All';
  bool _isLoading = true;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedMemoryIds = {};

  // Helper to shorten translation calls
  String tr(String key) => AppTranslations.get(widget.currentLocale.languageCode, key);

  void _handleProModeToggle(bool value) async {
    widget.onToggleProMode(value);
    
    if (value) {
      final storage = StorageService();
      // Check if user has seen the "First Time" dialog
      bool seen = await storage.hasSeenAdvancedDialog();
      if (!seen && mounted) {
        _showAdvancedWelcomeDialog();
        await storage.markAdvancedDialogSeen();
      }
    }
  }

  void _showAdvancedWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('advanced_features_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem(tr('feature_new_themes')),
            _buildFeatureItem(tr('feature_images')),
            _buildFeatureItem(tr('feature_biometric')),
            _buildFeatureItem(tr('feature_backup')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('ok_awesome')),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBannerAd();
  }

  @override
  void didUpdateWidget(MemoryHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAds != oldWidget.showAds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.showAds) {
            _loadBannerAd();
          } else {
            _disposeBannerAd();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeBannerAd();
    super.dispose();
  }

  void _loadBannerAd() {
    if (!widget.showAds || (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;
    
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBannerAdLoaded = true;
              });
            }
          });
        }
      },
      onRetryWithTestId: () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBannerAdLoaded = false;
                _bannerAd = null;
              });
              // Retry with the new Test ID after frame is complete
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _loadBannerAd();
                }
              });
            }
          });
        }
      },
    );
    _bannerAd?.load();
  }

  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }


  Future<void> _loadData() async {
    final memories = await _storageService.loadMemories();
    final categories = await _storageService.loadCategories();
    setState(() {
      _memories = memories;
      _categories = categories;
      _isLoading = false;
      _memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _saveMemories() async {
    await _storageService.saveMemories(_memories);
    setState(() {
       _memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _saveCategories() async {
    await _storageService.saveCategories(_categories);
  }

  void _addCategory(String name, String emoji) {
    if (name.trim().isEmpty) {
      return;
    }
    if (_categories.any((c) => c.name == name.trim())) {
      return;
    }
    
    setState(() {
      _categories.add(Category(name: name.trim(), emoji: emoji.trim().isEmpty ? '📁' : emoji.trim()));
    });
    _saveCategories();
  }

  void _deleteCategory(Category category) {
    if (_categories.length <= 1) {
      return; // Prevent deleting last category
    }
    setState(() {
      _categories.removeWhere((c) => c.name == category.name);
      if (_selectedCategoryName == category.name) {
        _selectedCategoryName = 'All';
      }
    });
    _saveCategories();
  }

  void _addOrUpdateMemory(String content, String categoryName, {String? id, DateTime? deadline, List<String>? imagePaths}) {
    if (content.trim().isEmpty) {
      return;
    }

    if (id == null) {
      final newItem = MemoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
        content: content.trim(),
        timestamp: DateTime.now(),
        category: categoryName,
        deadline: deadline,
        imagePaths: imagePaths,
      );
      setState(() {
        _memories.insert(0, newItem);
      });
      
      if (deadline != null) {
         _scheduleDeadlineNotification(newItem);
      }
    } else {
      final index = _memories.indexWhere((item) => item.id == id);
      if (index != -1) {
        // Cancel previous notification if exists
        NotificationService().cancelNotification(_memories[index].id.hashCode);

        setState(() {
          _memories[index].content = content.trim();
          _memories[index].timestamp = DateTime.now();
          _memories[index].category = categoryName;
          _memories[index].deadline = deadline;
          _memories[index].imagePaths = imagePaths;
        });

        if (deadline != null) {
          _scheduleDeadlineNotification(_memories[index]);
        }
      }
    }
    _saveMemories();
  }

  void _scheduleDeadlineNotification(MemoryItem item) {
    if (item.deadline == null) {
      return;
    }
    
    final scheduledDate = item.deadline!.subtract(const Duration(days: 1));
    if (scheduledDate.isAfter(DateTime.now())) {
      try {
        NotificationService().scheduleNotification(
          item.id.hashCode,
          'Deadline Approaching: ${item.category}',
          'Reminder: ${item.content} is due tomorrow!',
          scheduledDate,
        );
      } catch (e) {
        debugPrint('Failed to schedule notification: $e');
      }
    }
  }

  void _showImageLightbox(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Platform.isWindows ? 1000 : double.infinity,
                  maxHeight: Platform.isWindows ? 700 : double.infinity,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMemory(String id) {
    final deletedItem = _memories.firstWhere((item) => item.id == id);
    final int deletedIndex = _memories.indexOf(deletedItem);

    setState(() {
      _memories.removeWhere((item) => item.id == id);
    });
    NotificationService().cancelNotification(id.hashCode);
    _saveMemories();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('memory_deleted')),
        action: SnackBarAction(
          label: tr('undo'),
          onPressed: () {
            setState(() {
              _memories.insert(deletedIndex, deletedItem);
            });
            _saveMemories();
          },
        ),
      ),
    );
  }

  void _deleteSelectedMemories() {
    final List<MemoryItem> deletedItems = [];
    for (var id in _selectedMemoryIds) {
      final item = _memories.firstWhere((m) => m.id == id);
      deletedItems.add(item);
      NotificationService().cancelNotification(id.hashCode);
    }

    setState(() {
      _memories.removeWhere((m) => _selectedMemoryIds.contains(m.id));
      _isSelectionMode = false;
      _selectedMemoryIds.clear();
    });
    _saveMemories();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedItems.length} ${tr('memory_deleted')}'),
        action: SnackBarAction(
          label: tr('undo'),
          onPressed: () {
            setState(() {
              _memories.addAll(deletedItems);
              _memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            });
            _saveMemories();
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emojiController = TextEditingController(); // Simple generic emoji input
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr('add_category')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: tr('category_name_hint'),
                  labelText: tr('category_name_label'),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                maxLength: 3,
                decoration: InputDecoration(
                  hintText: tr('emoji_hint'),
                  labelText: tr('emoji_label'),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () {
                _addCategory(nameController.text, emojiController.text);
                Navigator.pop(context);
              },
              child: Text(tr('add')),
            ),
          ],
        );
      },
    );
  }

  void _showMemoryDialog({MemoryItem? item}) {
    final TextEditingController textController = TextEditingController(text: item?.content ?? '');
    final ScrollController scrollController = ScrollController();
    final FocusNode textFocusNode = FocusNode();
    
    String selectedCategoryName = item?.category ?? (_selectedCategoryName == 'All' && _categories.isNotEmpty ? _categories.first.name : _selectedCategoryName);

    // Fallback if category doesn't exist
    if (!_categories.any((c) => c.name == selectedCategoryName) && selectedCategoryName != 'All') {
      if (_categories.isNotEmpty) {
        selectedCategoryName = _categories.first.name;
      }
    }
    if (selectedCategoryName == 'All' && _categories.isNotEmpty) {
      selectedCategoryName = _categories.first.name;
    }

    DateTime? selectedDeadline = item?.deadline;
    List<String> selectedImagePaths = List<String>.from(item?.imagePaths ?? []);

    // Listen to focus changes to scroll when keyboard appears
    textFocusNode.addListener(() {
      if (textFocusNode.hasFocus) {
        // Delay to allow keyboard to appear first
        Future.delayed(const Duration(milliseconds: 300), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
                    // Logic for Submit shortcut
                    if (textController.text.trim().length < 3) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('min_char_error'),
                              style: TextStyle(color: Theme.of(context).colorScheme.onError),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            width: 280,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                    }
                    Navigator.pop(context);
                    Future.microtask(() {
                      _addOrUpdateMemory(
                        textController.text, 
                        selectedCategoryName, 
                        id: item?.id,
                        deadline: selectedDeadline,
                        imagePaths: selectedImagePaths,
                      );
                    });
                },
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  Navigator.pop(context);
                },
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.only(
                  bottom: 24,
                  top: 24,
                  left: 24,
                  right: 24,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null ? tr('new_memory') : tr('edit_memory'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                         icon: const Icon(Icons.close),
                         onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = selectedCategoryName == category.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${category.emoji} ${category.name}'),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setModalState(() {
                                  selectedCategoryName = category.name;
                                });
                              }
                            },
                            showCheckmark: false,
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.isProMode) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          tr('add_images'),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                        const Spacer(),
                        Text(
                          '${selectedImagePaths.length}/3',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...selectedImagePaths.asMap().entries.map((entry) {
                             int idx = entry.key;
                             String path = entry.value;
                             return Container(
                               margin: const EdgeInsets.only(right: 8),
                               width: 70,
                               height: 70,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                                 image: DecorationImage(
                                   image: FileImage(File(path)),
                                   fit: BoxFit.cover,
                                 ),
                               ),
                               child: Stack(
                                 children: [
                                   Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            selectedImagePaths.removeAt(idx);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                   ),
                                 ],
                                ),
                             );
                          }),
                          if (selectedImagePaths.length < 3)
                            GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> images = await picker.pickMultiImage();
                                if (images.isNotEmpty) {
                                  setModalState(() {
                                    for (var img in images) {
                                      if (selectedImagePaths.length < 3) {
                                        selectedImagePaths.add(img.path);
                                      }
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                                ),
                                child: Icon(Icons.add_a_photo_rounded, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                        controller: textController,
                        focusNode: textFocusNode,
                        autofocus: true,
                        maxLines: 6,
                        minLines: 3,
                        maxLength: 1000,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: tr('memory_hint'),
                          helperText: tr('min_char_helper'),
                          helperMaxLines: 1,
                        ),
                        onSubmitted: (value) {
                          // Handle Enter key - submit if single line
                          if (textController.text.split('\n').length == 1) {
                            if (textController.text.trim().length < 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    tr('min_char_error'),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onError),
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  width: 280,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context);
                            Future.microtask(() {
                              _addOrUpdateMemory(
                                textController.text, 
                                selectedCategoryName, 
                                id: item?.id,
                                deadline: selectedDeadline,
                                imagePaths: selectedImagePaths,
                              );
                            });
                          }
                        },
                      ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDeadline = picked;
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_today, size: 18, color: selectedDeadline != null ? Theme.of(context).colorScheme.primary : null),
                          label: Text(
                            selectedDeadline == null 
                                ? tr('set_deadline') 
                                : DateFormat('MMM d, y', widget.currentLocale.languageCode).format(selectedDeadline!),
                            style: TextStyle(
                               color: selectedDeadline != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface 
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: selectedDeadline != null 
                                ? BorderSide(color: Theme.of(context).colorScheme.primary) 
                                : null,
                          ),
                        ),
                      ),
                      if (selectedDeadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                             setModalState(() {
                               selectedDeadline = null;
                             });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      if (textController.text.trim().length < 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('min_char_error'),
                              style: TextStyle(color: Theme.of(context).colorScheme.onError),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            width: 280,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      Future.microtask(() {
                        _addOrUpdateMemory(
                          textController.text, 
                          selectedCategoryName, 
                          id: item?.id,
                          deadline: selectedDeadline,
                          imagePaths: selectedImagePaths,
                        );
                      });
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(tr('save_memory'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMemories = _selectedCategoryName == 'All'
        ? _memories
        : _memories.where((m) => m.category == _selectedCategoryName).toList();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (!_isSelectionMode) {
            _showMemoryDialog();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
            bottomNavigationBar: (_isBannerAdLoaded && widget.showAds && _bannerAd != null)
                ? SizedBox(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                : null,
      appBar: AppBar(
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.isProMode)
            _PremiumBadge(
              primaryColor: Theme.of(context).colorScheme.primary,
              isDarkMode: widget.isDarkMode,
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('app_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(tr('all_memories')),
              selected: _selectedCategoryName == 'All',
              onTap: () {
                setState(() => _selectedCategoryName = 'All');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      tr('categories'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._categories.map((category) => ListTile(
                    leading: Text(category.emoji, style: const TextStyle(fontSize: 20)),
                    title: Text(category.name),
                    selected: _selectedCategoryName == category.name,
                    trailing: IconButton(
                       icon: const Icon(Icons.delete_outline, size: 20),
                       onPressed: () => _deleteCategory(category),
                    ),
                    onTap: () {
                      setState(() => _selectedCategoryName = category.name);
                      Navigator.pop(context);
                    },
                  )),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(tr('add_category')),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddCategoryDialog();
                    },
                  ),

                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(tr('settings')),
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      isDarkMode: widget.isDarkMode,
                      onToggleTheme: widget.onToggleTheme,
                      currentLocale: widget.currentLocale,
                      onToggleLanguage: widget.onToggleLanguage,
                      showAds: widget.showAds,
                      onToggleAds: widget.onToggleAds,
                      canRemoveAds: canRemoveAds,
                      isProMode: widget.isProMode,
                      onToggleProMode: _handleProModeToggle,
                      customBackgroundColor: widget.customBackgroundColor,
                      customAccentColor: widget.customAccentColor,
                      onUpdateCustomTheme: widget.onUpdateCustomTheme,
                      currentFontFamily: widget.currentFontFamily,
                      onUpdateFontFamily: widget.onUpdateFontFamily,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(tr('how_to_use')),
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HowToUsePage(
                      currentLocale: widget.currentLocale,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(tr('about')),
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(
                      currentLocale: widget.currentLocale,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredMemories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.memory,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategoryName == 'All' 
                          ? tr('no_memories') 
                          : '${tr('no_cat_memories')} $_selectedCategoryName',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 12, left: 16, right: 16),
                  itemCount: filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = filteredMemories[index];
                    return Dismissible(
                      key: Key(memory.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) {
                        _deleteMemory(memory.id);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: _selectedMemoryIds.contains(memory.id) 
                              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                             if (_isSelectionMode) {
                               setState(() {
                                 if (_selectedMemoryIds.contains(memory.id)) {
                                   _selectedMemoryIds.remove(memory.id);
                                   if (_selectedMemoryIds.isEmpty) {
                                     _isSelectionMode = false;
                                   }
                                 } else {
                                   _selectedMemoryIds.add(memory.id);
                                 }
                               });
                             } else {
                               _showMemoryDialog(item: memory);
                             }
                          },
                          onLongPress: () {
                            setState(() {
                              _isSelectionMode = true;
                              _selectedMemoryIds.add(memory.id);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(memory.category).withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _getEmojiForCategory(memory.category),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            memory.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getCategoryColor(memory.category),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () => _deleteMemory(memory.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      style: IconButton.styleFrom(
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      tooltip: tr('delete'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 20),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: memory.content));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(tr('copied')),
                                            behavior: SnackBarBehavior.floating,
                                            width: 200,
                                          ),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      style: IconButton.styleFrom(
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      tooltip: 'Copy text',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (context) {
                                    final elements = linkify(
                                      memory.content,
                                      options: const LinkifyOptions(humanize: false),
                                      linkifiers: const [
                                        EmailLinkifier(), 
                                        UrlLinkifier(),
                                        PhoneNumberLinkifier(),
                                      ],
                                    );
                                    
                                    return Text.rich(
                                      TextSpan(
                                        children: elements.map<InlineSpan>((element) {
                                          if (element is LinkableElement) {
                                            return WidgetSpan(
                                              alignment: PlaceholderAlignment.baseline,
                                              baseline: TextBaseline.alphabetic,
                                              child: GestureDetector(
                                                onTap: () async {
                                                   if (!await launchUrl(Uri.parse(element.url), mode: LaunchMode.externalApplication)) {
                                                      if (context.mounted) {
                                                         ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text(tr('error_link'))),
                                                          );
                                                      }
                                                    }
                                                },
                                                onLongPress: () {
                                                  Clipboard.setData(ClipboardData(text: element.text));
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(tr('copied'))),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  element.text,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    height: 1.5,
                                                    color: Theme.of(context).colorScheme.primary,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return TextSpan(
                                              text: element.text,
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            );
                                          }
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                                if (memory.imagePaths != null && memory.imagePaths!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: Platform.isWindows ? 100 : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Row(
                                        children: memory.imagePaths!.map((path) {
                                          if (Platform.isWindows) {
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.only(right: 8),
                                              child: GestureDetector(
                                                onTap: () => _showImageLightbox(path),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.file(
                                                    File(path),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                      child: const Icon(Icons.broken_image_outlined),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                                child: GestureDetector(
                                                  onTap: () => _showImageLightbox(path),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: AspectRatio(
                                                      aspectRatio: memory.imagePaths!.length == 1 ? 16/9 : 1,
                                                      child: Image.file(
                                                        File(path),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => Container(
                                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                          child: const Icon(Icons.broken_image_outlined),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (memory.deadline != null)
                                      Builder(
                                        builder: (context) {
                                          final now = DateTime.now();
                                          final today = DateTime(now.year, now.month, now.day);
                                          final deadlineDate = DateTime(memory.deadline!.year, memory.deadline!.month, memory.deadline!.day);
                                          final daysUntil = deadlineDate.difference(today).inDays;

                                          Color badgeColor;
                                          Color textColor;
                                          String text;

                                          if (daysUntil < 0) {
                                            badgeColor = Theme.of(context).colorScheme.errorContainer;
                                            textColor = Theme.of(context).colorScheme.error;
                                          } else if (daysUntil == 0) {
                                             badgeColor = Colors.orange.withValues(alpha: 0.2);
                                             textColor = Colors.orange.shade900;
                                          } else if (daysUntil < 3) {
                                            // Red: < 3 days
                                            badgeColor = Theme.of(context).colorScheme.errorContainer;
                                            textColor = Theme.of(context).colorScheme.error;
                                          } else if (daysUntil <= 5) {
                                            // Yellow: 3 to 5 days
                                             badgeColor = Colors.amber.withValues(alpha: 0.2);
                                             textColor = Colors.amber.shade900;
                                          } else {
                                            // Green: > 5 days
                                            badgeColor = Colors.green.withValues(alpha: 0.2);
                                            textColor = Colors.green.shade800;
                                          }

                                          text = AppTranslations.getDaysRemaining(widget.currentLocale.languageCode, daysUntil);

                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.access_time, size: 12, color: textColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  text,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      ),
                                    Text(
                                      _formatDate(memory.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: _isSelectionMode
        ? FloatingActionButton.extended(
            onPressed: _deleteSelectedMemories,
            icon: const Icon(Icons.delete),
            label: Text(tr('delete')),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          )
        : FloatingActionButton(
            onPressed: () => _showMemoryDialog(),
            child: const Icon(Icons.add),
          ),
      ),
    ));
  }

  String _getEmojiForCategory(String categoryName) {
    try {
      return _categories.firstWhere((c) => c.name == categoryName).emoji;
    } catch (_) {
      return '📁';
    }
  }

  Color _getCategoryColor(String category) {
    if (category == 'Shopping') {
      return Colors.orange;
    }
    if (category == 'Work') {
      return Colors.blue;
    }
    if (category == 'Learning') {
      return Colors.green;
    }
    if (category == 'Free time') {
      return Colors.purple;
    }
    if (category == 'Custom') {
      return Colors.grey;
    }
    
    // Generate a consistent color for user defined categories
    final int hash = category.hashCode;
    final List<Color> colors = [
      Colors.pink, Colors.teal, Colors.indigo, Colors.cyan, 
      Colors.amber, Colors.deepOrange, Colors.lime, Colors.brown
    ];
    return colors[hash.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    return AppTranslations.getTimeAgo(widget.currentLocale.languageCode, date);
  }

}

class _PremiumBadge extends StatefulWidget {
  final Color primaryColor;
  final bool isDarkMode;

  const _PremiumBadge({
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  State<_PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<_PremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    // ..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a premium gradient based on theme
    final gradientColors = widget.isDarkMode
        ? [
            widget.primaryColor,
            widget.primaryColor.withValues(alpha: 0.8),
            Colors.amber.shade400,
          ]
        : [
            Colors.amber.shade600,
            widget.primaryColor,
            Colors.purple.shade400,
          ];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
