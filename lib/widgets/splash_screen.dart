import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    bool lightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    return Scaffold(
      backgroundColor: lightMode
          ? const Color(0xFFFFFFFF) // White for light mode
          : const Color(0xFF1A1A1A), // Dark gray for dark mode
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/goodgut-logo.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            Text(
              'Good Gut',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: lightMode
                    ? const Color(0xFF8ABE46) // Primary green color
                    : const Color(0xFF9FD259), // Lighter green for dark mode
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
