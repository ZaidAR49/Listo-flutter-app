
import 'package:flutter/material.dart';
import 'package:my_app/notification_service.dart';
import 'package:my_app/error_page.dart';

class TestModePage extends StatefulWidget {
  const TestModePage({super.key});

  @override
  State<TestModePage> createState() => _TestModePageState();
}

class _TestModePageState extends State<TestModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Test Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await NotificationService().showImmediateNotification(
                  'Test Notification',
                  'This is a test notification from Test Mode',
                );
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Notification sent!')),
                   );
                }
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Trigger Test Notification'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ErrorPage(
                      details: FlutterErrorDetails(
                        exception: Exception('Simulated Test Exception'),
                        stack: StackTrace.current,
                        library: 'Test Mode',
                        context: ErrorDescription('User manually triggered error page'),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.error_outline),
              label: const Text('Go to Error Page'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
