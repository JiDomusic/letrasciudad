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
    
    // Área disponible SOLO en la mitad SUPERIOR de la pantalla
    // Reservamos TODO el 50% inferior para evitar cualquier interferencia
    final upperHalfOnly = screenHeight * 0.45; // Solo usar el 45% superior
    final availableHeight = upperHalfOnly - 100; // Margen generoso desde arriba
    final availableWidth = screenWidth - 100; // 50px margen en cada lado
    
    // Asegurar que tenemos espacio mínimo incluso en pantallas pequeñas
    final safeAvailableHeight = math.max(availableHeight, 120.0);
    
    // Distribución orgánica adaptativa
    final totalLetters = widget.letters.length;
    
    // Adaptar columnas según orientación y tamaño
    final isLandscape = screenWidth > screenHeight;
    int cols;
    if (isSmallScreen) {
      cols = isLandscape ? 6 : 4;
    } else if (isMediumScreen) {
      cols = isLandscape ? 8 : 5;
    } else {
      cols = isLandscape ? 10 : 6;
    }
    
    final rows = (totalLetters / cols).ceil();
    final col = index % cols;
    final row = index ~/ cols;
    
    // Calcular posición base en cuadrícula - SOLO en parte superior
    final cellWidth = availableWidth / cols;
    final cellHeight = math.max(safeAvailableHeight / rows, 90.0); // Mínimo 90px de altura
    
    // Añadir variación aleatoria para efecto natural
    final random = math.Random(index + letter.character.codeUnitAt(0));
    final offsetX = (random.nextDouble() - 0.5) * (cellWidth * 0.3); // Reducir variación horizontal
    final offsetY = (random.nextDouble() - 0.5) * (cellHeight * 0.2); // Reducir variación vertical
    
    // Posición final SOLO en la mitad superior de la pantalla
    var finalX = 50 + (col * cellWidth) + (cellWidth / 2) + offsetX;
    var finalY = 50 + (row * cellHeight) + (cellHeight / 2) + offsetY; // Comenzar bien arriba
    
    // Tamaño de casa más pequeño para evitar interferencias
    final houseSize = isSmallScreen ? 60.0 : (isMediumScreen ? 70.0 : 80.0);
    
    // Asegurar que las casas estén ESTRICTAMENTE en la parte superior
    finalX = finalX.clamp(houseSize / 2 + 15, screenWidth - houseSize / 2 - 15);
    // Límite ABSOLUTO - NUNCA pasar del 45% de la pantalla
    final absoluteMaxY = screenHeight * 0.45; // Máximo ABSOLUTO 45% de altura
    finalY = finalY.clamp(houseSize / 2 + 25, absoluteMaxY - houseSize / 2);
    
    // DEBUG: Mostrar información de posicionamiento
    // print('Letra ${letter.character}: x=$finalX, y=$finalY, maxY=$maxY, screenHeight=$screenHeight');
    
    // Verificar si está resaltada
    final isHighlighted = widget.highlightedLetter == letter.character;
    
    return Positioned(
      left: finalX - houseSize / 2,
      top: finalY - houseSize / 2,
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
    return ClipRect(
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Techo - altura fija muy pequeña para evitar overflow
            SizedBox(
              height: size * 0.3, // Reducido significativamente
              child: ClipRect(
                child: CustomPaint(
                  size: Size(size, size * 0.3),
                  painter: _RoofPainter(
                    color: Colors.brown[600]!,
                    shadowColor: Colors.brown[800]!,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ),
            ),
            // Cuerpo de la casa - altura fija
            SizedBox(
              height: size * 0.7, // El resto del espacio disponible
              child: ClipRect(
                child: Container(
                  width: size,
                  decoration: BoxDecoration(
                    color: letter.primaryColor,
                    border: isDragging ? Border.all(
                      color: Colors.yellow,
                      width: 1,
                    ) : null,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Letra principal - centrada y simple
                      Center(
                        child: ClipRect(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              letter.character,
                              style: TextStyle(
                                fontSize: size * 0.25, // Tamaño proporcional pero limitado
                                fontWeight: FontWeight.bold,
                                color: letter.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Elementos decorativos solo en pantallas grandes
                      if (!isSmallScreen) ...[
                        // Ventanas pequeñas
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[200],
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[200],
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        // Puerta pequeña
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.brown[400],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Indicador de estrellas - solo si hay espacio
                      if (letter.stars > 0 && !isSmallScreen)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Container(
                            width: 10,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.amber[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Center(
                              child: Text(
                                '${letter.stars}',
                                style: const TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
