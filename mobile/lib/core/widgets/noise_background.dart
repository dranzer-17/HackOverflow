import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle grain texture overlay on all backgrounds (CustomPainter).
class NoiseBackground extends StatelessWidget {
  const NoiseBackground({
    super.key,
    this.child,
    this.opacity = 0.03,
  });

  final Widget? child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NoisePainter(opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (var y = 0.0; y < size.height; y += 2) {
      for (var x = 0.0; x < size.width; x += 2) {
        final gray = random.nextInt(256);
        final paint = Paint()
          ..color = Color.fromRGBO(gray, gray, gray, opacity)
          ..strokeWidth = 1;
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
