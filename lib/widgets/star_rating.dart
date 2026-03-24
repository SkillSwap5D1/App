import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const StarRating({
    required this.rating,
    required this.reviewCount,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: AppColors.star, size: size),
        SizedBox(width: 4),
        Text(
          '$rating',
          style: TextStyle(
            fontSize: size - 2,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: TextStyle(
            fontSize: size - 4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
