import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReferenceStyleHouse extends StatelessWidget {
  final String letter;
  final double size;
  final VoidCallback onTap;
  final bool isUnlocked;

  const ReferenceStyleHouse({
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
        height: size * 1.4,
        child: CustomPaint(
          painter: ReferenceHousePainter(
            letter: letter,
            isUnlocked: isUnlocked,
          ),
        ),
      ),
    );
  }
}

class ReferenceHousePainter extends CustomPainter {
  final String letter;
  final bool isUnlocked;

  ReferenceHousePainter({
    required this.letter,
    required this.isUnlocked,
  });

  Color _getWallColor(String letter) {
    // Alternar entre amarillo y naranja como en la referencia
    final index = letter.codeUnitAt(0) - 65; // A=0, B=1, etc.
    return index % 2 == 0 
        ? const Color(0xFFFFD700) // Amarillo dorado
        : const Color(0xFFFF8C00); // Naranja
  }

  Color _getLetterBadgeColor(String letter) {
    // Colores vibrantes para los círculos de letras
    final colors = [
      const Color(0xFFE91E63), // Rosa fucsia (como la M en referencia)
      const Color(0xFF9C27B0), // Púrpura
      const Color(0xFF2196F3), // Azul
      const Color(0xFF4CAF50), // Verde
      const Color(0xFFF44336), // Rojo
      const Color(0xFFFF9800), // Naranja
      const Color(0xFF607D8B), // Gris azul
      const Color(0xFF795548), // Marrón
    ];
    final index = letter.codeUnitAt(0) - 65;
    return colors[index % colors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white;

    final centerX = size.width / 2;
    final baseY = size.height * 0.85;
    
    // Dimensiones exactas como en la referencia
    final houseWidth = size.width * 0.75;
    final houseHeight = size.height * 0.45;
    final roofHeight = size.height * 0.25;
    final foundationHeight = size.height * 0.08;

    // 1. BASE/FUNDACIÓN AZUL (como en la referencia)
    paint.color = const Color(0xFF2196F3); // Azul exacto de la referencia
    final foundation = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY + foundationHeight/2),
        width: houseWidth + 12,
        height: foundationHeight,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(foundation, paint);
    
    // Contorno blanco de la fundación
    strokePaint.strokeWidth = 2;
    canvas.drawRRect(foundation, strokePaint);

    // 2. PAREDES PRINCIPALES (amarillo/naranja alternado)
    paint.color = _getWallColor(letter);
    final walls = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - houseHeight/2),
        width: houseWidth,
        height: houseHeight,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(walls, paint);
    canvas.drawRRect(walls, strokePaint);

    // 3. TECHO AZUL TRIANGULAR (exacto como referencia)
    paint.color = const Color(0xFF1976D2); // Azul más oscuro para el techo
    final roofPath = Path();
    final roofTop = baseY - houseHeight - roofHeight + 8;
    
    // Techo triangular con bordes redondeados
    roofPath.moveTo(centerX - houseWidth/2 - 8, baseY - houseHeight + 8);
    roofPath.lineTo(centerX, roofTop);
    roofPath.lineTo(centerX + houseWidth/2 + 8, baseY - houseHeight + 8);
    roofPath.lineTo(centerX + houseWidth/2 - 2, baseY - houseHeight + 12);
    roofPath.lineTo(centerX, roofTop + 6);
    roofPath.lineTo(centerX - houseWidth/2 + 2, baseY - houseHeight + 12);
    roofPath.close();
    
    canvas.drawPath(roofPath, paint);
    strokePaint.strokeWidth = 2;
    canvas.drawPath(roofPath, strokePaint);

    // 4. CHIMENEA PEQUEÑA (como en referencia)
    paint.color = const Color(0xFF8D6E63); // Marrón chimenea
    final chimney = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX + houseWidth/4,
        roofTop + 8,
        8,
        20,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(chimney, paint);
    strokePaint.strokeWidth = 1.5;
    canvas.drawRRect(chimney, strokePaint);

