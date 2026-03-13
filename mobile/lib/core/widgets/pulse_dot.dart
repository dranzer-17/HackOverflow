import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Status indicator as glowing ember pulse (not text label).
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.size = 10,
    this.active = true,
    this.color,
  });

  final double size;
  final bool active;
  final Color? color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scale = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.ember;
    if (!widget.active) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.smog.withValues(alpha: 0.5),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: widget.size * _scale.value,
        height: widget.size * _scale.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: _opacity.value),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
