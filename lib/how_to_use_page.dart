import 'package:flutter/material.dart';
import 'package:my_app/app_translations.dart';

class HowToUsePage extends StatelessWidget {
  final Locale currentLocale;

  const HowToUsePage({super.key, required this.currentLocale});

  String tr(String key) => AppTranslations.get(currentLocale.languageCode, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('how_to_use')),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.keyboard,
            titleKey: 'tip_shortcuts_title',
            descKey: 'tip_shortcuts_desc',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.checklist_rtl_rounded,
            titleKey: 'tip_long_press_title',
            descKey: 'tip_long_press_desc',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.diamond_outlined,
            titleKey: 'tip_pro_mode_title',
            descKey: 'tip_pro_mode_desc',
            color: Colors.amber,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.swipe_left_rounded,
            titleKey: 'tip_swipe_title',
            descKey: 'tip_swipe_desc',
            color: Colors.red,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.link_rounded,
            titleKey: 'tip_smart_links_title',
            descKey: 'tip_smart_links_desc',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.timer_outlined,
            titleKey: 'tip_deadlines_title',
            descKey: 'tip_deadlines_desc',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.category_outlined,
            titleKey: 'tip_categories_title',
            descKey: 'tip_categories_desc',
            color: Colors.teal,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String descKey,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(titleKey),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr(descKey),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
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
