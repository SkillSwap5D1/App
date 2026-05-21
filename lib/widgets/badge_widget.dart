import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class BadgeWidget extends StatelessWidget {
  final int count;
  final Widget child;
  final Color backgroundColor;
  final Color textColor;

  const BadgeWidget({
    super.key,
    required this.count,
    required this.child,
    this.backgroundColor = AppColors.pastelGreenDeep,
    this.textColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
