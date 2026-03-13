import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Brutalist 2px ember horizontal rule with section label.
class EmberDivider extends StatelessWidget {
  const EmberDivider({
    super.key,
    required this.label,
    this.thickness = 2,
  });

  final String label;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.tag.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: thickness,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
