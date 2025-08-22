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
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size * 1.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // LADO DERECHO 3D DE LA CASA (para efecto de profundidad)
            Positioned(
              bottom: 8,
              right: -size * 0.05,
              child: Container(
                width: size * 0.25,
                height: size * 0.95,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE0E0E0), // Gris claro
                      const Color(0xFFBDBDBD), // Gris medio
                      const Color(0xFF9E9E9E), // Gris oscuro
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size * 0.08),
                    bottomRight: Radius.circular(size * 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(4, 6),
                    ),
                  ],
                ),
              ),
            ),
            
            // CASA PRINCIPAL CON EFECTOS 3D MEJORADOS
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.9,
                height: size * 1.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8F8F8),
                      const Color(0xFFF0F0F0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                  boxShadow: [
                    // Sombra principal profunda
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(5, 8),
                    ),
                    // Sombra secundaria suave
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(8, 12),
                    ),
                    // Brillo interior
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 5,
                      offset: const Offset(-2, -2),
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
            
            // PUERTA 3D REALISTA CON EFECTO DE PROFUNDIDAD
            Positioned(
              bottom: size * 0.02,
              child: Stack(
                children: [
                  // Marco de la puerta (fondo con profundidad)
                  Container(
                    width: size * 0.48,
                    height: size * 0.63,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8D6E63), // Marrón marco
                          const Color(0xFF5D4037),
                          const Color(0xFF3E2723),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(size * 0.08),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(3, 4),
                        ),
                      ],
                    ),
                  ),
                  
                  // Puerta principal con efecto 3D
                  Positioned(
                    left: size * 0.015,
                    top: size * 0.015,
                    child: Container(
                      width: size * 0.45,
                      height: size * 0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getLetterColor(letter),
                            _getLetterColor(letter).withValues(alpha: 0.8),
                            _getLetterColor(letter).withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(size * 0.06),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          // Sombra interna para efecto cóncavo
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Paneles de la puerta
                          Positioned(
                            top: size * 0.05,
                            left: size * 0.05,
                            child: Container(
                              width: size * 0.35,
                              height: size * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(size * 0.02),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: size * 0.15,
                            left: size * 0.05,
                            child: Container(
                              width: size * 0.35,
                              height: size * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(size * 0.02),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          
                          // Letra prominente en el centro
                          Center(
                            child: Container(
                              width: size * 0.25,
                              height: size * 0.25,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.9),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  letter.toUpperCase(),
                                  style: TextStyle(
                                    color: _getLetterColor(letter),
                                    fontSize: size * 0.18,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Arial Black',
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // MANIJA DORADA 3D REALISTA
            Positioned(
              bottom: size * 0.32,
              right: size * 0.22,
              child: Container(
                width: size * 0.06,
                height: size * 0.06,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFE082), // Dorado claro
                      const Color(0xFFFFD700), // Dorado medio
                      const Color(0xFFFF8F00), // Dorado oscuro
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFE082).withValues(alpha: 0.6),
                      blurRadius: 6,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.02,
                    height: size * 0.02,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            
            // VENTANA 3D REALISTA CON CRISTAL
            Positioned(
              bottom: size * 0.52,
              right: size * 0.12,
              child: Stack(
                children: [
                  // Marco de la ventana (profundidad)
                  Container(
                    width: size * 0.26,
                    height: size * 0.26,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6D4C41), // Marrón marco
                          const Color(0xFF5D4037),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(size * 0.06),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                  
                  // Cristal de la ventana
                  Positioned(
                    left: size * 0.015,
                    top: size * 0.015,
                    child: Container(
                      width: size * 0.23,
                      height: size * 0.23,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFE3F2FD), // Azul cristal claro
                            const Color(0xFFBBDEFB),
                            const Color(0xFF90CAF9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(size * 0.04),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        boxShadow: [
                          // Reflejos en el cristal
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(-1, -1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Reflejos modernos en el cristal
                          Positioned(
                            top: size * 0.02,
                            left: size * 0.02,
                            child: Container(
                              width: size * 0.08,
                              height: size * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(size * 0.02),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: size * 0.02,
                            right: size * 0.02,
                            child: Container(
                              width: size * 0.05,
                              height: size * 0.03,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(size * 0.015),
                              ),
                            ),
                          ),
                          // Pequeña decoración circular
                          Center(
                            child: Container(
                              width: size * 0.04,
                              height: size * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

    // LADO DERECHO DEL TECHO 3D (efecto de profundidad)
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF5D1A1A), // Rojo muy oscuro
        const Color(0xFF4A0C0C), // Rojo casi negro
        const Color(0xFF2D0707), // Rojo negro
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final sideRoofPath = Path();
    sideRoofPath.moveTo(centerX, roofTop);
    sideRoofPath.lineTo(centerX + size.width/2 - 10, baseY);
    sideRoofPath.lineTo(centerX + size.width/2 + 15, baseY + 15);
    sideRoofPath.lineTo(centerX + 8, roofTop + 8);
    sideRoofPath.close();
    
    canvas.drawPath(sideRoofPath, paint);

    // TECHO PRINCIPAL CON GRADIENTE 3D
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFD32F2F), // Rojo brillante
        const Color(0xFFB71C1C), // Rojo medio
        const Color(0xFF8B0000), // Rojo oscuro
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final roofPath = Path();
    roofPath.moveTo(centerX - size.width/2 + 10, baseY);
    roofPath.quadraticBezierTo(centerX, roofTop - 15, centerX + size.width/2 - 10, baseY);
    roofPath.lineTo(centerX + size.width/2 - 20, baseY + 10);
    roofPath.quadraticBezierTo(centerX, roofTop, centerX - size.width/2 + 20, baseY + 10);
    roofPath.close();
    
    canvas.drawPath(roofPath, paint);
    
    // TEJAS 3D CON EFECTOS DE PROFUNDIDAD
    paint.shader = null;
    final tileCount = 12;
    final tileWidth = size.width / tileCount;
    final tileHeight = size.height * 0.12;
    
    for (int i = 0; i < tileCount; i++) {
      final tileX = (i * tileWidth);
      final tileY = baseY - (i * 2) + 3;
      
      // Teja principal con gradiente
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFFE57373), const Color(0xFFB71C1C), i / tileCount)!,
          Color.lerp(const Color(0xFFB71C1C), const Color(0xFF8B0000), i / tileCount)!,
        ],
      ).createShader(Rect.fromLTWH(tileX, tileY - tileHeight, tileWidth, tileHeight));
      
      final tilePath = Path();
      tilePath.moveTo(tileX + 2, tileY);
      tilePath.quadraticBezierTo(tileX + tileWidth/2, tileY - tileHeight - 3, tileX + tileWidth - 2, tileY);
      tilePath.lineTo(tileX + tileWidth - 4, tileY + 3);
      tilePath.quadraticBezierTo(tileX + tileWidth/2, tileY - tileHeight, tileX + 4, tileY + 3);
      tilePath.close();
      
      canvas.drawPath(tilePath, paint);
      
      // Sombra de la teja
      paint.shader = null;
      paint.color = Colors.black.withValues(alpha: 0.2);
      final shadowPath = Path();
      shadowPath.moveTo(tileX + 1, tileY + 1);
      shadowPath.quadraticBezierTo(tileX + tileWidth/2 + 1, tileY - tileHeight - 2, tileX + tileWidth - 1, tileY + 1);
      shadowPath.lineTo(tileX + tileWidth - 3, tileY + 4);
      shadowPath.quadraticBezierTo(tileX + tileWidth/2 + 1, tileY - tileHeight + 1, tileX + 5, tileY + 4);
      shadowPath.close();
      canvas.drawPath(shadowPath, paint);
      
      // Brillo en la teja
      strokePaint.strokeWidth = 1;
      strokePaint.color = Colors.white.withValues(alpha: 0.3);
      final tileBorder = Path();
      tileBorder.moveTo(tileX + 2, tileY - 1);
      tileBorder.quadraticBezierTo(tileX + tileWidth/2, tileY - tileHeight - 4, tileX + tileWidth - 2, tileY - 1);
      canvas.drawPath(tileBorder, strokePaint);
    }
    
    // BORDE DECORATIVO 3D CON EFECTO METÁLICO
    strokePaint.strokeWidth = 4;
    strokePaint.shader = LinearGradient(
      colors: [
        const Color(0xFFFFE082), // Dorado claro
        const Color(0xFFFFD700), // Dorado
        const Color(0xFFFF8F00), // Dorado oscuro
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
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