    // 5. PUERTA AZUL (como en la segunda casa de referencia)
    paint.color = const Color(0xFF1565C0); // Azul puerta
    final door = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + houseWidth/4, baseY - 12),
        width: houseWidth * 0.18,
        height: houseHeight * 0.4,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(door, paint);
    strokePaint.strokeWidth = 1.5;
    canvas.drawRRect(door, strokePaint);

    // Manija dorada de la puerta
    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(
      Offset(centerX + houseWidth/4 + 8, baseY - 12),
      2.5,
      paint,
    );

    // 6. VENTANA PEQUEÑA (como en referencia)
    paint.color = const Color(0xFF87CEEB); // Azul claro ventana
    final window = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - houseWidth/4, baseY - houseHeight/3),
        width: houseWidth * 0.15,
        height: houseWidth * 0.15,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(window, paint);
    strokePaint.strokeWidth = 1.5;
    canvas.drawRRect(window, strokePaint);

    // Cruz de la ventana
    strokePaint.strokeWidth = 1;
    strokePaint.color = Colors.white;
    final windowCenter = Offset(centerX - houseWidth/4, baseY - houseHeight/3);
    canvas.drawLine(
      Offset(windowCenter.dx, windowCenter.dy - houseWidth * 0.075),
      Offset(windowCenter.dx, windowCenter.dy + houseWidth * 0.075),
      strokePaint,
    );
    canvas.drawLine(
      Offset(windowCenter.dx - houseWidth * 0.075, windowCenter.dy),
      Offset(windowCenter.dx + houseWidth * 0.075, windowCenter.dy),
      strokePaint,
    );

    // 7. CÍRCULO CENTRAL PARA LA LETRA (exacto como referencia)
    final badgeColor = _getLetterBadgeColor(letter);
    paint.color = badgeColor;
    
    // Círculo principal
    final letterCircleRadius = size.width * 0.25;
    canvas.drawCircle(
      Offset(centerX, baseY - houseHeight/2),
      letterCircleRadius,
      paint,
    );
    
    // Contorno blanco grueso del círculo
    strokePaint.strokeWidth = 4;
    strokePaint.color = Colors.white;
    canvas.drawCircle(
      Offset(centerX, baseY - houseHeight/2),
      letterCircleRadius,
      strokePaint,
    );

    // 8. LETRA BLANCA GRANDE (exacta como referencia)
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.35, // Letra MUY grande como en referencia
          fontWeight: FontWeight.w900,
          fontFamily: 'Arial', // Fuente clean como en referencia
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    final letterX = centerX - textPainter.width / 2;
    final letterY = baseY - houseHeight/2 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(letterX, letterY));

    // 9. PASTO VERDE EN LA BASE (como en la segunda casa)
    paint.color = const Color(0xFF4CAF50); // Verde pasto
    final grassLeft = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - houseWidth/3, baseY + foundationHeight + 8),
        width: houseWidth * 0.25,
        height: 12,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(grassLeft, paint);
    
    final grassRight = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + houseWidth/3, baseY + foundationHeight + 8),
        width: houseWidth * 0.25,
        height: 12,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(grassRight, paint);

    // 10. OVERLAY SI NO ESTÁ DESBLOQUEADA
    if (!isUnlocked) {
      paint.color = Colors.black.withOpacity(0.5);
      canvas.drawRRect(walls, paint);
      
      // Candado dorado grande
      paint.color = const Color(0xFFFFD700);
      final lockSize = size.width * 0.2;
      final lockRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, baseY - houseHeight/2),
          width: lockSize,
          height: lockSize,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(lockRect, paint);
      
      // Arco del candado
      strokePaint.strokeWidth = 3;
      strokePaint.color = const Color(0xFFFFD700);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(centerX, baseY - houseHeight/2 - 6),
          width: lockSize * 0.7,
          height: lockSize * 0.5,
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