import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    int fullStars = (rating / 2).floor();
    bool hasHalfStar = (rating / 2) % 1 >= 0.5;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: isDarkMode ? Colors.amber[300] : Colors.amber, size: 24);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: isDarkMode ? Colors.amber[300] : Colors.amber, size: 24);
        } else {
          return Icon(Icons.star_border, color: isDarkMode ? Colors.grey[600] : Colors.grey, size: 24);
        }
      }),
    );
  }
}
