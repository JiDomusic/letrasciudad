import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_service.dart';

// Widget mini para trazado de letras individuales en palabras
class MiniTracingCanvas extends StatefulWidget {
  final String letter;
  final VoidCallback onTracingComplete;
  final AudioService audioService;

  const MiniTracingCanvas({
    super.key,
    required this.letter,
    required this.onTracingComplete,
    required this.audioService,
  });

  @override
  State<MiniTracingCanvas> createState() => _MiniTracingCanvasState();
}

class _MiniTracingCanvasState extends State<MiniTracingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isCompleted = false;
  double _completionPercentage = 0.0;
  double _accuracyScore = 0.0;
  Size _canvasSize = const Size(80, 100); // Tamaño por defecto
  
  // Variables para feedback inmediato y continuo
  DateTime _lastFeedbackTime = DateTime.now();
  bool _wasTracingWell = true;
  int _consecutiveGoodPoints = 0;
  int _consecutiveBadPoints = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (!_isCompleted) {
          _currentStroke = [details.localPosition];
        }
      },
      onPanUpdate: (details) {
        if (!_isCompleted) {
          setState(() {
            _currentStroke.add(details.localPosition);
            // FEEDBACK CONTINUO E INMEDIATO en MiniTracingCanvas
            _provideContinuousFeedback();
          });
        }
      },
      onPanEnd: (details) {
        if (!_isCompleted && _currentStroke.isNotEmpty) {
          setState(() {
            _strokes.add([..._currentStroke]);
            _currentStroke.clear();
            
            // Validar trazado real antes de completar
            _updateCompletionPercentage();
            if (_completionPercentage > 0.75 && _accuracyScore > 0.7) {
              _isCompleted = true;
              // Mensaje más entusiasta cuando completa
              final celebrations = [
                '¡EXCELENTE! Trazaste perfectamente la letra ${widget.letter}',
                '¡INCREÍBLE! Tu letra ${widget.letter} quedó perfecta',
                '¡GENIAL! Hiciste una ${widget.letter} hermosa',
                '¡FANTÁSTICO! Eres muy bueno trazando la ${widget.letter}'
              ];
              final message = celebrations[DateTime.now().millisecond % celebrations.length];
              widget.audioService.speakText(message);
            } else if (_completionPercentage > 0.3 && _accuracyScore < 0.5) {
              widget.audioService.speakText('Sigue la forma de la letra ${widget.letter}. No hagas garabatos.');
            }
          });
          
          if (_isCompleted) {
            widget.onTracingComplete();
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            painter: _MiniTracingPainter(
              _strokes, 
              _currentStroke, 
              widget.letter,
              _isCompleted,
              _canvasSize,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  void _updateCompletionPercentage() {
    if (_currentStroke.isEmpty) return;
    
    final letterPath = _getLetterPath(widget.letter, _canvasSize);
    int validPoints = 0;
    
    // Validar todos los trazos
    for (final stroke in _strokes) {
      for (final point in stroke) {
        if (_isPointNearPath(point, letterPath, _canvasSize)) {
          validPoints++;
        }
      }
    }
    
    // Validar trazo actual
    for (final point in _currentStroke) {
      if (_isPointNearPath(point, letterPath, _canvasSize)) {
        validPoints++;
      }
    }
    
    final totalPoints = _strokes.fold<int>(0, (sum, stroke) => sum + stroke.length) + _currentStroke.length;
    final requiredPoints = _getRequiredPointsForLetter(widget.letter);
    
    _completionPercentage = math.min(1.0, (validPoints / requiredPoints) * 0.8);
    _accuracyScore = totalPoints > 0 ? validPoints / totalPoints : 0.0;
  }

  int _getRequiredPointsForLetter(String letter) {
    const letterComplexity = {
      'A': 25, 'B': 35, 'C': 20, 'D': 25, 'E': 30, 'F': 25, 'G': 30,
      'H': 30, 'I': 15, 'J': 20, 'K': 35, 'L': 20, 'M': 40, 'N': 25,
      'Ñ': 30, 'O': 20, 'P': 25, 'Q': 30, 'R': 35, 'S': 25, 'T': 20,
      'U': 20, 'V': 25, 'W': 35, 'X': 25, 'Y': 30, 'Z': 25,
    };
    return letterComplexity[letter.toUpperCase()] ?? 25;
  }

  // NUEVO: Feedback continuo e inmediato para MiniTracingCanvas
  void _provideContinuousFeedback() {
    final now = DateTime.now();
    final timeSinceLastFeedback = now.difference(_lastFeedbackTime).inMilliseconds;
    
    // Solo dar feedback cada 3 segundos para no saturar
    if (timeSinceLastFeedback < 3000) return;
    
    // Verificar si el último punto del trazo actual está cerca del path correcto
    if (_currentStroke.isNotEmpty) {
      final lastPoint = _currentStroke.last;
      final letterPath = _getLetterPath(widget.letter, _canvasSize);
      final isPointCorrect = _isPointNearPath(lastPoint, letterPath, _canvasSize);
      
      if (isPointCorrect) {
        _consecutiveGoodPoints++;
        _consecutiveBadPoints = 0;
        
        // Felicitar después de MUCHOS puntos buenos (menos frecuente)
        if (_consecutiveGoodPoints >= 10 && !_wasTracingWell) {
          _wasTracingWell = true;
          _lastFeedbackTime = now;
          final encouragements = [
            '¡Muy bien! Sigues bien la letra ${widget.letter}',
            '¡Perfecto! Así se hace la ${widget.letter}',
            '¡Genial! Tu ${widget.letter} se ve perfecta',
            '¡Excelente trazado de la ${widget.letter}!'
          ];
          final message = encouragements[DateTime.now().millisecond % encouragements.length];
          widget.audioService.speakText(message);
          print('🎤 Mini feedback positivo: $message');
        }
      } else {
        _consecutiveBadPoints++;
        _consecutiveGoodPoints = 0;
        
        // Ayudar después de MUCHOS puntos malos (menos frecuente)
        if (_consecutiveBadPoints >= 8 && _wasTracingWell) {
          _wasTracingWell = false;
          _lastFeedbackTime = now;
          final corrections = [
            'Sigue la forma de la letra ${widget.letter}',
            'No hagas garabatos, sigue la línea de la ${widget.letter}',
            'Vuelve a la forma correcta de la ${widget.letter}',
            'Despacio, traza bien la ${widget.letter}'
          ];
          final message = corrections[DateTime.now().millisecond % corrections.length];
          widget.audioService.speakText(message);
          print('🎤 Mini feedback correctivo: $message');
        }
      }
    }
  }

  Path _getLetterPath(String letter, Size canvasSize) {
    final path = Path();
    
    // Escalar proporcionalmente al tamaño del canvas
    final scaleX = canvasSize.width / 80;  // Tamaño de referencia 80
    final scaleY = canvasSize.height / 100; // Tamaño de referencia 100
    
    switch (letter.toUpperCase()) {
      case 'V':
        path.moveTo(15 * scaleX, 10 * scaleY);
        path.lineTo(40 * scaleX, 80 * scaleY);
        path.lineTo(65 * scaleX, 10 * scaleY);
        break;
      case 'W':
        path.moveTo(10 * scaleX, 10 * scaleY);
        path.lineTo(20 * scaleX, 80 * scaleY);
        path.lineTo(40 * scaleX, 40 * scaleY);
        path.lineTo(60 * scaleX, 80 * scaleY);
        path.lineTo(70 * scaleX, 10 * scaleY);
        break;
      case 'K':
        path.moveTo(15 * scaleX, 10 * scaleY);
        path.lineTo(15 * scaleX, 80 * scaleY);
        path.moveTo(15 * scaleX, 45 * scaleY);
        path.lineTo(65 * scaleX, 10 * scaleY);
        path.moveTo(15 * scaleX, 45 * scaleY);
        path.lineTo(65 * scaleX, 80 * scaleY);
        break;
      case 'Y':
        path.moveTo(15 * scaleX, 10 * scaleY);
        path.lineTo(40 * scaleX, 45 * scaleY);
        path.moveTo(65 * scaleX, 10 * scaleY);
        path.lineTo(40 * scaleX, 45 * scaleY);
        path.lineTo(40 * scaleX, 80 * scaleY);
        break;
      case 'Ñ':
        path.moveTo(15 * scaleX, 80 * scaleY);
        path.lineTo(15 * scaleX, 15 * scaleY);
        path.lineTo(65 * scaleX, 80 * scaleY);
        path.lineTo(65 * scaleX, 15 * scaleY);
        // Tilde de la Ñ
        path.moveTo(25 * scaleX, 5 * scaleY);
        path.quadraticBezierTo(40 * scaleX, 0, 55 * scaleX, 5 * scaleY);
        break;
      case 'B':
        path.moveTo(15 * scaleX, 10 * scaleY);
        path.lineTo(15 * scaleX, 80 * scaleY);
        path.moveTo(15 * scaleX, 10 * scaleY);
        path.quadraticBezierTo(50 * scaleX, 10 * scaleY, 50 * scaleX, 30 * scaleY);
        path.quadraticBezierTo(50 * scaleX, 45 * scaleY, 15 * scaleX, 45 * scaleY);
        path.moveTo(15 * scaleX, 45 * scaleY);
        path.quadraticBezierTo(55 * scaleX, 45 * scaleY, 55 * scaleX, 65 * scaleY);
        path.quadraticBezierTo(55 * scaleX, 80 * scaleY, 15 * scaleX, 80 * scaleY);
        break;
      default:
        // Círculo genérico escalado
        path.addOval(Rect.fromLTWH(
          20 * scaleX, 
          20 * scaleY, 
          40 * scaleX, 
          40 * scaleY
        ));
    }
    
    return path;
  }

  bool _isPointNearPath(Offset point, Path letterPath, Size canvasSize) {
    // Tolerancia proporcional al tamaño del canvas (más generosa en móvil)
    final scaleFactor = math.min(canvasSize.width, canvasSize.height) / 80.0;
    final tolerance = 20.0 * scaleFactor; // Más generoso para trazado táctil
    
    final pathMetrics = letterPath.computeMetrics();
    if (pathMetrics.isEmpty) return false;
    
    double minDistance = double.infinity;
    
    for (final pathMetric in pathMetrics) {
      final pathLength = pathMetric.length;
      
      for (double i = 0; i < pathLength; i += math.max(1.0, pathLength / 50)) {
        final tangent = pathMetric.getTangentForOffset(i);
        if (tangent?.position != null) {
          final distance = (point - tangent!.position).distance;
          if (distance < minDistance) {
            minDistance = distance;
          }
        }
      }
    }
    
    return minDistance <= tolerance;
  }
}

// Pintor para el trazado mini de letras
class _MiniTracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String letter;
  final bool isCompleted;
  final Size canvasSize;

  _MiniTracingPainter(this.strokes, this.currentStroke, this.letter, this.isCompleted, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Pintura para los trazos
    final strokePaint = Paint()
      ..color = isCompleted ? Colors.green : Colors.orange[400]!
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Dibujar la letra de fondo en gris claro
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.height * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.grey[300],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Dibujar trazos completados
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], strokePaint);
      }
    }

    // Dibujar trazo actual
    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], strokePaint);
    }

    // Si está completado, mostrar la letra final en color
    if (isCompleted) {
      final completedTextPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            fontSize: size.height * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      completedTextPainter.layout();
      completedTextPainter.paint(
        canvas, 
        Offset(
          (size.width - completedTextPainter.width) / 2,
          (size.height - completedTextPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}