import 'package:flutter/material.dart';
import 'home/items_page.dart';
import 'screens/intro_screen.dart';   // <-- ADD THIS IMPORT
import 'screens/login_page.dart';    // <-- ADD THIS IMPORT (create login_page.dart)

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,

      // DARK THEME (your original)
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      // START THE APP WITH INTRO SCREEN
      initialRoute: '/',

      routes: {
        '/': (context) => const IntroScreen(),   // <-- Lottie intro screen
        '/login': (context) => const LoginPage(), // <-- Login screen
        '/home': (context) => ItemsPage(),       // <-- Your existing home
      },
    );
  }
}
