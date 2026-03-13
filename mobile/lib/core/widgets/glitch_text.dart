import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Glitch effect text — horizontal offset flicker animation.
class GlitchText extends StatefulWidget {
  const GlitchText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 80),
    this.offset = 2.0,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final double offset;

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetX;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _offsetX = Tween<double>(begin: 0, end: widget.offset).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTypography.displayLarge;
    return AnimatedBuilder(
      animation: _offsetX,
      builder: (context, _) {
        return Stack(
          children: [
            // Cyan/red shift layer (subtle)
            Positioned(
              left: _offsetX.value,
              child: Text(
                widget.text,
                style: style.copyWith(color: AppColors.emberWithOpacity(0.6)),
              ),
            ),
            Positioned(
              left: -_offsetX.value,
              child: Text(
                widget.text,
                style: style.copyWith(color: AppColors.goldWithOpacity(0.5)),
              ),
            ),
            Text(widget.text, style: style),
          ],
        );
      },
    );
  }
}
