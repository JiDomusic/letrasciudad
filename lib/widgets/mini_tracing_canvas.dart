import 'package:flutter/material.dart';
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
          });
        }
      },
      onPanEnd: (details) {
        if (!_isCompleted && _currentStroke.isNotEmpty) {
          setState(() {
            _strokes.add([..._currentStroke]);
            _currentStroke.clear();
            
            // Simular trazado completo después de un trazo
            _isCompleted = true;
          });
          
          widget.onTracingComplete();
        }
      },
      child: CustomPaint(
        painter: _MiniTracingPainter(
          _strokes, 
          _currentStroke, 
          widget.letter,
          _isCompleted,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// Pintor para el trazado mini de letras
class _MiniTracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final String letter;
  final bool isCompleted;

  _MiniTracingPainter(this.strokes, this.currentStroke, this.letter, this.isCompleted);

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