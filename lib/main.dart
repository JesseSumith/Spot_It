import 'package:flutter/material.dart';
import 'package:spot_it/screens/intro_screen.dart';
import 'package:spot_it/screens/auth/login_page.dart';

void main() {
  runApp(const SpotItApp());
}

class SpotItApp extends StatelessWidget {
  const SpotItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotIt - Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // 👇 we are using named routes now
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginPage(),

        // you can also add '/items': (context) => const ItemsPage(), etc.
      },
    );
  }
}
