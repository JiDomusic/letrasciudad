import 'package:flutter/material.dart';
import '../models/letter.dart';

class LetterHouseWidget extends StatefulWidget {
  final Letter letter;
  final VoidCallback onTap;

  const LetterHouseWidget({
    super.key,
    required this.letter,
    required this.onTap,
  });

  @override
  State<LetterHouseWidget> createState() => _LetterHouseWidgetState();
}

class _LetterHouseWidgetState extends State<LetterHouseWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.letter.isUnlocked && widget.letter.stars < 3) {
      _shimmerController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _bounceController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _bounceController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _bounceController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final houseColors = [
      Colors.red[400]!, Colors.blue[400]!, Colors.green[400]!, 
      Colors.purple[400]!, Colors.orange[400]!, Colors.teal[400]!,
      Colors.pink[400]!, Colors.cyan[400]!, Colors.indigo[400]!
    ];
    final houseColor = widget.letter.isUnlocked 
        ? houseColors[widget.letter.character.codeUnitAt(0) % houseColors.length]
        : Colors.grey[400]!;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Casa con forma real
                  Column(
                    children: [
                      // Techo triangular
                      Expanded(
                        flex: 2,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _HouseRoofPainter(
                            color: Colors.brown[600]!,
                            shadowColor: Colors.brown[800]!,
                          ),
                        ),
                      ),
                      // Cuerpo de la casa
                      Expanded(
                        flex: 3,
                        child: Container(
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
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Shimmer effect para casas desbloqueadas
                              if (widget.letter.isUnlocked && widget.letter.stars < 3)
                                AnimatedBuilder(
                                  animation: _shimmerAnimation,
                                  builder: (context, child) {
                                    return Positioned(
                                      left: _shimmerAnimation.value * 100,
                                      child: Container(
                                        width: 40,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              
                              // Letra principal en el centro
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: houseColor, width: 2),
                                  ),
                                  child: Text(
                                    widget.letter.character,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: houseColor.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Ventanas
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[100],
                                    border: Border.all(color: Colors.brown[400]!, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[100],
                                    border: Border.all(color: Colors.brown[400]!, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              
                              // Puerta
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[400],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      border: Border.all(color: Colors.brown[600]!, width: 1),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.yellow[600],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Indicadores de estado
                              if (widget.letter.stars > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        widget.letter.stars.clamp(0, 3),
                                        (index) => Icon(
                                          Icons.star,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              
                              if (widget.letter.isUnlocked && widget.letter.stars == 0)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'NUEVA',
                                      style: TextStyle(
                                        fontSize: 8,
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
                  
                  // Overlay de bloqueo
                  if (!widget.letter.isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  
                  // Etiqueta del nombre en la parte inferior
                  Positioned(
                    bottom: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: houseColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.letter.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: houseColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Barra de progreso en la parte inferior
                  Positioned(
                    bottom: -20,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: widget.letter.activities.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: widget.letter.activities
                                        .where((a) => a.isCompleted)
                                        .length /
                                    widget.letter.activities.length,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(houseColor),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Painter para el techo de la casa
class _HouseRoofPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  _HouseRoofPainter({required this.color, required this.shadowColor});

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
    shadowPath.lineTo(size.width - 6, size.height);
    shadowPath.lineTo(size.width / 2, 6);
    shadowPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}