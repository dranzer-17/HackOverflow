import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Card matching website: bg-card, border, rounded-xl, optional gradient overlay.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.title,
    this.titleIcon,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? title;
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Subtle gradient overlay (website style)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.foreground.withValues(alpha: 0.03),
                      Colors.transparent,
                      AppColors.foreground.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Row(
                      children: [
                        if (titleIcon != null) ...[
                          Icon(titleIcon, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          title!,
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
