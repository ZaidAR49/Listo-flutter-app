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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'package:my_app/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';

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
  AdService().initialize();
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


  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
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

  @override
  Widget build(BuildContext context) {
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
        textTheme: GoogleFonts.outfitTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF0F0F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6200EE),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
        textTheme: GoogleFonts.outfitTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBB86FC),
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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFBB86FC),
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleLanguage: _changeLanguage,
        currentLocale: _locale,
        showAds: _showAds,
        onToggleAds: _toggleAds,
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

  const MemoryHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onToggleLanguage,
    required this.currentLocale,
    required this.showAds,
    required this.onToggleAds,
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
      if (widget.showAds) {
        _loadBannerAd();
      } else {
        _disposeBannerAd();
      }
    }
  }

  @override
  void dispose() {
    _disposeBannerAd();
    super.dispose();
  }

  void _loadBannerAd() {
    if (!widget.showAds) return; // Don't load if disabled
    
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      },
      onRetryWithTestId: () {
        if (mounted) {
           setState(() {
              _isBannerAdLoaded = false;
              _bannerAd = null;
           });
           _loadBannerAd(); // Retry with the new Test ID
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
    if (name.trim().isEmpty) return;
    if (_categories.any((c) => c.name == name.trim())) return;
    
    setState(() {
      _categories.add(Category(name: name.trim(), emoji: emoji.trim().isEmpty ? '📁' : emoji.trim()));
    });
    _saveCategories();
  }

  void _deleteCategory(Category category) {
    if (_categories.length <= 1) return; // Prevent deleting last category
    setState(() {
      _categories.removeWhere((c) => c.name == category.name);
      if (_selectedCategoryName == category.name) {
        _selectedCategoryName = 'All';
      }
    });
    _saveCategories();
  }

  void _addOrUpdateMemory(String content, String categoryName, {String? id, DateTime? deadline}) {
    if (content.trim().isEmpty) return;

    if (id == null) {
      final newItem = MemoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
        content: content.trim(),
        timestamp: DateTime.now(),
        category: categoryName,
        deadline: deadline,
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
        });

        if (deadline != null) {
          _scheduleDeadlineNotification(_memories[index]);
        }
      }
    }
    _saveMemories();
  }

  void _scheduleDeadlineNotification(MemoryItem item) {
    if (item.deadline == null) return;
    
    final scheduledDate = item.deadline!.subtract(const Duration(days: 1));
    if (scheduledDate.isAfter(DateTime.now())) {
      NotificationService().scheduleNotification(
        item.id.hashCode,
        'Deadline Approaching: ${item.category}',
        'Reminder: ${item.content} is due tomorrow!',
        scheduledDate,
      );
    }
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

  void _showAppAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 10),
              Text(tr('about_title')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('created_by'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('app_description'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  tr('privacy_terms'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('privacy_policy'),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  tr('contact'),
                   style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('zaidradaideh.dev@gmail.com'),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse('https://zar.onrender.com/');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('error_link'))),
                        );
                      }
                    }
                  },
                  child: Text(
                    'https://zar.onrender.com/',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                           fontSize: 12,
                           color: Theme.of(context).colorScheme.outline
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        '© ${DateTime.now().year} Zaid Radaideh',
                        style: TextStyle(
                           fontSize: 12,
                           color: Theme.of(context).colorScheme.outline
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('close')),
            ),
          ],
        );
      },
    );
  }

  void _showMemoryDialog({MemoryItem? item}) {
    final TextEditingController textController = TextEditingController(text: item?.content ?? '');
    String selectedCategoryName = item?.category ?? (_selectedCategoryName == 'All' && _categories.isNotEmpty ? _categories.first.name : _selectedCategoryName);

    // Fallback if category doesn't exist
    if (!_categories.any((c) => c.name == selectedCategoryName) && selectedCategoryName != 'All') {
      if (_categories.isNotEmpty) selectedCategoryName = _categories.first.name;
    }
    if (selectedCategoryName == 'All' && _categories.isNotEmpty) {
      selectedCategoryName = _categories.first.name;
    }

    DateTime? selectedDeadline = item?.deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView( // Wrap in SingleChildScrollView to fix overflow
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
                  TextField(
                    controller: textController,
                    autofocus: true,
                    maxLines: 6,
                    minLines: 3,
                    maxLength: 1000,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: tr('memory_hint'),
                    ),
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
                      _addOrUpdateMemory(
                        textController.text, 
                        selectedCategoryName, 
                        id: item?.id,
                        deadline: selectedDeadline, // Pass the deadline
                      );
                      Navigator.pop(context);
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

    return Scaffold(
      bottomNavigationBar: (_isBannerAdLoaded && widget.showAds && _bannerAd != null)
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
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
                    Image.asset(
                      'assets/logo.png',
                      height: 64,
                      fit: BoxFit.contain,
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategoryName == 'All' 
                          ? tr('no_memories') 
                          : '${tr('no_cat_memories')} $_selectedCategoryName',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                        color: _getCategoryColor(memory.category).withOpacity(0.15),
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
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                      tooltip: tr('delete'),
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
                                             badgeColor = Colors.orange.withOpacity(0.2);
                                             textColor = Colors.orange.shade900;
                                          } else if (daysUntil < 3) {
                                            // Red: < 3 days
                                            badgeColor = Theme.of(context).colorScheme.errorContainer;
                                            textColor = Theme.of(context).colorScheme.error;
                                          } else if (daysUntil <= 5) {
                                            // Yellow: 3 to 5 days
                                             badgeColor = Colors.amber.withOpacity(0.2);
                                             textColor = Colors.amber.shade900;
                                          } else {
                                            // Green: > 5 days
                                            badgeColor = Colors.green.withOpacity(0.2);
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
    );
  }

  String _getEmojiForCategory(String categoryName) {
    try {
      return _categories.firstWhere((c) => c.name == categoryName).emoji;
    } catch (_) {
      return '📁';
    }
  }

  Color _getCategoryColor(String category) {
    if (category == 'Shopping') return Colors.orange;
    if (category == 'Work') return Colors.blue;
    if (category == 'Learning') return Colors.green;
    if (category == 'Free time') return Colors.purple;
    if (category == 'Custom') return Colors.grey;
    
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

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      case 'de': return 'Deutsch';
      case 'en': 
      default: return 'English';
    }
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('language'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption('English', 'en'),
              _buildLanguageOption('العربية', 'ar'),
              _buildLanguageOption('Français', 'fr'),
              _buildLanguageOption('Español', 'es'),
              _buildLanguageOption('Deutsch', 'de'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    final isSelected = widget.currentLocale.languageCode == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        widget.onToggleLanguage(Locale(code));
        Navigator.pop(context);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
