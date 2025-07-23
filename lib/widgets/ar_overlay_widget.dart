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


      // Asegurar que tenemos letras antes de crear animaciones (máximo 27)
      final letterCount = math.max(1, math.min(27, widget.letters.length));
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

      // Temporalmente deshabilitado para evitar loops
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) {
      //     _floatController.repeat(reverse: true);
      //     _rotationController.repeat();
      //   }
      // });
    } catch (e) {
      // En caso de error en inicialización, crear animaciones básicas limitadas
      _floatController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );
      _rotationController = AnimationController(
        duration: const Duration(seconds: 30),
        vsync: this,
      );
      
      // Crear solo las animaciones necesarias (máximo 27)
      final fallbackCount = math.min(27, math.max(1, widget.letters.length));
      _floatAnimations = List.generate(
        fallbackCount,
        (index) => Tween<double>(begin: 0, end: 0).animate(_floatController),
      );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use LayoutBuilder to ensure we have valid constraints
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Temporalmente sin animaciones para evitar loop
        try {
          // Limitar el número de letras para evitar overflow
          final limitedLetters = widget.letters.take(27).toList(); // Máximo 27 letras
          
          
          return Stack(
                clipBehavior: Clip.hardEdge,
                children: limitedLetters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final letter = entry.value;
                  
                  // Protección contra índices fuera de rango
                  if (index >= _floatAnimations.length || index >= 27) {
                    return const SizedBox.shrink();
                  }
                  
                  // Valores fijos temporalmente para evitar loop
                  const floatValue = 0.0;
                  const rotationValue = 0.0;
                  
                  return _buildFloatingHouse(
                    letter,
                    index,
                    size,
                    floatValue,
                    rotationValue,
                  );
                }).toList(),
              );
            } catch (e) {
              // En caso de error, mostrar algo simple en lugar de pantalla roja
              return Container(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
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

      // Distribución espacial responsiva
      final lettersPerRing = isSmallScreen ? 4 : (isMediumScreen ? 6 : 8);
      final ring = (index / lettersPerRing).floor();
      final positionInRing = index % lettersPerRing;
      
      // Radios MASIVOS para casas más visibles
      final baseRadiusMultiplier = isSmallScreen ? 0.15 : (isMediumScreen ? 0.18 : 0.20);
      final minRadius = isSmallScreen ? 120.0 : (isMediumScreen ? 150.0 : 180.0);
      final ringSpacing = isSmallScreen ? 120.0 : (isMediumScreen ? 140.0 : 160.0);
      
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
      
      // Márgenes reducidos para casas más centralizadas y visibles
      final marginX = isSmallScreen ? 20.0 : (isMediumScreen ? 40.0 : 100.0);
      final marginY = isSmallScreen ? 20.0 : (isMediumScreen ? 40.0 : 120.0);
      
      final safeFloatOffset = floatOffset.isFinite ? floatOffset.clamp(-15.0, 15.0) : 0.0;
      final x = (screenSize.width * 0.5 + finalRadius * math.cos(angle))
          .clamp(marginX, screenSize.width - marginX);
      final y = (screenSize.height * 0.5 + 
                (finalRadius * math.sin(angle) * 0.4) + 
                safeFloatOffset + 
                (ring * 10)).clamp(marginY, screenSize.height - marginY);
      
      // Sistema de escala responsivo - casas grandes pero un poco más chicas
      final baseScale = isSmallScreen ? 1.1 : (isMediumScreen ? 1.4 : 1.1);
      final distanceFromCenter = math.sqrt(
        math.pow(x - screenSize.width * 0.5, 2) + 
        math.pow(y - screenSize.height * 0.5, 2)
      );
      final maxDistance = math.min(screenSize.width, screenSize.height) * 0.2;
      final normalizedDistance = (distanceFromCenter / maxDistance).clamp(0.0, 1.0);
      
      // Escala mínima balanceada para casas visibles
      final minScale = isSmallScreen ? 1.2 : (isMediumScreen ? 1.5 : 1.8);
      final scale = (baseScale - (normalizedDistance * 0.3)).clamp(minScale, baseScale * 1.2);
      final opacity = (1.0 - (normalizedDistance * 0.2)).clamp(0.6, 1.0);

      // Escala interactiva mejorada
      final isHighlighted = widget.highlightedLetter == letter.character;
      final safeHouseScale = widget.houseScale.isFinite ? widget.houseScale.clamp(1.0, 3.0) : 1.0;
      final finalScale = isHighlighted 
          ? (scale * safeHouseScale).clamp(minScale, baseScale * 1.5)
          : scale;

      // Tamaños reducidos para las casas con valores mínimos seguros
      final itemWidth = math.max(120.0, isSmallScreen ? 160.0 : (isMediumScreen ? 200.0 : 240.0));
      final itemHeight = math.max(140.0, isSmallScreen ? 180.0 : (isMediumScreen ? 220.0 : 260.0));
      
      // Offsets ajustados para casas más pequeñas
      final positionOffsetWidth = isSmallScreen ? 80.0 : (isMediumScreen ? 100.0 : 120.0);
      final positionOffsetHeight = isSmallScreen ? 90.0 : (isMediumScreen ? 110.0 : 130.0);
      
      // Asegurar que las posiciones estén dentro de los límites de pantalla
      final safeLeft = (x - positionOffsetWidth).clamp(0.0, screenSize.width - itemWidth);
      final safeTop = (y - positionOffsetHeight).clamp(0.0, screenSize.height - itemHeight);

      return Positioned(
        left: safeLeft,
        top: safeTop,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: itemWidth,
            maxWidth: itemWidth,
            minHeight: itemHeight,
            maxHeight: itemHeight,
          ),
          child: SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: finalScale.clamp(1.0, 2.0), // Escala más controlada
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  minWidth: itemWidth * 0.8,
                  maxWidth: itemWidth * 1.2,
                  minHeight: itemHeight * 0.8,
                  maxHeight: itemHeight * 1.2,
                ),
                decoration: isHighlighted ? BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ) : null,
                child: Opacity(
                  opacity: opacity.clamp(0.3, 1.0),
                  child: GestureDetector(
                    onTap: () => widget.onLetterTap(letter),
                    child: _buildHouseWidget(letter, normalizedDistance, screenSize),
                  ),
                ),
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
      
      // Tamaños reducidos para VR con valores mínimos seguros
      final houseWidth = math.max(120.0, isSmallScreen ? 160.0 : (isMediumScreen ? 200.0 : 240.0));
      final houseHeight = math.max(140.0, isSmallScreen ? 180.0 : (isMediumScreen ? 220.0 : 260.0));
      final roofWidth = houseWidth;
      final roofHeight = math.min(houseHeight * 0.4, isSmallScreen ? 60.0 : (isMediumScreen ? 80.0 : 100.0));
      final bodyHeight = math.max(60.0, houseHeight - roofHeight);
      
      final houseColors = [
        Colors.red[300]!, Colors.blue[300]!, Colors.green[300]!, 
        Colors.purple[300]!, Colors.orange[300]!, Colors.teal[300]!
      ];
      final colorIndex = letter.character.codeUnitAt(0) % houseColors.length;
      final houseColor = houseColors[colorIndex];
    
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: math.max(80.0, houseWidth * 0.8),
          maxWidth: math.min(screenSize.width * 0.4, houseWidth * 1.2),
          minHeight: math.max(100.0, houseHeight * 0.8),
          maxHeight: math.min(screenSize.height * 0.4, houseHeight * 1.2),
        ),
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            if (outerConstraints.maxWidth <= 0 || outerConstraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }
            
            final constrainedWidth = math.min(houseWidth, outerConstraints.maxWidth);
            final constrainedHeight = math.min(houseHeight, outerConstraints.maxHeight);
            
            return SizedBox(
              width: constrainedWidth,
              height: constrainedHeight,
              child: Stack(
                children: [
                  // Sombra de la casa
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Techo triangular responsivo
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: math.max(60.0, roofWidth * 0.8),
                            maxWidth: roofWidth,
                            minHeight: math.max(30.0, roofHeight * 0.8),
                            maxHeight: roofHeight,
                          ),
                          child: CustomPaint(
                            size: Size(roofWidth, roofHeight),
                            painter: _RoofPainter(
                              color: Colors.brown[600]!,
                              shadowColor: Colors.brown[800]!,
                            ),
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
                                houseColor.withValues(alpha: 0.9),
                                houseColor,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: isSmallScreen ? 2.0 : (isMediumScreen ? 3.0 : 4.0),
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                                return const SizedBox.shrink();
                              }
                              return Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  // Letra principal responsiva
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
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
                                            ? (isNear ? 36 : 32) // Reducidos
                                            : (isMediumScreen 
                                              ? (isNear ? 44 : 40) // Reducidos
                                              : (isNear ? 52 : 48)), // Reducidos
                                          fontWeight: FontWeight.bold,
                                          color: houseColor.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Ventanas responsivas
                                  Positioned(
                                    top: math.max(4.0, constraints.maxHeight * 0.1),
                                    left: math.max(4.0, constraints.maxWidth * 0.1),
                                    child: Container(
                                      width: math.min(constraints.maxWidth * 0.3, isSmallScreen ? 60 : (isMediumScreen ? 80 : 100)),
                                      height: math.min(constraints.maxHeight * 0.4, isSmallScreen ? 60 : (isMediumScreen ? 80 : 100)),
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
                                    top: math.max(4.0, constraints.maxHeight * 0.1),
                                    right: math.max(4.0, constraints.maxWidth * 0.1),
                                    child: Container(
                                      width: math.min(constraints.maxWidth * 0.3, isSmallScreen ? 60 : (isMediumScreen ? 80 : 100)),
                                      height: math.min(constraints.maxHeight * 0.4, isSmallScreen ? 60 : (isMediumScreen ? 80 : 100)),
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
                                    left: math.max(0.0, (constraints.maxWidth - math.min(constraints.maxWidth * 0.5, isSmallScreen ? 80 : (isMediumScreen ? 100 : 120))) / 2),
                                    child: Container(
                                      width: math.min(constraints.maxWidth * 0.5, isSmallScreen ? 80 : (isMediumScreen ? 100 : 120)),
                                      height: math.min(constraints.maxHeight * 0.6, isSmallScreen ? 90 : (isMediumScreen ? 110 : 130)),
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
                                          width: math.min(constraints.maxWidth * 0.1, isSmallScreen ? 20 : (isMediumScreen ? 25 : 30)),
                                          height: math.min(constraints.maxHeight * 0.1, isSmallScreen ? 20 : (isMediumScreen ? 25 : 30)),
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
                                      top: math.max(2.0, constraints.maxHeight * 0.05),
                                      left: math.max(2.0, constraints.maxWidth * 0.05),
                                      child: Container(
                                        padding: EdgeInsets.all(
                                          math.max(2.0, math.min(constraints.maxWidth * 0.02, isSmallScreen ? 3.0 : (isMediumScreen ? 4.0 : 5.0)))
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
                              );
                            },
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
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)
                          ),
                          border: Border.all(
                            color: houseColor, 
                            width: isSmallScreen ? 1.5 : (isMediumScreen ? 2.0 : 2.5)
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
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
          },
        ),
    );
    } catch (e) {
      // Fallback responsivo en caso de error - MÁS GRANDE para niños
      final isSmallScreen = screenSize.width < 600;
      final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
      final fallbackWidth = isSmallScreen ? 160.0 : (isMediumScreen ? 200.0 : 240.0);
      final fallbackHeight = isSmallScreen ? 180.0 : (isMediumScreen ? 220.0 : 260.0);
      
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: math.max(80.0, fallbackWidth * 0.8),
          maxWidth: math.min(screenSize.width * 0.3, fallbackWidth),
          minHeight: math.max(100.0, fallbackHeight * 0.8),
          maxHeight: math.min(screenSize.height * 0.3, fallbackHeight),
        ),
        child: Container(
          width: fallbackWidth,
          height: fallbackHeight,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.home,
              size: isSmallScreen ? 60 : (isMediumScreen ? 80 : 100), // Icono fallback reducido
              color: Colors.white,
            ),
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