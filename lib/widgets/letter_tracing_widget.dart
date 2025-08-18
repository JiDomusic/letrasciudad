import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_service.dart';

/// Widget de trazado interactivo para las 27 letras del alfabeto argentino
class LetterTracingWidget extends StatefulWidget {
  final String letter;
  final VoidCallback? onTracingComplete;
  final AudioService audioService;

  const LetterTracingWidget({
    super.key,
    required this.letter,
    this.onTracingComplete,
    required this.audioService,
  });

  @override
  State<LetterTracingWidget> createState() => _LetterTracingWidgetState();
}

class _LetterTracingWidgetState extends State<LetterTracingWidget>
    with TickerProviderStateMixin {
  final List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  bool _isCompleted = false;
  double _completionPercentage = 0.0;
  
  late AnimationController _celebrationController;
  late AnimationController _hintController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _hintAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _hintController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _hintAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
    
    // Reproducir instrucción al iniciar
    _playInstructions();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _playInstructions() {
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.audioService.speakText(
        'Traza la letra ${widget.letter} con tu dedo. ¡Sigue las líneas punteadas!'
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      _currentStroke.add(details.localPosition);
      _updateCompletionPercentage();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _userStrokes.add([..._currentStroke]);
        _currentStroke.clear();
        
        // Verificar si el trazado está completo
        if (_completionPercentage > 0.7) {
          _completeTracing();
        }
      }
    });
  }

  void _updateCompletionPercentage() {
    // Algoritmo simple: porcentaje basado en cantidad de trazos
    final totalPoints = _userStrokes.fold<int>(0, (sum, stroke) => sum + stroke.length) + 
                       _currentStroke.length;
    
    // Diferentes letras requieren diferentes cantidades de trazos
    final requiredPoints = _getRequiredPointsForLetter(widget.letter);
    _completionPercentage = math.min(1.0, totalPoints / requiredPoints);
  }

  int _getRequiredPointsForLetter(String letter) {
    // Puntos requeridos aproximados para cada letra
    const letterComplexity = {
      'A': 80, 'B': 100, 'C': 60, 'D': 80, 'E': 90, 'F': 80, 'G': 90,
      'H': 90, 'I': 40, 'J': 60, 'K': 100, 'L': 60, 'M': 120, 'N': 80,
      'Ñ': 90, 'O': 70, 'P': 80, 'Q': 90, 'R': 100, 'S': 80, 'T': 60,
      'U': 70, 'V': 60, 'W': 100, 'X': 80, 'Y': 80, 'Z': 80,
    };
    return letterComplexity[letter.toUpperCase()] ?? 80;
  }

  void _completeTracing() {
    setState(() {
      _isCompleted = true;
    });
    
    _celebrationController.forward();
    _hintController.stop();
    
    widget.audioService.speakText('¡Excelente! Trazaste la letra ${widget.letter} perfectamente!');
    
    widget.onTracingComplete?.call();
    
    // Celebración con confetti virtual
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.audioService.speakText('¡Eres increíble! ¿Quieres intentar otra vez?');
    });
  }

  void _resetTracing() {
    setState(() {
      _userStrokes.clear();
      _currentStroke.clear();
      _isCompleted = false;
      _completionPercentage = 0.0;
    });
    
    _celebrationController.reset();
    _hintController.repeat(reverse: true);
    
    widget.audioService.speakText('¡Perfecto! Vamos a intentar de nuevo.');
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isPhone),
          Expanded(
            child: _buildTracingArea(isPhone),
          ),
          _buildControls(isPhone),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isPhone) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 16 : 20),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_celebrationAnimation.value * 0.3),
                    child: Container(
                      width: isPhone ? 60 : 80,
                      height: isPhone ? 60 : 80,
                      decoration: BoxDecoration(
                        color: _isCompleted ? Colors.green : Colors.blue[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isCompleted ? Colors.green : Colors.blue[600]!)
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.letter.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPhone ? 28 : 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? '¡COMPLETADO!' : 'Trazando letra ${widget.letter.toUpperCase()}',
                      style: TextStyle(
                        fontSize: isPhone ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: _isCompleted ? Colors.green : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _completionPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCompleted ? Colors.green : Colors.blue[600]!,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_completionPercentage * 100).toInt()}% completado',
                      style: TextStyle(
                        fontSize: isPhone ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTracingArea(bool isPhone) {
    return Container(
      margin: EdgeInsets.all(isPhone ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _LetterTracingPainter(
              letter: widget.letter.toUpperCase(),
              userStrokes: _userStrokes,
              currentStroke: _currentStroke,
              isCompleted: _isCompleted,
              hintAnimation: _hintAnimation,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isPhone) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reintentar',
            color: Colors.orange,
            onPressed: _resetTracing,
            isPhone: isPhone,
          ),
          _buildControlButton(
            icon: Icons.volume_up,
            label: 'Escuchar',
            color: Colors.purple,
            onPressed: () => widget.audioService.speakText(
              'La letra ${widget.letter} se pronuncia ${_getLetterPronunciation(widget.letter)}'
            ),
            isPhone: isPhone,
          ),
          if (_isCompleted)
            _buildControlButton(
              icon: Icons.star,
              label: '¡Genial!',
              color: Colors.green,
              onPressed: () {},
              isPhone: isPhone,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isPhone,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isPhone ? 20 : 24),
      label: Text(
        label,
        style: TextStyle(fontSize: isPhone ? 14 : 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 16 : 20,
          vertical: isPhone ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  String _getLetterPronunciation(String letter) {
    const pronunciations = {
      'A': 'ah', 'B': 'beh', 'C': 'ce', 'D': 'de', 'E': 'eh', 'F': 'efe', 'G': 'ge',
      'H': 'ache', 'I': 'i', 'J': 'jota', 'K': 'ka', 'L': 'ele', 'M': 'eme', 'N': 'ene',
      'Ñ': 'eñe', 'O': 'o', 'P': 'pe', 'Q': 'cu', 'R': 'erre', 'S': 'ese', 'T': 'te',
      'U': 'u', 'V': 've corta', 'W': 'doble ve', 'X': 'equis', 'Y': 'ye', 'Z': 'zeta',
    };
    return pronunciations[letter.toUpperCase()] ?? letter.toLowerCase();
  }
}

/// Pintor personalizado para el trazado de letras
class _LetterTracingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> userStrokes;
  final List<Offset> currentStroke;
  final bool isCompleted;
  final Animation<double> hintAnimation;

  _LetterTracingPainter({
    required this.letter,
    required this.userStrokes,
    required this.currentStroke,
    required this.isCompleted,
    required this.hintAnimation,
  }) : super(repaint: hintAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar guía de la letra (fondo)
    _drawLetterGuide(canvas, size);
    
    // Dibujar trazos del usuario
    _drawUserStrokes(canvas, size);
    
    // Dibujar animación de pista si no está completado
    if (!isCompleted) {
      _drawHintAnimation(canvas, size);
    }
    
    // Dibujar efectos de celebración si está completado
    if (isCompleted) {
      _drawCelebrationEffects(canvas, size);
    }
  }

  void _drawLetterGuide(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.height * 0.6,
          fontWeight: FontWeight.w300,
          color: Colors.grey[300],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  void _drawUserStrokes(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = isCompleted ? Colors.green[600]! : Colors.blue[600]!
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dibujar trazos completados
    for (final stroke in userStrokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, strokePaint);
      }
    }

    // Dibujar trazo actual
    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawHintAnimation(Canvas canvas, Size size) {
    final hintPaint = Paint()
      ..color = Colors.orange.withValues(alpha: hintAnimation.value)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Dibujar puntos parpadeantes como guía
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 4, hintPaint);
  }

  void _drawCelebrationEffects(Canvas canvas, Size size) {
    final celebrationPaint = Paint()
      ..color = Colors.yellow[600]!
      ..strokeWidth = 3.0;

    // Dibujar estrellas de celebración
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi) / 5;
      final x = size.width / 2 + math.cos(angle) * (size.width * 0.3);
      final y = size.height / 2 + math.sin(angle) * (size.height * 0.3);
      
      _drawStar(canvas, Offset(x, y), 10, celebrationPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi) / 5;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}