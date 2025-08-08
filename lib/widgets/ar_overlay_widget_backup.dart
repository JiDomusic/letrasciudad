import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/letter.dart';

class AROverlayWidget extends StatefulWidget {
  final List<Letter> letters;
  final Function(Letter) onLetterTap;
  final String? highlightedLetter;
  final double houseScale;

  const AROverlayWidget({
    super.key,
    required this.letters,
    required this.onLetterTap,
    this.highlightedLetter,
    this.houseScale = 1.0,
  });

  @override
  State<AROverlayWidget> createState() => _AROverlayWidgetState();
}

class _AROverlayWidgetState extends State<AROverlayWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.letters.isEmpty) {
      return const Center(
        child: Text(
          'No hay letras disponibles',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        // Limitar letras y crear distribución simple
        final limitedLetters = widget.letters.take(27).toList();
        
        return Stack(
          children: limitedLetters.asMap().entries.map((entry) {
            final index = entry.key;
            final letter = entry.value;
            
            return _build3DHouse(letter, index, constraints);
          }).toList(),
        );
      },
    );
  }

  Widget _build3DHouse(Letter letter, int index, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    
    // Detectar tamaño de pantalla para responsive design
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    
    // Distribución en círculo simple con radio adaptativo
    final totalLetters = widget.letters.length;
    final angle = (index / totalLetters) * 2 * math.pi;
    
    // Radio responsivo - más pequeño en pantallas pequeñas
    final baseRadius = math.min(screenWidth, screenHeight);
    final radiusMultiplier = isSmallScreen ? 0.28 : (isMediumScreen ? 0.32 : 0.35);
    final radius = baseRadius * radiusMultiplier;
    
    // Posición centrada en círculo
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    final x = centerX + radius * math.cos(angle);
    final y = centerY + radius * math.sin(angle);
    
    // Tamaño de casa responsivo
    final houseSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);
    
    // Verificar si está resaltada
    final isHighlighted = widget.highlightedLetter == letter.character;
    
    return Positioned(
      left: x - houseSize / 2,
      top: y - houseSize / 2,
      child: Draggable<String>(
        data: letter.character,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: isSmallScreen ? 1.2 : (isMediumScreen ? 1.25 : 1.3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.6),
                    blurRadius: isSmallScreen ? 12 : 15,
                    spreadRadius: isSmallScreen ? 3 : 5,
                  ),
                ],
              ),
              child: _buildHouseStructure(letter, houseSize, true, isSmallScreen, isMediumScreen),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildHouseStructure(letter, houseSize, false, isSmallScreen, isMediumScreen),
        ),
        child: GestureDetector(
          onTap: () => widget.onLetterTap(letter),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isHighlighted ? (isSmallScreen ? 1.15 : 1.2) : 1.0,
            child: _buildHouseStructure(letter, houseSize, false, isSmallScreen, isMediumScreen),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseStructure(Letter letter, double size, bool isDragging, bool isSmallScreen, bool isMediumScreen) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Sombra de la casa para efecto 3D responsiva
          Positioned(
            left: isSmallScreen ? 2 : 4,
            top: isSmallScreen ? 2 : 4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              ),
            ),
          ),
          // Estructura principal de la casa con flex constraints
          ClipRRect(
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Techo triangular responsivo - usando Expanded
                Expanded(
                  flex: 2, // 40% of available height
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _RoofPainter(
                      color: Colors.brown[600]!,
                      shadowColor: Colors.brown[800]!,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ),
                // Cuerpo de la casa - usando Expanded
                Expanded(
                  flex: 3, // 60% of available height
                  child: Container(
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        letter.primaryColor.withValues(alpha: 0.9),
                        letter.primaryColor,
                      ],
                    ),
                    border: Border.all(
                      color: isDragging ? Colors.yellow : Colors.white,
                      width: isDragging ? (isSmallScreen ? 2 : 3) : (isSmallScreen ? 1.5 : 2),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: isDragging ? [
                      BoxShadow(
                        color: Colors.yellow.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Letra principal - flexible
                      Positioned.fill(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 4 : 6, 
                                vertical: isSmallScreen ? 3 : 4
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                                border: Border.all(
                                  color: letter.primaryColor,
                                  width: isSmallScreen ? 1 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                letter.character,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.w900,
                                  color: letter.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Ventanas responsivas con posicionamiento flexible
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          width: isSmallScreen ? 8 : 12,
                          height: isSmallScreen ? 8 : 12,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            border: Border.all(
                              color: Colors.brown[400]!,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: isSmallScreen ? 8 : 12,
                          height: isSmallScreen ? 8 : 12,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            border: Border.all(
                              color: Colors.brown[400]!,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      // Puerta responsiva - más pequeña
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: isSmallScreen ? 12 : 16,
                            height: isSmallScreen ? 16 : 20,
                            decoration: BoxDecoration(
                              color: Colors.brown[400],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isSmallScreen ? 4 : 6),
                                topRight: Radius.circular(isSmallScreen ? 4 : 6),
                              ),
                              border: Border.all(
                                color: Colors.brown[600]!,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.yellow[600],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Indicador de drag compacto
                      Positioned(
                        top: 1,
                        right: 1,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Icon(
                            Icons.drag_indicator,
                            size: isSmallScreen ? 8 : 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // Indicador de estrellas compacto
                      if (letter.stars > 0)
                        Positioned(
                          top: 1,
                          left: 1,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.amber[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '★${letter.stars}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 6 : 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
        ],
      ),
    );
  }
}

// Painter personalizado para el techo triangular 3D
class _RoofPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final bool isSmallScreen;

  _RoofPainter({required this.color, required this.shadowColor, this.isSmallScreen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    // Techo principal
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Sombra del techo (lado derecho para efecto 3D) responsiva
    final shadowPath = Path();
    final shadowOffset = isSmallScreen ? 2.0 : 4.0;
    shadowPath.moveTo(size.width / 2, 0);
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width - shadowOffset, size.height);
    shadowPath.lineTo(size.width / 2, shadowOffset);
    shadowPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}