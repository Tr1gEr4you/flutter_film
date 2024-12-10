import 'package:flutter/material.dart';


class MovieCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String year;
  final VoidCallback onTap;

  MovieCard({
    required this.title,
    required this.posterUrl,
    required this.year,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withOpacity(0.3),  // Добавляем эффект волны
      borderRadius: BorderRadius.circular(8),  // Скругление для эффекта волны
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),  // Скругление углов карточки
        ),
        color: isDarkMode ? Colors.grey[800] : Colors.white,  // Цвет фона карточки
        child: Row(
          children: [
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),  // Скругление верхнего левого угла
                  bottomLeft: Radius.circular(8),  // Скругление нижнего левого угла
                ),
                image: DecorationImage(
                  image: NetworkImage(posterUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,  // Цвет текста
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      year,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Цвет текста
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}