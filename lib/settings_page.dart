import 'package:flutter/material.dart';
import 'package:my_app/app_translations.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final Function() onToggleTheme;
  final Locale currentLocale;
  final Function(Locale) onToggleLanguage;
  final bool showAds;
  final Function(bool) onToggleAds;
  final bool canRemoveAds; // New variable to control visibility of the toggle

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onToggleLanguage,
    required this.showAds,
    required this.onToggleAds,
    required this.canRemoveAds,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings') ?? 'Settings'), // Fallback if 'settings' key missing
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
        ],
      ),
    );
  }
}
