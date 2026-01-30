import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class AnimatedReflectionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedReflectionButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<AnimatedReflectionButton> createState() => _AnimatedReflectionButtonState();
}

class _AnimatedReflectionButtonState extends State<AnimatedReflectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 180,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background circles
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CirclesPainter(
                          progress: _controller.value,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32,
                        color: Colors.white,
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        )
                        .scale(
                          duration: 2000.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                        ),

                    const SizedBox(height: 16),

                    Text(
                      'Start Reflection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Voice, text, or both',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),

              // Shimmer effect on hover
              if (_isHovered)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ).animate().shimmer(duration: 1500.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw multiple animated circles
    for (int i = 0; i < 3; i++) {
      final offset = i * 0.33;
      final adjustedProgress = (progress + offset) % 1.0;
      final radius = size.width * 0.3 * (1 + adjustedProgress);
      final opacity = (1 - adjustedProgress) * 0.5;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        radius,
        paint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CirclesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
