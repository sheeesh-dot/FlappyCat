import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _cloudController;
  late Animation<double> _cloudAnimation;
  late AnimationController _mouthController;
  late Animation<double> _mouthAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  final List<Map<String, double>> _clouds = [
    {'offset': 0.8, 'top': 60, 'size': 100, 'speed': 1.0},   // Small, fast, high
    {'offset': 0.3, 'top': 150, 'size': 150, 'speed': 0.7},  // Medium, medium speed, mid
    {'offset': 0.6, 'top': 250, 'size': 120, 'speed': 0.5},  // Small, slow, low
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
    _floatController.repeat(reverse: true);

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _pulseController.repeat(reverse: true);

    _cloudController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    _cloudAnimation = Tween<double>(
      begin: 1.0,
      end: -0.5,
    ).animate(
      CurvedAnimation(
        parent: _cloudController,
        curve: Curves.linear,
      ),
    );
    _cloudController.repeat();

    _mouthController = AnimationController(
      duration: const Duration(milliseconds: 300), // Fast mouth open/close
      vsync: this,
    );

    _mouthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mouthController,
        curve: Curves.easeInOut,
      ),
    );

    // Create a pattern: closed -> open -> closed -> pause -> repeat
    _animateMouth();

    _playBackgroundMusic();
  }

// NEW: Function to create mouth animation pattern
  void _animateMouth() async {
    while (mounted) {  // Keep animating while widget is alive
      // Open mouth
      await _mouthController.forward();
      await Future.delayed(const Duration(milliseconds: 100));

      // Close mouth
      await _mouthController.reverse();
      await Future.delayed(const Duration(milliseconds: 150));

      // Quick double blink effect (optional - makes it funnier!)
      await _mouthController.forward();
      await Future.delayed(const Duration(milliseconds: 80));
      await _mouthController.reverse();
      await Future.delayed(const Duration(milliseconds: 80));

      // Pause before next cycle
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.0);
      await _audioPlayer.play(AssetSource('sounds/background_music.wav'));
      _fadeInMusic();
      print('Background music started with fade-in');
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  void _fadeInMusic() {
    const fadeDuration = 2.0;
    const steps = 20;
    final stepDuration = Duration(milliseconds: (fadeDuration * 1000 / steps).round());
    int currentStep = 0;

    Timer.periodic(stepDuration, (timer) {
      currentStep++;
      double volume = currentStep / steps;
      _audioPlayer.setVolume(volume);
      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _audioPlayer.setVolume(0.0);
      } else {
        _audioPlayer.setVolume(1.0);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _cloudController.dispose();
    _mouthController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  Widget _buildCloud(int index) {
    final cloud = _clouds[index];
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _cloudAnimation,
      builder: (context, child) {
        // Each cloud moves at different speed
        double position = (_cloudAnimation.value + cloud['offset']!) % 1.5 - 0.5;

        return Positioned(
          left: position * screenWidth,
          top: cloud['top']!,
          child: Opacity(
            opacity: 0.5 + (index * 0.1),  // Varying opacity for depth
            child: Image.asset(
              'assets/images/cloud.png',
              width: cloud['size']!,
              height: cloud['size']! * 0.6,  // Maintain aspect ratio
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
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
              // Multiple cloud layers
              ..._clouds.asMap().entries.map((entry) => _buildCloud(entry.key)),

              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _toggleMute();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ),

              // Main content (in the Stack, after the clouds)
              Center(  // ← Wrap the entire Column in Center
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,  // ← Don't expand unnecessarily
                  children: [
                    // Game Title
                    Text(
                      'FLAPPY CAT',
                      textAlign: TextAlign.center,  // ← Center the text
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            offset: const Offset(-2, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Animated Cat with mouth sprite switching
                    AnimatedBuilder(
                      animation: Listenable.merge([_floatAnimation, _mouthAnimation]),  // ← Listen to both animations
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),  // Floating motion
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),  // Smooth transition between sprites
                            child: Image.asset(
                              // Switch between open and closed mouth based on animation value
                              _mouthAnimation.value > 0.5
                                  ? 'assets/images/cat_open.png'
                                  : 'assets/images/cat_closed.png',
                              key: ValueKey<bool>(_mouthAnimation.value > 0.5),  // Key for AnimatedSwitcher
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),

                    // Play button (same as before)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            SlidePageRoute(page: const GameScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: const Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GAME STARTS HERE',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              Text(
                '(Gameplay logic would go here)',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'BACK TO START',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
    transitionDuration: Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var slideTween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: curve));
      var slideAnimation = animation.drive(slideTween);

      var fadeTween = Tween(begin: 0.0, end: 1.0);
      var fadeAnimation = animation.drive(fadeTween);

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}