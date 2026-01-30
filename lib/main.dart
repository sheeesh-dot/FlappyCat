import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Cat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF4A90E2),
            ],
          ),
        ),
        child: SafeArea(
          // Stack allows us to layer widgets on top of each other
          child: Stack(
            children: [
              // Column arranges widgets vertically
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Title
                  Text(
                    'FLAPPY CAT',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(4, 4),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: Colors.orange.withOpacity(0.3),
                          offset: Offset(-2, -2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),

                  // Cat Image
                  Image.asset(
                    'assets/images/cat.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 60),

                  // Play Button
                  ElevatedButton(
                    // onPressed defines what happens when button is tapped
                    onPressed: () {
                      print('Play button pressed!');
                    },
                    // Style customizes the button appearance
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button background color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                      ),
                      elevation: 8, // Shadow depth
                      shadowColor: Colors.black.withOpacity(0.5),
                    ),
                    child: Text(
                      'PLAY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}