import 'package:flutter/material.dart';

class RoundedLetterHouse extends StatelessWidget {
  final String letter;
  final double size;
  final VoidCallback onTap;
  final bool isUnlocked;

  const RoundedLetterHouse({
    super.key,
    required this.letter,
    required this.size,
    required this.onTap,
    this.isUnlocked = true,
  });

  Color _getLetterColor(String letter) {
    final colors = [
      const Color(0xFFE91E63), // Rosa fucsia - A
      const Color(0xFF9C27B0), // Púrpura - B
      const Color(0xFF2196F3), // Azul - C
      const Color(0xFF4CAF50), // Verde - D
      const Color(0xFFF44336), // Rojo - E
      const Color(0xFFFF9800), // Naranja - F
      const Color(0xFF607D8B), // Gris azul - G
      const Color(0xFF795548), // Marrón - H
      const Color(0xFF3F51B5), // Índigo - I
      const Color(0xFF009688), // Verde azulado - J
      const Color(0xFF8BC34A), // Verde claro - K
      const Color(0xFFCDDC39), // Verde lima - L
      const Color(0xFFFFEB3B), // Amarillo - M
      const Color(0xFFFFC107), // Ámbar - N
      const Color(0xFFFF5722), // Rojo naranja - Ñ
      const Color(0xFF673AB7), // Púrpura profundo - O
      const Color(0xFF9E9E9E), // Gris - P
      const Color(0xFF00BCD4), // Cian - Q
      const Color(0xFF03DAC6), // Teal - R
      const Color(0xFFFF6F00), // Naranja profundo - S
      const Color(0xFFE65100), // Naranja oscuro - T
      const Color(0xFF6200EA), // Púrpura intenso - U
      const Color(0xFF00C853), // Verde intenso - V
      const Color(0xFF1DE9B6), // Teal claro - W
      const Color(0xFFD500F9), // Magenta - X
      const Color(0xFF651FFF), // Púrpura azul - Y
      const Color(0xFFFF1744), // Rosa rojo - Z
    ];
    
    // Usar el código ASCII de la letra para obtener un color consistente
    final index = letter.codeUnitAt(0) - 65; // A=0, B=1, etc.
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
  Widget build(BuildContext context) {
    final letterColor = _getLetterColor(letter);
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Casa blanca con bordes redondeados
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.9,
                height: size * 1.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            
            // Techo triangular estilo chino con tejas
            Positioned(
              top: size * 0.05,
              child: CustomPaint(
                size: Size(size * 0.95, size * 0.5),
                painter: ChineseRoofPainter(
                  chimneyColor: _getChimneyColor(letter),
                ),
              ),
            ),
            
            // Puerta azul redondeada
            Positioned(
              bottom: size * 0.02,
              child: Container(
                width: size * 0.25,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(size * 0.06),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
            
            // Manija dorada de la puerta
            Positioned(
              bottom: size * 0.22,
              right: size * 0.32,
              child: Container(
                width: size * 0.04,
                height: size * 0.04,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Ventana redondeada
            Positioned(
              bottom: size * 0.5,
              right: size * 0.15,
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB),
                  borderRadius: BorderRadius.circular(size * 0.04),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Cruz de la ventana
                    Center(
                      child: Container(
                        width: 1,
                        height: size * 0.18,
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: size * 0.18,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Círculo de la letra (elemento principal)
            Positioned(
              bottom: size * 0.45,
              left: size * 0.1,
              child: Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: letterColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: size * 0.02,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: letterColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letter.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.35, // Letras más grandes
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Camino desde la puerta
            Positioned(
              bottom: -size * 0.05,
              child: Container(
                width: size * 0.3,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEB887), // Color arena/camino
                  borderRadius: BorderRadius.circular(size * 0.02),
                  border: Border.all(
                    color: const Color(0xFFCD853F),
                    width: 1,
                  ),
                ),
              ),
            ),
            
            // Pasto verde en la base
            Positioned(
              bottom: -size * 0.02,
              child: Container(
                width: size * 1.1,
                height: size * 0.1,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF8BC34A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.05),
                ),
              ),
            ),
            
            // Overlay si no está desbloqueada
            if (!isUnlocked)
              Positioned(
                bottom: 0,
                child: Container(
                  width: size * 0.9,
                  height: size * 1.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(size * 0.12),
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.25,
                      height: size * 0.25,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(size * 0.04),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChineseRoofPainter extends CustomPainter {
  final Color chimneyColor;

  ChineseRoofPainter({required this.chimneyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final baseY = size.height * 0.8;
    final roofTop = size.height * 0.2;

    // Techo base con curvatura china
    paint.color = const Color(0xFF8B0000); // Rojo oscuro tradicional chino
    final roofPath = Path();
    roofPath.moveTo(centerX - size.width/2 + 10, baseY);
    roofPath.quadraticBezierTo(centerX, roofTop - 15, centerX + size.width/2 - 10, baseY);
    roofPath.lineTo(centerX + size.width/2 - 20, baseY + 10);
    roofPath.quadraticBezierTo(centerX, roofTop, centerX - size.width/2 + 20, baseY + 10);
    roofPath.close();
    
    canvas.drawPath(roofPath, paint);
    
    // Tejas triangulares superpuestas
    paint.color = const Color(0xFFB71C1C); // Rojo más brillante para tejas
    final tileCount = 10;
    final tileWidth = size.width / tileCount;
    final tileHeight = size.height * 0.15;
    
    for (int i = 0; i < tileCount; i++) {
      final tileX = (i * tileWidth);
      final tileY = baseY - (i * 3) + 5;
      
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
    
    // Chimenea con color único
    paint.color = chimneyColor;
    final chimney = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX + size.width/4,
        roofTop + 10,
        size.width * 0.08,
        size.height * 0.25,
      ),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(chimney, paint);
    
    // Humo de la chimenea
    paint.color = Colors.grey.withValues(alpha: 0.6);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(centerX + size.width/4 + size.width * 0.04, roofTop - (i * 12)),
        4 - (i * 0.8),
        paint,
      );
    }
    
    strokePaint.strokeWidth = 2;
    strokePaint.color = Colors.white;
    canvas.drawRRect(chimney, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}