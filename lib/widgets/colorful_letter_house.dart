import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorfulLetterHouse extends StatelessWidget {
  final String letter;
  final double size;
  final VoidCallback onTap;
  final bool isUnlocked;

  const ColorfulLetterHouse({
    super.key,
    required this.letter,
    required this.size,
    required this.onTap,
    this.isUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.3,
        child: CustomPaint(
          painter: ColorfulHousePainter(
            letter: letter,
            isUnlocked: isUnlocked,
          ),
        ),
      ),
    );
  }
}

class ColorfulHousePainter extends CustomPainter {
  final String letter;
  final bool isUnlocked;

  ColorfulHousePainter({
    required this.letter,
    required this.isUnlocked,
  });

  Color _getHouseColor(String letter) {
    // Colores vibrantes para cada letra
    final colors = {
      'A': const Color(0xFFFF6B6B), // Rojo coral
      'B': const Color(0xFF4ECDC4), // Turquesa
      'C': const Color(0xFFFFE66D), // Amarillo
      'D': const Color(0xFF95E1D3), // Verde menta
      'E': const Color(0xFFFF8B94), // Rosa
      'F': const Color(0xFF9B59B6), // Púrpura
      'G': const Color(0xFF3498DB), // Azul
      'H': const Color(0xFF2ECC71), // Verde
      'I': const Color(0xFFE67E22), // Naranja
      'J': const Color(0xFFE74C3C), // Rojo
      'K': const Color(0xFF1ABC9C), // Verde azulado
      'L': const Color(0xFFF39C12), // Dorado
      'M': const Color(0xFF8E44AD), // Violeta
      'N': const Color(0xFF34495E), // Gris azulado
      'O': const Color(0xFFE91E63), // Rosa fucsia
      'P': const Color(0xFF00BCD4), // Cian
      'Q': const Color(0xFF4CAF50), // Verde claro
      'R': const Color(0xFFFF5722), // Naranja profundo
      'S': const Color(0xFF673AB7), // Púrpura profundo
      'T': const Color(0xFF009688), // Verde cerceta
      'U': const Color(0xFFFF9800), // Ámbar
      'V': const Color(0xFF795548), // Marrón
      'W': const Color(0xFF607D8B), // Gris azul
      'X': const Color(0xFFE91E63), // Rosa
      'Y': const Color(0xFF8BC34A), // Verde lima
      'Z': const Color(0xFF9C27B0), // Púrpura brillante
    };
    return colors[letter.toUpperCase()] ?? const Color(0xFF3498DB);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white;

    final houseColor = _getHouseColor(letter);
    
    // Dimensiones de la casa estilo cartoon
    final houseWidth = size.width * 0.85;
    final houseHeight = size.height * 0.5;
    final roofHeight = size.height * 0.3;
    
    final centerX = size.width / 2;
    final baseY = size.height * 0.9;
    
    // 1. Base/fundación de la casa
    paint.color = const Color(0xFF8B4513);
    final foundation = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 5),
        width: houseWidth + 8,
        height: 12,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(foundation, paint);

