import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool showButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showButton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark mode
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ----------- APP NAME -----------
              const Text(
                "Spot It",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Optional tagline – you can remove if not needed
              const Text(
                "Campus Lost & Found",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // ------------ LOTTIE ANIMATION -----------
              Lottie.asset(
                'assets/animations/intro.json', // your new animation path
                width: 260,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // ------------ GET STARTED BUTTON -----------
              AnimatedOpacity(
                opacity: showButton ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
