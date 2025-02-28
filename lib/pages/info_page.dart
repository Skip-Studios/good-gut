import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/analytics_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView(screenName: 'info_page');
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _analytics.logFeatureUse(featureName: 'sign_out');
    } catch (e) {
      _analytics.logError(
        errorCode: 'sign_out_error',
        message: e.toString(),
      );
    }
  }

  Future<void> _launchURL(String url, String linkName) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _analytics.logFeatureUse(featureName: 'link_click_$linkName');
      }
    } catch (e) {
      _analytics.logError(
        errorCode: 'url_launch_error',
        message: 'Failed to launch $url: $e',
      );
    }
  }

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
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () => _launchURL(
                  'https://goodgutapp.com/privacy', 'privacy_policy'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Use'),
              onTap: () =>
                  _launchURL('https://goodgutapp.com/terms', 'terms_of_use'),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Support'),
              onTap: () =>
                  _launchURL('https://goodgutapp.com/support', 'support'),
            ),
            const Spacer(),
            Center(
              child: FilledButton(
                onPressed: () async {
                  await _signOut();
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
