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

// StatefulWidget allows the widget to have changing state (animations)
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

// SingleTickerProviderStateMixin is needed for AnimationController
class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  // AnimationController manages the animation timing
  late AnimationController _floatController;
  // Animation defines the value range (vertical position)
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _floatController = AnimationController(
      duration: Duration(seconds: 2), // How long one cycle takes
      vsync: this, // Synchronizes animation with screen refresh
    );

    // Tween defines the animation range: from -10 to +10 pixels
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(
      // CurvedAnimation makes the movement smooth (not linear)
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut, // Smooth acceleration/deceleration
      ),
    );

    // Start the animation and make it repeat in reverse (up, down, up, down...)
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Always clean up controllers to prevent memory leaks
    _floatController.dispose();
    super.dispose();
  }

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
          child: Stack(
            children: [
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

                  // Animated Cat Image
                  // AnimatedBuilder rebuilds only this part when animation updates
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        // Offset moves the cat vertically based on animation value
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    // child is built once and reused (efficient)
                    child: Image.asset(
                      'assets/images/cat.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 60),

                  // Play Button
                  ElevatedButton(
                    onPressed: () {
                      print('Play button pressed!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
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