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

class _AROverlayWidgetState extends State<AROverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotationController;
  late List<Animation<double>> _floatAnimations;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    try {
      _floatController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );
      
      _rotationController = AnimationController(
        duration: const Duration(seconds: 30), // Rotación más lenta
        vsync: this,
      );

      _rotationAnimation = Tween<double>(
        begin: 0,
        end: 2 * math.pi,
      ).animate(CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear, // Rotación más suave
      ));

      // Asegurar que tenemos letras antes de crear animaciones
      final letterCount = math.max(1, widget.letters.length);
      _floatAnimations = List.generate(
        letterCount,
        (index) => Tween<double>(
          begin: -8, // Flotación más sutil
          end: 8,
        ).animate(CurvedAnimation(
          parent: _floatController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.7),
            ((index * 0.1) + 0.3).clamp(0.3, 1.0),
            curve: Curves.easeInOut,
          ),
        )),
      );

      _floatController.repeat(reverse: true);
      _rotationController.repeat();
    } catch (e) {
      // En caso de error en inicialización, crear animaciones básicas
      _floatController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );
      _rotationController = AnimationController(
        duration: const Duration(seconds: 30),
        vsync: this,
      );
      _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_rotationController);
      _floatAnimations = [Tween<double>(begin: 0, end: 0).animate(_floatController)];
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _rotationController]),
      builder: (context, child) {
        try {
          return Stack(
            children: widget.letters.asMap().entries.map((entry) {
              final index = entry.key;
              final letter = entry.value;
              
              // Protección contra índices fuera de rango
              if (index >= _floatAnimations.length) {
                return const SizedBox.shrink();
              }
              
              return _buildFloatingHouse(
                letter,
                index,
                size,
                _floatAnimations[index].value,
                _rotationAnimation.value,
              );
            }).toList(),
          );
        } catch (e) {
          // En caso de error, mostrar algo simple en lugar de pantalla roja
          return Container(
            child: const Center(
              child: Text(
                'Cargando VR...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFloatingHouse(
    Letter letter,
    int index,
    Size screenSize,
    double floatOffset,
    double rotation,
  ) {
    try {
      // Verificaciones de seguridad
      if (screenSize.width <= 0 || screenSize.height <= 0) {
        return const SizedBox.shrink();
      }

      // Sistema responsivo para diferentes tamaños de pantalla
      final isSmallScreen = screenSize.width < 600;
      final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
      final isLargeScreen = screenSize.width >= 1200;

      // Distribución espacial responsiva
      final totalLetters = widget.letters.length;
      final lettersPerRing = isSmallScreen ? 4 : (isMediumScreen ? 6 : 8);
      final ring = (index / lettersPerRing).floor();
      final positionInRing = index % lettersPerRing;
      
      // Radios responsivos basados en el tamaño de pantalla
      final baseRadiusMultiplier = isSmallScreen ? 0.25 : (isMediumScreen ? 0.3 : 0.35);
      final minRadius = isSmallScreen ? 80.0 : (isMediumScreen ? 120.0 : 160.0);
      final ringSpacing = isSmallScreen ? 80.0 : (isMediumScreen ? 100.0 : 120.0);
      
      final baseRadius = math.max(
        minRadius + (ring * ringSpacing),
        screenSize.width * baseRadiusMultiplier + (ring * ringSpacing)
      );
      
      // Rotación más suave
      final safeRotation = rotation.isFinite ? rotation : 0.0;
      final angle = (positionInRing / lettersPerRing) * 2 * math.pi + 
                    safeRotation * 0.05 + (ring * 0.1);
      
      // Variación orgánica más sutil
      final randomOffset = (index * 11) % 30 - 15;
      final finalRadius = (baseRadius + randomOffset).clamp(minRadius, screenSize.width * 0.45);
      
      // Márgenes más grandes para casas súper gigantes
      final marginX = isSmallScreen ? 180.0 : (isMediumScreen ? 250.0 : 320.0);
      final marginY = isSmallScreen ? 200.0 : (isMediumScreen ? 280.0 : 370.0);
      
      final safeFloatOffset = floatOffset.isFinite ? floatOffset.clamp(-15.0, 15.0) : 0.0;
      final x = (screenSize.width * 0.5 + finalRadius * math.cos(angle))
          .clamp(marginX, screenSize.width - marginX);
      final y = (screenSize.height * 0.5 + 
                (finalRadius * math.sin(angle) * 0.4) + 
                safeFloatOffset + 
                (ring * 10)).clamp(marginY, screenSize.height - marginY);
      
      // Sistema de escala responsivo - casas más grandes en general
      final baseScale = isSmallScreen ? 1.0 : (isMediumScreen ? 1.2 : 1.4);
      final distanceFromCenter = math.sqrt(
        math.pow(x - screenSize.width * 0.5, 2) + 
        math.pow(y - screenSize.height * 0.5, 2)
      );
      final maxDistance = math.min(screenSize.width, screenSize.height) * 0.4;
      final normalizedDistance = (distanceFromCenter / maxDistance).clamp(0.0, 1.0);
      
      // Escala mínima más alta para casas más grandes
      final minScale = isSmallScreen ? 0.7 : (isMediumScreen ? 0.8 : 0.9);
      final scale = (baseScale - (normalizedDistance * 0.3)).clamp(minScale, baseScale * 1.5);
      final opacity = (1.0 - (normalizedDistance * 0.2)).clamp(0.6, 1.0);

      // Escala interactiva mejorada
      final isHighlighted = widget.highlightedLetter == letter.character;
      final safeHouseScale = widget.houseScale.isFinite ? widget.houseScale.clamp(1.0, 2.5) : 1.0;
      final finalScale = isHighlighted 
          ? (scale * safeHouseScale).clamp(minScale, baseScale * 2.0)
          : scale;

      // Offsets para casas SÚPER MEGA GIGANTES
      final positionOffsetWidth = isSmallScreen ? 150.0 : (isMediumScreen ? 225.0 : 300.0);
      final positionOffsetHeight = isSmallScreen ? 175.0 : (isMediumScreen ? 260.0 : 350.0);
      
      return Positioned(
        left: x - positionOffsetWidth, // Centrado para casas gigantes
        top: y - positionOffsetHeight, // Centrado para casas gigantes
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: finalScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: isHighlighted ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ) : null,
            child: Opacity(
              opacity: opacity,
              child: GestureDetector(
                onTap: () => widget.onLetterTap(letter),
                child: _buildHouseWidget(letter, normalizedDistance, screenSize),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // En caso de error en esta casa específica, devolver placeholder
      return Positioned(
        left: 100,
        top: 100,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.home, color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _buildHouseWidget(Letter letter, double distance, Size screenSize) {
    try {
      final isNear = distance < 0.5;
      
      // Sistema responsivo para las casas
      final isSmallScreen = screenSize.width < 600;
      final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
      
      // Tamaños SÚPER MEGA GIGANTES para VR - ENORMES!
      final houseWidth = isSmallScreen ? 300.0 : (isMediumScreen ? 450.0 : 600.0);
      final houseHeight = isSmallScreen ? 350.0 : (isMediumScreen ? 520.0 : 700.0);
      final roofWidth = houseWidth;
      final roofHeight = isSmallScreen ? 120.0 : (isMediumScreen ? 180.0 : 240.0);
      final bodyHeight = houseHeight - roofHeight;
      
      final houseColors = [
        Colors.red[300]!, Colors.blue[300]!, Colors.green[300]!, 
        Colors.purple[300]!, Colors.orange[300]!, Colors.teal[300]!
      ];
      final colorIndex = letter.character.codeUnitAt(0) % houseColors.length;
      final houseColor = houseColors[colorIndex];
    
      return Container(
        width: houseWidth,
        height: houseHeight,
      child: Stack(
        children: [
          // Sombra de la casa
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Techo triangular responsivo
                CustomPaint(
                  size: Size(roofWidth, roofHeight),
                  painter: _RoofPainter(
                    color: Colors.brown[600]!,
                    shadowColor: Colors.brown[800]!,
                  ),
                ),
                // Cuerpo de la casa responsivo
                Container(
                  width: houseWidth,
                  height: bodyHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        houseColor.withOpacity(0.9),
                        houseColor,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: isSmallScreen ? 2.0 : (isMediumScreen ? 3.0 : 4.0),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Letra principal responsiva
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(
                            isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(
                              isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)
                            ),
                            border: Border.all(
                              color: houseColor, 
                              width: isSmallScreen ? 2.0 : (isMediumScreen ? 3.0 : 4.0)
                            ),
                          ),
                          child: Text(
                            letter.character,
                            style: TextStyle(
                              fontSize: isSmallScreen 
                                ? (isNear ? 72 : 64) 
                                : (isMediumScreen 
                                  ? (isNear ? 108 : 96) 
                                  : (isNear ? 144 : 128)), // Letras SÚPER MEGA GIGANTES!
                              fontWeight: FontWeight.bold,
                              color: houseColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      // Ventanas responsivas
                      Positioned(
                        top: isSmallScreen ? 8 : (isMediumScreen ? 10 : 12),
                        left: isSmallScreen ? 8 : (isMediumScreen ? 10 : 12),
                        child: Container(
                          width: isSmallScreen ? 48 : (isMediumScreen ? 70 : 90),
                          height: isSmallScreen ? 48 : (isMediumScreen ? 70 : 90),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            border: Border.all(
                              color: Colors.brown[400]!, 
                              width: isSmallScreen ? 1 : (isMediumScreen ? 1.5 : 2)
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isSmallScreen ? 8 : (isMediumScreen ? 10 : 12),
                        right: isSmallScreen ? 8 : (isMediumScreen ? 10 : 12),
                        child: Container(
                          width: isSmallScreen ? 48 : (isMediumScreen ? 70 : 90),
                          height: isSmallScreen ? 48 : (isMediumScreen ? 70 : 90),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[100],
                            border: Border.all(
                              color: Colors.brown[400]!, 
                              width: isSmallScreen ? 1 : (isMediumScreen ? 1.5 : 2)
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // Puerta responsiva
                      Positioned(
                        bottom: 0,
                        left: (houseWidth - (isSmallScreen ? 80 : (isMediumScreen ? 120 : 160))) / 2,
                        child: Container(
                          width: isSmallScreen ? 80 : (isMediumScreen ? 120 : 160),
                          height: isSmallScreen ? 70 : (isMediumScreen ? 110 : 150),
                          decoration: BoxDecoration(
                            color: Colors.brown[400],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isSmallScreen ? 8 : (isMediumScreen ? 10 : 12)),
                              topRight: Radius.circular(isSmallScreen ? 8 : (isMediumScreen ? 10 : 12)),
                            ),
                            border: Border.all(
                              color: Colors.brown[600]!, 
                              width: isSmallScreen ? 1 : (isMediumScreen ? 1.5 : 2)
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: isSmallScreen ? 16 : (isMediumScreen ? 24 : 32),
                              height: isSmallScreen ? 16 : (isMediumScreen ? 24 : 32),
                              decoration: BoxDecoration(
                                color: Colors.yellow[600],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Indicador de estrellas responsivo
                      if (letter.stars > 0)
                        Positioned(
                          top: isSmallScreen ? 4 : (isMediumScreen ? 6 : 8),
                          left: isSmallScreen ? 4 : (isMediumScreen ? 6 : 8),
                          child: Container(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 3.0 : (isMediumScreen ? 4.0 : 5.0)
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[600],
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 4 : (isMediumScreen ? 6 : 8)
                              ),
                            ),
                            child: Text(
                              '★${letter.stars}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : (isMediumScreen ? 14 : 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Etiqueta de nombre responsiva
          if (isNear)
            Positioned(
              top: -(isSmallScreen ? 30.0 : (isMediumScreen ? 35.0 : 40.0)),
              left: -(isSmallScreen ? 15.0 : (isMediumScreen ? 20.0 : 25.0)),
              right: -(isSmallScreen ? 15.0 : (isMediumScreen ? 20.0 : 25.0)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0),
                  vertical: isSmallScreen ? 4.0 : (isMediumScreen ? 5.0 : 6.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)
                  ),
                  border: Border.all(
                    color: houseColor, 
                    width: isSmallScreen ? 1.5 : (isMediumScreen ? 2.0 : 2.5)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: isSmallScreen ? 4.0 : (isMediumScreen ? 6.0 : 8.0),
                      offset: Offset(0, isSmallScreen ? 2.0 : (isMediumScreen ? 3.0 : 4.0)),
                    ),
                  ],
                ),
                child: Text(
                  letter.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14.0 : (isMediumScreen ? 18.0 : 22.0),
                    fontWeight: FontWeight.bold,
                    color: houseColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
    } catch (e) {
      // Fallback responsivo en caso de error
      final isSmallScreen = screenSize.width < 600;
      final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
      final fallbackWidth = isSmallScreen ? 300.0 : (isMediumScreen ? 450.0 : 600.0);
      final fallbackHeight = isSmallScreen ? 350.0 : (isMediumScreen ? 520.0 : 700.0);
      
      return Container(
        width: fallbackWidth,
        height: fallbackHeight,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.home,
            size: isSmallScreen ? 120 : (isMediumScreen ? 180 : 240),
            color: Colors.white,
          ),
        ),
      );
    }
  }
}

// Painter personalizado para el techo triangular
class _RoofPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  _RoofPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Techo principal
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Sombra del techo (lado derecho)
    final shadowPath = Path();
    shadowPath.moveTo(size.width / 2, 0);
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width - 4, size.height);
    shadowPath.lineTo(size.width / 2, 4);
    shadowPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}