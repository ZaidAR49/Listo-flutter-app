import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/app_translations.dart';
import 'package:my_app/privacy_policy_page.dart';
//
class AboutPage extends StatelessWidget {
  final Locale currentLocale;

  const AboutPage({super.key, required this.currentLocale});

  String tr(String key) => AppTranslations.get(currentLocale.languageCode, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('about')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'LISTO',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              tr('created_by'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              tr('app_description'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              tr('privacy_terms'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage(currentLocale: currentLocale))
                );
              },
              child: Row(
                children: [
                  Text(
                    tr('view_full_policy'),
                    style: TextStyle(
                      fontSize: 14, 
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              tr('contact'),
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 20),
                const SizedBox(width: 8),
                const Text('zaidradaideh.dev@gmail.com'),
              ],
            ),
            const SizedBox(height: 12),
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
              child: Row(
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'https://zar.onrender.com/',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Text(
                    'Version 1.0.1',
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
    );
  }
}
