import 'package:flutter/material.dart';
import 'package:my_app/app_translations.dart';
import 'package:my_app/notification_service.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final Function() onToggleTheme;
  final Locale currentLocale;
  final Function(Locale) onToggleLanguage;
  final bool showAds;
  final Function(bool) onToggleAds;
  final bool canRemoveAds;
  final bool isProMode;
  final Function(bool) onToggleProMode;
  final Color? customBackgroundColor;
  final Color? customAccentColor;
  final Function(Color?, Color?) onUpdateCustomTheme;
  final String? currentFontFamily;
  final Function(String?) onUpdateFontFamily;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onToggleLanguage,
    required this.showAds,
    required this.onToggleAds,
    required this.canRemoveAds,
    required this.isProMode,
    required this.onToggleProMode,
    required this.customBackgroundColor,
    required this.customAccentColor,
    required this.onUpdateCustomTheme,
    required this.currentFontFamily,
    required this.onUpdateFontFamily,
  });

  String tr(String key) => AppTranslations.get(currentLocale.languageCode, key);

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

  void _showLanguageDialog(BuildContext context) {
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
              _buildLanguageOption(context, 'English', 'en'),
              _buildLanguageOption(context, 'العربية', 'ar'),
              _buildLanguageOption(context, 'Français', 'fr'),
              _buildLanguageOption(context, 'Español', 'es'),
              _buildLanguageOption(context, 'Deutsch', 'de'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    final isSelected = currentLocale.languageCode == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        onToggleLanguage(Locale(code));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildColorPicker(BuildContext context, String title, List<Color> colors, Color? selectedColor, Function(Color) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = selectedColor?.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected 
                        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) 
                        : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)
                    ]
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings')), 
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(tr('language')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLanguageName(currentLocale.languageCode), 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(tr('dark_mode')),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (val) => onToggleTheme(),
          ),
          if (canRemoveAds) ...[
            const Divider(),
            SwitchListTile(
              title: const Text('Show Ads'),
              secondary: const Icon(Icons.ad_units),
              value: showAds,
              onChanged: (val) => onToggleAds(val),
            ),
          ],
          
          const Divider(),
           SwitchListTile(
            title: Text(tr('pro_mode')),
            subtitle: isProMode ? Text(tr('advanced_features_title'), style: const TextStyle(fontSize: 12, color: Colors.green)) : null,
            secondary: Icon(Icons.verified_user, color: isProMode ? Colors.amber : null),
            value: isProMode,
            onChanged: (val) => onToggleProMode(val),
          ),

          if (isProMode) ...[
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Text(tr('customize_theme'), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
             ),
             _buildColorPicker(
               context, 
               tr('background_color'), 
               [
                 const Color(0xFFF2F2F7), // Default Light Gray
                 const Color(0xFFE3F2FD), // Light Blue
                 const Color(0xFFFCE4EC), // Light Pink
                 const Color(0xFFE8F5E9), // Light Green
                 const Color(0xFFFFF3E0), // Light Orange
                 const Color(0xFFEDE7F6), // Lavender
                 const Color(0xFFFFFDE7), // Cream
                 const Color(0xFFE0F2F1), // Mint
               ], 
               customBackgroundColor ?? (isDarkMode ? const Color(0xFF121212) : const Color(0xFFF2F2F7)), 
               (color) => onUpdateCustomTheme(color, customAccentColor)
             ),
             const SizedBox(height: 16),
             _buildColorPicker(
               context, 
               tr('accent_color'), 
               [
                 const Color(0xFF6200EE), // Default Purple
                 const Color(0xFFFF5722), // Deep Orange
                 const Color(0xFF00C853), // Green
                 const Color(0xFFFFC107), // Amber
                 const Color(0xFF2196F3), // Blue
                 const Color(0xFFE91E63), // Pink
               ], 
               customAccentColor ?? const Color(0xFF6200EE), 
               (color) => onUpdateCustomTheme(customBackgroundColor, color)
             ),
             const SizedBox(height: 16),
             _buildFontPicker(context),
             const SizedBox(height: 16),
             TextButton(
               onPressed: () {
                 onUpdateCustomTheme(null, null);
                 onUpdateFontFamily(null);
               },
               child: Text(tr('reset_theme')),
             ),
             const SizedBox(height: 20),
          ],
          const Divider(),
           ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Test Notification'),
            subtitle: const Text('Click to verify notifications work'),
            onTap: () async {
              await NotificationService().showImmediateNotification(
                'LISTO Test', 
                'This is a test notification from LISTO!',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification Sent! Check your tray.')),
                );
              }
            },
           ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFontPicker(BuildContext context) {
    final fonts = [
      {'name': tr('font_default'), 'value': null},
      {'name': tr('font_cairo'), 'value': 'Cairo'},
      {'name': tr('font_tajawal'), 'value': 'Tajawal'},
      {'name': tr('font_comic'), 'value': 'Comic'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(tr('font_style'), style: Theme.of(context).textTheme.titleSmall),
        ),
        Theme(
           data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardColor),
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Wrap(
               spacing: 8,
               children: fonts.map((font) {
                 final isSelected = currentFontFamily == font['value'];
                 return ChoiceChip(
                   label: Text(font['name'] as String),
                   selected: isSelected,
                   onSelected: (selected) {
                     if (selected) onUpdateFontFamily(font['value']);
                   },
                 );
               }).toList(),
             ),
           ),
        ),
      ],
    );
  }
}
