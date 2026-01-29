import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const AnimatedSplashScreen({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation - dramatic entrance
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade animation - smooth appearance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Rotate animation - subtle rotation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeOutBack,
    ));

    // Pulse animation - heartbeat effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation - glowing effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Start animation sequence
    _startAnimationSequence();

    // Safety timeout - ensure splash screen doesn't get stuck
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        debugPrint('Splash screen safety timeout triggered');
        widget.onAnimationComplete();
      }
    });
  }

  void _startAnimationSequence() async {
    try {
      // Initial delay
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Start all animations
      _fadeController.forward();
      _scaleController.forward();
      _rotateController.forward();

      // Wait for main animations to complete
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      // Start pulse animation (repeating)
      _pulseController.repeat(reverse: true);

      // Start shimmer animation (repeating)
      _shimmerController.repeat(reverse: true);

      // Complete after total duration
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Fade out
      await _fadeController.reverse();

      if (!mounted) return;

      // Call completion callback
      debugPrint('Splash animation complete, calling onAnimationComplete');
      widget.onAnimationComplete();
    } catch (e) {
      debugPrint('Error in splash animation sequence: $e');
      // Ensure we still transition even if there's an error
      if (mounted) {
        widget.onAnimationComplete();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF1744), // Romantic red
              const Color(0xFFE91E63), // Pink accent
              const Color(0xFFC41230), // Darker red
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation,
                  _fadeAnimation,
                  _rotateAnimation,
                  _pulseAnimation,
                  _shimmerAnimation,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo with modern design
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(
                                          alpha: 0.2 + (_shimmerAnimation.value * 0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Main logo container
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.4 + (_shimmerAnimation.value * 0.4),
                                        ),
                                        blurRadius: 30 + (_shimmerAnimation.value * 20),
                                        spreadRadius: 8 + (_shimmerAnimation.value * 8),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFE91E63).withValues(alpha: 0.4),
                                        blurRadius: 50,
                                        spreadRadius: 3,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Image.asset(
                                      'assets/images/kei.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                // Rotating border accent
                                Transform.rotate(
                                  angle: _shimmerAnimation.value * 2 * 3.14159,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.5),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 50),

                            // Brand name with enhanced styling
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.white,
                                  ],
                                  stops: [
                                    _shimmerAnimation.value - 0.3,
                                    _shimmerAnimation.value,
                                    _shimmerAnimation.value + 0.3,
                                  ].map((s) => s.clamp(0.0, 1.0)).toList(),
                                ).createShader(bounds);
                              },
                              child: Column(
                                children: [
                                  const Text(
                                    'Simulizi za Mapenzi',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 3,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Tagline with icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_stories_outlined,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hadithi za Mapenzi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(
                              alpha: 0.5 + (_shimmerAnimation.value * 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final duration = 3000 + random.nextInt(4000);
    final size = 2.0 + random.nextDouble() * 4;
    final delay = random.nextInt(2000);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration),
      builder: (context, value, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * startX,
          top: MediaQuery.of(context).size.height * startY -
              (value * MediaQuery.of(context).size.height * 0.3),
          child: Opacity(
            opacity: (1 - value) * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
      },
    );
  }
}
