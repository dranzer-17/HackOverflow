import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Terminal-style loading: text types out letter by letter with blinking cursor.
class TerminalLoader extends StatefulWidget {
  const TerminalLoader({
    super.key,
    this.prefix = '> ',
    this.message = 'LOADING...',
    this.cursorChar = '▌',
    this.onComplete,
  });

  final String prefix;
  final String message;
  final String cursorChar;
  final VoidCallback? onComplete;

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late AnimationController _typeController;
  int _visibleLength = 0;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);

    _typeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.message.length * 40),
    );
    _typeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
    _typeController.forward();

    final interval = 1.0 / widget.message.length;
    for (var i = 0; i <= widget.message.length; i++) {
      final t = i * interval;
      _typeController.addListener(() {
        if (_typeController.value >= t - 0.01 && _visibleLength < i && mounted) {
          setState(() => _visibleLength = i);
        }
      });
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.message.substring(0, _visibleLength.clamp(0, widget.message.length));
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.prefix,
          style: AppTypography.terminalPrefix,
        ),
        Text(
          visible,
          style: AppTypography.bodyMedium,
        ),
        AnimatedBuilder(
          animation: _cursorController,
          builder: (_, __) => Text(
            _cursorController.value > 0.5 ? widget.cursorChar : '',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.ember),
          ),
        ),
      ],
    );
  }
}
