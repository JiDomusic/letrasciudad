import 'package:flutter/material.dart';

class IsometricHouse3D extends StatelessWidget {
  final String letter;
  final double size;
  final VoidCallback onTap;
  final bool isUnlocked;
  final Color houseColor;

  const IsometricHouse3D({
    super.key,
    required this.letter,
    required this.size,
    required this.onTap,
    this.isUnlocked = true,
    this.houseColor = const Color(0xFF8B4513),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.2,
        child: CustomPaint(
          painter: IsometricHousePainter(
            letter: letter,
            isUnlocked: isUnlocked,
            houseColor: houseColor,
          ),
        ),
      ),
    );
  }
}

class IsometricHousePainter extends CustomPainter {
  final String letter;
  final bool isUnlocked;
  final Color houseColor;

  IsometricHousePainter({
    required this.letter,
    required this.isUnlocked,
    required this.houseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black.withValues(alpha: 0.3);

    // Dimensiones base para vista isométrica
    final baseWidth = size.width * 0.8;
    final baseHeight = size.height * 0.4;
    final roofHeight = size.height * 0.25;
    final depth = baseWidth * 0.6;

    // Coordenadas isométricas (45 grados)
    final centerX = size.width / 2;
    final baseY = size.height * 0.85;

    // Puntos base de la casa (vista isométrica)
    final frontBottomLeft = Offset(centerX - baseWidth / 2, baseY);
    final frontBottomRight = Offset(centerX + baseWidth / 2, baseY);
    final frontTopLeft = Offset(centerX - baseWidth / 2, baseY - baseHeight);
    final frontTopRight = Offset(centerX + baseWidth / 2, baseY - baseHeight);

    // Puntos traseros (proyección isométrica)
    final backBottomLeft = Offset(frontBottomLeft.dx - depth * 0.5, frontBottomLeft.dy - depth * 0.3);
    final backBottomRight = Offset(frontBottomRight.dx - depth * 0.5, frontBottomRight.dy - depth * 0.3);
    final backTopLeft = Offset(frontTopLeft.dx - depth * 0.5, frontTopLeft.dy - depth * 0.3);
    final backTopRight = Offset(frontTopRight.dx - depth * 0.5, frontTopRight.dy - depth * 0.3);

    // Punto del techo
    final roofPeak = Offset(centerX - depth * 0.25, baseY - baseHeight - roofHeight);
    final backRoofPeak = Offset(roofPeak.dx - depth * 0.5, roofPeak.dy - depth * 0.3);

    // 1. Dibujar cara lateral (más oscura)
    paint.color = houseColor.withValues(alpha: 0.7);
    final sideWall = Path()
      ..moveTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(backBottomRight.dx, backBottomRight.dy)
      ..lineTo(backTopRight.dx, backTopRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..close();
    canvas.drawPath(sideWall, paint);
    canvas.drawPath(sideWall, strokePaint);

    // 2. Dibujar cara frontal (más clara)
    paint.color = houseColor;
    final frontWall = Path()
      ..moveTo(frontBottomLeft.dx, frontBottomLeft.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(frontTopLeft.dx, frontTopLeft.dy)
      ..close();
    canvas.drawPath(frontWall, paint);
    canvas.drawPath(frontWall, strokePaint);

    // 3. Dibujar techo triangular lateral (oscuro)
    paint.color = const Color(0xFF8B0000); // Rojo oscuro como las otras casas
    final sideRoof = Path()
      ..moveTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(backTopRight.dx, backTopRight.dy)
      ..lineTo(backRoofPeak.dx, backRoofPeak.dy)
      ..lineTo(roofPeak.dx, roofPeak.dy)
      ..close();
    canvas.drawPath(sideRoof, paint);
    canvas.drawPath(sideRoof, strokePaint);

    // 4. Dibujar techo triangular frontal (más claro)
    paint.color = const Color(0xFFB71C1C); // Rojo más brillante como las tejas
    final frontRoof = Path()
      ..moveTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(roofPeak.dx, roofPeak.dy)
      ..close();
    canvas.drawPath(frontRoof, paint);
    canvas.drawPath(frontRoof, strokePaint);

    // 4.5. Agregar tejas triangulares en el techo frontal
    paint.color = const Color(0xFFD32F2F); // Rojo brillante para tejas
    final tileCount = 6;
    final tileWidth = (frontTopRight.dx - frontTopLeft.dx) / tileCount;
    
    for (int i = 0; i < tileCount; i++) {
      final tileX = frontTopLeft.dx + (i * tileWidth);
      final tileY = frontTopLeft.dy + (i * 2); // Ligera inclinación
      final tileHeight = roofHeight * 0.15;
      
      final tilePath = Path();
      tilePath.moveTo(tileX, tileY);
      tilePath.lineTo(tileX + tileWidth/2, tileY - tileHeight);
      tilePath.lineTo(tileX + tileWidth, tileY);
      tilePath.close();
      
      canvas.drawPath(tilePath, paint);
      
      // Contorno blanco de cada teja
      strokePaint.strokeWidth = 0.8;
      strokePaint.color = Colors.white;
      canvas.drawPath(tilePath, strokePaint);
    }
    
    // Restaurar strokePaint original
    strokePaint.strokeWidth = 1.5;
    strokePaint.color = Colors.black.withValues(alpha: 0.3);

    // 5. Dibujar puerta
    paint.color = const Color(0xFF4A4A4A);
    final doorWidth = baseWidth * 0.2;
    final doorHeight = baseHeight * 0.6;
    final doorLeft = centerX - doorWidth / 2;
    final doorTop = baseY - doorHeight;
    
    final door = Rect.fromLTWH(doorLeft, doorTop, doorWidth, doorHeight);
    canvas.drawRect(door, paint);
    canvas.drawRect(door, strokePaint);

    // 6. Dibujar ventana
    paint.color = const Color(0xFF87CEEB);
    final windowSize = baseWidth * 0.15;
    final windowLeft = centerX + baseWidth * 0.15;
    final windowTop = baseY - baseHeight * 0.7;
    
    final window = Rect.fromLTWH(windowLeft, windowTop, windowSize, windowSize);
    canvas.drawRect(window, paint);
    canvas.drawRect(window, strokePaint);

    // Marco de ventana
    strokePaint.strokeWidth = 1;
    canvas.drawLine(
      Offset(windowLeft + windowSize / 2, windowTop),
      Offset(windowLeft + windowSize / 2, windowTop + windowSize),
      strokePaint,
    );
    canvas.drawLine(
      Offset(windowLeft, windowTop + windowSize / 2),
      Offset(windowLeft + windowSize, windowTop + windowSize / 2),
      strokePaint,
    );

    // 7. Dibujar letra
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter.toUpperCase(),
        style: TextStyle(
          color: isUnlocked ? Colors.white : Colors.grey,
          fontSize: size.width * 0.3,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.7),
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
    final letterY = baseY - baseHeight / 2 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(letterX, letterY));

    // 8. Overlay si no está desbloqueada
    if (!isUnlocked) {
      paint.color = Colors.black.withValues(alpha: 0.4);
      canvas.drawPath(frontWall, paint);
      
      // Candado
      paint.color = Colors.yellow;
      final lockSize = size.width * 0.15;
      final lockRect = Rect.fromCenter(
        center: Offset(centerX, baseY - baseHeight * 0.3),
        width: lockSize,
        height: lockSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(lockRect, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}