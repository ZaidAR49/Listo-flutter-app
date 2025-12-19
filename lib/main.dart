import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/memory_model.dart';
import 'package:my_app/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ZarMemoryApp());
}

class ZarMemoryApp extends StatefulWidget {
  const ZarMemoryApp({super.key});

  @override
  State<ZarMemoryApp> createState() => _ZarMemoryAppState();
}

class _ZarMemoryAppState extends State<ZarMemoryApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LISTO',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
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
      ),
    );
  }
}

class MemoryHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MemoryHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _addOrUpdateMemory(String content, String categoryName, {String? id}) {
    if (content.trim().isEmpty) return;

    if (id == null) {
      final newItem = MemoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
        content: content.trim(),
        timestamp: DateTime.now(),
        category: categoryName,
      );
      setState(() {
        _memories.insert(0, newItem);
      });
    } else {
      final index = _memories.indexWhere((item) => item.id == id);
      if (index != -1) {
        setState(() {
          _memories[index].content = content.trim();
          _memories[index].timestamp = DateTime.now();
          _memories[index].category = categoryName;
        });
      }
    }
    _saveMemories();
  }

  void _deleteMemory(String id) {
    final deletedItem = _memories.firstWhere((item) => item.id == id);
    final int deletedIndex = _memories.indexOf(deletedItem);

    setState(() {
      _memories.removeWhere((item) => item.id == id);
    });
    _saveMemories();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memory deleted'),
        action: SnackBarAction(
          label: 'Undo',
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

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emojiController = TextEditingController(); // Simple generic emoji input
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 20,
                decoration: const InputDecoration(
                  hintText: 'Category Name (e.g., Ideas)',
                  labelText: 'Name',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                maxLength: 3,
                decoration: const InputDecoration(
                  hintText: 'Emoji (e.g., 💡)',
                  labelText: 'Emoji',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _addCategory(nameController.text, emojiController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
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
          title: const Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 10),
              Text('About LISTO'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Created by Zaid Radaideh ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'LISTO is a simple memory keeping app designed to help you organize your thoughts.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Privacy Policy & Terms',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This application operates locally on your device. We do not currently collect, store, or share any personal data.\n\nNote: Future versions may include advertising services (e.g., Google AdMob) which might collect standard usage data.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Contact',
                   style: TextStyle(fontWeight: FontWeight.bold),
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
                          const SnackBar(content: Text('Could not open link')),
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
              child: const Text('Close'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null ? 'New Memory' : 'Edit Memory',
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
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      _addOrUpdateMemory(textController.text, selectedCategoryName, id: item?.id);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Memory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
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
                    const Text(
                      'LISTO',
                      style: TextStyle(
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
              title: const Text('All Memories'),
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
                      'Categories',
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
                    title: const Text('Add Category'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddCategoryDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAppAboutDialog();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: widget.isDarkMode,
              onChanged: (val) => widget.onToggleTheme(),
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
                        _selectedCategoryName == 'All' ? 'No memories yet' : 'No $_selectedCategoryName memories',
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showMemoryDialog(item: memory),
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
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  memory.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
      floatingActionButton: FloatingActionButton(
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
    // Simple helper to format date nicely
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
           return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
