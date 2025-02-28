import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:good_gut/pages/login_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good_gut/pages/home_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize the database path
  await getDatabasesPath();
  // Initialize Google Mobile Ads
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        color.red + ((ds < 0 ? color.red : (255 - color.red)) * ds).round(),
        color.green +
            ((ds < 0 ? color.green : (255 - color.green)) * ds).round(),
        color.blue + ((ds < 0 ? color.blue : (255 - color.blue)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Good Gut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(
            const Color(0xFF8ABE46),
          ),
          brightness: Brightness.light,
        ).copyWith(
          onSurface: const Color(0xFF071013),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
