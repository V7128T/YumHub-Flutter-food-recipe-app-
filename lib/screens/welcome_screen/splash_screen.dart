import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _letterAnimations;
  late Animation<Offset> _forkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Set up animations for each letter
    _letterAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, (index * 0.1 + 0.6).clamp(0.0, 1.0),
              curve: Curves.easeOut),
        ),
      );
    });

    // Set up animation for the fork
    _forkAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1, curve: Curves.elasticOut),
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated letters
            ..._buildAnimatedLetters(),
            // Animated fork
            SlideTransition(
              position: _forkAnimation,
              child: const Text('🍴', style: TextStyle(fontSize: 40)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedLetters() {
    const String text = 'YumHub';
    return List.generate(text.length, (index) {
      return FadeTransition(
        opacity: _letterAnimations[index],
        child: Text(
          text[index],
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: index < 3 ? Colors.red : Colors.orange,
          ),
        ),
      );
    });
  }
}
