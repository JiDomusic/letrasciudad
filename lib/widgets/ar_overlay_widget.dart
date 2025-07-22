import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/letter.dart';

class AROverlayWidget extends StatefulWidget {
  final List<Letter> letters;
  final Function(Letter) onLetterTap;

  const AROverlayWidget({
    super.key,
    required this.letters,
    required this.onLetterTap,
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
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _floatAnimations = List.generate(
      widget.letters.length,
      (index) => Tween<double>(
        begin: -10,
        end: 10,
      ).animate(CurvedAnimation(
        parent: _floatController,
        curve: Interval(
          index * 0.1,
          1.0,
          curve: Curves.easeInOut,
        ),
      )),
    );

    _floatController.repeat(reverse: true);
    _rotationController.repeat();
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
        return Stack(
          children: widget.letters.asMap().entries.map((entry) {
            final index = entry.key;
            final letter = entry.value;
            
            return _buildFloatingHouse(
              letter,
              index,
              size,
              _floatAnimations[index].value,
              _rotationAnimation.value,
            );
          }).toList(),
        );
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
    // Configuración de parque circular con múltiples anillos
    final totalLetters = widget.letters.length;
    final ring = (index / 9).floor(); // 9 letras por anillo
    final positionInRing = index % 9;
    
    // Radio base para cada anillo (plaza central, anillo interno, anillo externo)
    final baseRadius = ring == 0 ? 80.0 : (ring == 1 ? 140.0 : 200.0);
    final angle = (positionInRing / 9) * 2 * math.pi + rotation * 0.5;
    
    // Posición con efecto de perspectiva de parque
    final x = screenSize.width * 0.5 + baseRadius * math.cos(angle);
    final y = screenSize.height * 0.45 + 
              (baseRadius * math.sin(angle) * 0.4) + 
              floatOffset + 
              (ring * 20); // Elevación por anillo
    
    // Escala basada en la distancia (más cerca = más grande)
    final distance = ring == 0 ? 1.0 : (ring == 1 ? 0.8 : 0.6);
    final scale = 0.5 + distance * 0.4;
    final opacity = 0.6 + distance * 0.4;

    return Positioned(
      left: x - 40,
      top: y - 40,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () => widget.onLetterTap(letter),
            child: _buildHouseWidget(letter, distance),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseWidget(Letter letter, double distance) {
    final isNear = distance > 0.7;
    
    return Container(
      width: 80,
      height: 100,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, distance * 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Techo estilo kiosco de parque (más redondeado y colorido)
                Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green[300]!,
                        Colors.green[500]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    border: Border.all(
                      color: Colors.green[700]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_florist,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                // Base del kiosco con diseño más amigable
                Container(
                  width: 80,
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        letter.primaryColor.withOpacity(0.8),
                        letter.primaryColor,
                        letter.primaryColor.withOpacity(0.9),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          letter.character,
                          style: TextStyle(
                            fontSize: isNear ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (letter.stars > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                math.min(letter.stars, 3),
                                (index) => Icon(
                                  Icons.star,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.brown[600]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.brown[800],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      bottomLeft: Radius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.brown[800],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
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
          ),
          if (isNear)
            Positioned(
              top: -10,
              left: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  letter.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: letter.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}