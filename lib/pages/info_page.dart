import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Good Gut',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Good Gut helps you track your daily intake of fruits and vegetables, '
              'aiming to increase the diversity of plants in your diet. Research shows '
              'that eating 30+ different plants weekly can significantly improve gut health.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your daily produce, set goals, and view your progress over time '
              'to build better eating habits and improve your gut microbiome.',
            ),
            const Spacer(),
            Center(
              child: FilledButton(
                onPressed: () async {
                  await AuthService().signOut();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFED4040),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