    // 2. Paredes principales (coloridas)
    paint.color = houseColor;
    final mainWalls = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - houseHeight / 2),
        width: houseWidth,
        height: houseHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(mainWalls, paint);
    canvas.drawRRect(mainWalls, strokePaint);

    // 3. Techo azul vibrante (como en la referencia)
    paint.color = const Color(0xFF2196F3);
    final roofPath = Path();
    final roofTop = baseY - houseHeight - roofHeight + 10;
    
    roofPath.moveTo(centerX - houseWidth / 2 - 10, baseY - houseHeight + 10);
    roofPath.lineTo(centerX, roofTop);
    roofPath.lineTo(centerX + houseWidth / 2 + 10, baseY - houseHeight + 10);
    roofPath.lineTo(centerX + houseWidth / 2, baseY - houseHeight + 15);
    roofPath.lineTo(centerX, roofTop + 8);
    roofPath.lineTo(centerX - houseWidth / 2, baseY - houseHeight + 15);
    roofPath.close();
    
    canvas.drawPath(roofPath, paint);
    canvas.drawPath(roofPath, strokePaint);

    // 4. Chimenea cute
    paint.color = const Color(0xFF8B4513);
    final chimney = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX + houseWidth / 3,
        roofTop + 10,
        12,
        25,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(chimney, paint);
    canvas.drawRRect(chimney, strokePaint);

    // 5. Humo de la chimenea
    paint.color = Colors.grey[300]!;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(
          centerX + houseWidth / 3 + 6 + (i * 2),
          roofTop + 5 - (i * 8),
        ),
        3.0 + i,
        paint,
      );
    }

    // 6. Puerta encantadora
    paint.color = const Color(0xFF8B4513);
    final door = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - 15),
        width: houseWidth * 0.25,
        height: houseHeight * 0.55,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(door, paint);
    canvas.drawRRect(door, strokePaint);

    // Manija de la puerta
    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(
      Offset(centerX + houseWidth * 0.08, baseY - 15),
      3,
      paint,
    );

    // 7. Ventanas adorables
    paint.color = const Color(0xFF87CEEB);
    // Ventana izquierda
    final leftWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - houseWidth * 0.25, baseY - houseHeight * 0.3),
        width: houseWidth * 0.2,
        height: houseWidth * 0.2,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftWindow, paint);
    canvas.drawRRect(leftWindow, strokePaint);

    // Ventana derecha
    final rightWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + houseWidth * 0.25, baseY - houseHeight * 0.3),
        width: houseWidth * 0.2,
        height: houseWidth * 0.2,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rightWindow, paint);
    canvas.drawRRect(rightWindow, strokePaint);

    // Marcos de ventanas
    strokePaint.strokeWidth = 1.5;
    strokePaint.color = Colors.white;
    // Cruz en ventana izquierda
    canvas.drawLine(
      Offset(centerX - houseWidth * 0.25, baseY - houseHeight * 0.4),
      Offset(centerX - houseWidth * 0.25, baseY - houseHeight * 0.2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX - houseWidth * 0.35, baseY - houseHeight * 0.3),
      Offset(centerX - houseWidth * 0.15, baseY - houseHeight * 0.3),
      strokePaint,
    );
    // Cruz en ventana derecha
    canvas.drawLine(
      Offset(centerX + houseWidth * 0.25, baseY - houseHeight * 0.4),
      Offset(centerX + houseWidth * 0.25, baseY - houseHeight * 0.2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(centerX + houseWidth * 0.15, baseY - houseHeight * 0.3),
      Offset(centerX + houseWidth * 0.35, baseY - houseHeight * 0.3),
      strokePaint,
    );

    // 8. LETRA GRANDE Y PROMINENTE (como en la referencia)
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.4, // Letra MUY grande
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    final letterX = centerX - textPainter.width / 2;
    final letterY = baseY - houseHeight / 2 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(letterX, letterY));

    // 9. Detalles decorativos
    // Flores en las ventanas
    paint.color = const Color(0xFFFF69B4);
    canvas.drawCircle(
      Offset(centerX - houseWidth * 0.3, baseY - houseHeight * 0.15),
      2,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + houseWidth * 0.3, baseY - houseHeight * 0.15),
      2,
      paint,
    );

    // 10. Overlay si no está desbloqueada
    if (!isUnlocked) {
      paint.color = Colors.black.withOpacity(0.6);
      canvas.drawRRect(mainWalls, paint);
      
      // Candado grande y visible
      paint.color = const Color(0xFFFFD700);
      final lockRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, baseY - houseHeight / 2),
          width: size.width * 0.3,
          height: size.width * 0.3,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(lockRect, paint);
      
      // Arco del candado
      strokePaint.strokeWidth = 4;
      strokePaint.color = const Color(0xFFFFD700);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(centerX, baseY - houseHeight / 2 - 8),
          width: size.width * 0.2,
          height: size.width * 0.15,
        ),
        math.pi,
        math.pi,
        false,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}