import 'package:flutter/material.dart';
import 'package:my_app/app_translations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final Locale currentLocale;

  const PrivacyPolicyPage({super.key, required this.currentLocale});

  String tr(String key) => AppTranslations.get(currentLocale.languageCode, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('privacy_policy_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, tr('privacy_intro_title')),
            _buildSectionText(context, tr('privacy_intro_desc')),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, tr('privacy_data_title')),
            _buildSectionText(context, tr('privacy_data_desc')),
            const SizedBox(height: 24),

            _buildSectionTitle(context, tr('terms_pricing_title')),
            _buildSectionText(context, tr('terms_pricing_desc')),
            const SizedBox(height: 24),

            _buildSectionTitle(context, tr('privacy_liability_title')),
            _buildSectionText(context, tr('privacy_liability_desc')),
            const SizedBox(height: 24),

            _buildSectionTitle(context, tr('privacy_changes_title')),
            _buildSectionText(context, tr('privacy_changes_desc')),
            
            const SizedBox(height: 48),
            Center(
               child: Text(
                '${tr('last_updated')}: 23 Dec 2025',
                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontStyle: FontStyle.italic),
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
