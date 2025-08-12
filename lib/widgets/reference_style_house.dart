
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReferenceStyleHouse extends StatelessWidget {
  final String letter;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onDoorTap;
  final bool isUnlocked;

  const ReferenceStyleHouse({
    super.key,
    required this.letter,
    required this.size,
    required this.onTap,
    this.onDoorTap,
    this.isUnlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // AJUSTAR PROPORCIÓN PARA MÓVIL
    final houseWidth = size;
    final houseHeight = isMobile ? size * 1.2 : size * 1.4; // Menos altura en móvil
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: houseWidth,
        height: houseHeight,
        child: Stack(
          children: [
            CustomPaint(
              painter: ReferenceHousePainter(
                letter: letter,
                isUnlocked: isUnlocked,
                isMobile: isMobile,
              ),
            ),
            // Área clickeable de la puerta (ajustada para puerta a la derecha)
            if (onDoorTap != null)
              Positioned(
                left: houseWidth * 0.625, // Puerta a la derecha
                top: houseHeight * 0.45, // Posición vertical de la puerta
                child: GestureDetector(
                  onTap: onDoorTap,
                  child: Container(
                    width: houseWidth * 0.18, // Ancho de la puerta
                    height: houseHeight * 0.3, // Alto de la puerta
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReferenceHousePainter extends CustomPainter {
  final String letter;
  final bool isUnlocked;
  final bool isMobile;

  ReferenceHousePainter({
    required this.letter,
    required this.isUnlocked,
    this.isMobile = false,
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

  Color _getChimneyColor(String letter) {
    // Colores diferentes para cada chimenea
    final colors = [
      const Color(0xFF8D6E63), // Marrón
      const Color(0xFFD32F2F), // Rojo ladrillo
      const Color(0xFF689F38), // Verde oscuro
      const Color(0xFF455A64), // Gris azulado
      const Color(0xFF6A1B9A), // Púrpura
      const Color(0xFFE65100), // Naranja quemado
      const Color(0xFF2E7D32), // Verde
      const Color(0xFF795548), // Marrón chocolate
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
    
    // DIMENSIONES RESPONSIVAS PARA MÓVIL
    final houseWidth = isMobile ? size.width * 0.85 : size.width * 0.75; // Más ancho en móvil
    final houseHeight = isMobile ? size.height * 0.50 : size.height * 0.45;
    final roofHeight = isMobile ? size.height * 0.22 : size.height * 0.25; // Techo más bajo en móvil
    final foundationHeight = isMobile ? size.height * 0.10 : size.height * 0.08;

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
    strokePaint.strokeWidth = isMobile ? 1.5 : 2;
    strokePaint.color = Colors.white;
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
    strokePaint.strokeWidth = isMobile ? 1.5 : 2.0;
    strokePaint.color = Colors.white;
    canvas.drawRRect(walls, strokePaint);

    // 3. TECHO ESTILO CHINO CON TEJAS TRIANGULARES
    final roofTop = baseY - houseHeight - roofHeight + 8;
    
    // Techo base con curvatura china
    paint.color = const Color(0xFF8B0000); // Rojo oscuro tradicional chino
    final roofPath = Path();
    roofPath.moveTo(centerX - houseWidth/2 - 12, baseY - houseHeight + 8);
    roofPath.quadraticBezierTo(centerX, roofTop - 10, centerX + houseWidth/2 + 12, baseY - houseHeight + 8);
    roofPath.lineTo(centerX + houseWidth/2 - 2, baseY - houseHeight + 12);
    roofPath.quadraticBezierTo(centerX, roofTop + 2, centerX - houseWidth/2 + 2, baseY - houseHeight + 12);
    roofPath.close();
    
    canvas.drawPath(roofPath, paint);
    
    // Tejas triangulares superpuestas
    paint.color = const Color(0xFFB71C1C); // Rojo más brillante para tejas
    final tileWidth = houseWidth / 8;
    final tileHeight = roofHeight * 0.3;
    
    for (int i = 0; i < 8; i++) {
      final tileX = centerX - houseWidth/2 + (i * tileWidth);
      final tileY = baseY - houseHeight + 8 - (i * 2);
      
      final tilePath = Path();
      tilePath.moveTo(tileX, tileY);
      tilePath.lineTo(tileX + tileWidth/2, tileY - tileHeight);
      tilePath.lineTo(tileX + tileWidth, tileY);
      tilePath.close();
      
      canvas.drawPath(tilePath, paint);
      
      // Contorno blanco de cada teja
      strokePaint.strokeWidth = 1;
      strokePaint.color = Colors.white;
      canvas.drawPath(tilePath, strokePaint);
    }
    
    // Borde decorativo del techo estilo chino
    strokePaint.strokeWidth = 3;
    strokePaint.color = const Color(0xFFFFD700); // Dorado
    canvas.drawPath(roofPath, strokePaint);
    
    // 4. CHIMENEA CON DIFERENTES COLORES
    paint.color = _getChimneyColor(letter);
    final chimney = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX + houseWidth/3,
        roofTop + 5,
        12,
        25,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(chimney, paint);
    
    // Humo de la chimenea
    paint.color = Colors.grey.withOpacity(0.6);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(centerX + houseWidth/3 + 6, roofTop - 5 - (i * 8)),
        3 - (i * 0.5),
        paint,
      );
    }
    
    strokePaint.strokeWidth = 1.5;
    strokePaint.color = Colors.white;
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
    strokePaint.color = Colors.white;
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
    strokePaint.color = Colors.white;
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
          fontSize: isMobile ? size.width * 0.40 : size.width * 0.35, // Más grande en móvil para legibilidad
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
      strokePaint.strokeWidth = isMobile ? 2.5 : 3;
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