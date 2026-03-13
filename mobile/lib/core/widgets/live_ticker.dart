import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Scrolling horizontal ticker at bottom (stock-ticker style).
class LiveTicker extends StatefulWidget {
  const LiveTicker({
    super.key,
    required this.items,
    this.height = 40,
    this.speed = 30.0,
  });

  final List<String> items;
  final double height;
  final double speed;

  @override
  State<LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<LiveTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.items.length * 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: -1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.items.join('  •  ');
    return Container(
      height: widget.height,
      decoration: BoxDecoration(color: AppColors.ash),
      clipBehavior: Clip.hardEdge,
      child: Builder(
        builder: (context) {
          final w = _textWidth(text);
          return AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: SizedBox(
                  width: w * 2 + 80,
                  height: widget.height,
                  child: Transform.translate(
                    offset: Offset(_animation.value * w, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tickerText(text),
                        const SizedBox(width: 80),
                        _tickerText(text),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _textWidth(String t) {
    final span = TextSpan(
      text: t,
      style: AppTypography.bodySmall,
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width + 80;
  }

  Widget _tickerText(String t) {
    return Text(
      t,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.smog,
        letterSpacing: 1,
      ),
    );
  }
}
