// screens/splash/splash_screen.dart
// Animated splash screen with cyber aesthetic

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize library data
    await context.read<LibraryProvider>().initialize();

    // Minimum splash duration for branding effect
    await Future.delayed(const Duration(milliseconds: 2800));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Animated background grid
          Positioned.fill(child: _AnimatedGrid()),

          // Radial glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6 + _pulseController.value * 0.15,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.12),
                      AppTheme.primaryPurple.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                _LogoWidget()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 28),

                // App name
                Text(
                  'NetShelf',
                  style: GoogleFonts.spaceMono(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Your Digital Tech Library',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.darkTextSecondary,
                    letterSpacing: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms),

                const SizedBox(height: 60),

                // Loading indicator
                _LoadingBar()
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms),
              ],
            ),
          ),

          // Bottom credits
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: AppTheme.darkTextMuted,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 1500.ms),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.wifi_rounded, color: Colors.white, size: 28),
          Positioned(
            bottom: 18,
            right: 18,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 14, color: AppTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatefulWidget {
  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _animation.value,
                minHeight: 3,
                backgroundColor: AppTheme.darkBorder,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading library...',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: AppTheme.darkTextMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGrid extends StatefulWidget {
  @override
  State<_AnimatedGrid> createState() => _AnimatedGridState();
}

class _AnimatedGridState extends State<_AnimatedGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _GridPainter(_controller.value),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.06)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    final offset = progress * spacing;

    for (double x = -spacing + (offset % spacing); x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -spacing + (offset % spacing); y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.progress != progress;
}
