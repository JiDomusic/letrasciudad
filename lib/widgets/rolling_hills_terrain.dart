import 'package:flutter/material.dart';
import 'dart:math' as math;

class RollingHillsTerrain extends StatelessWidget {
  final Size terrainSize;

  const RollingHillsTerrain({
    super.key,
    required this.terrainSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RollingHillsPainter(),
      size: terrainSize,
    );
  }
}

class RollingHillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cielo con degradado
    _drawSky(canvas, size);
    
    // 2. Montañas de fondo
    _drawBackgroundMountains(canvas, size);
    
    // 3. Colinas medias
    _drawMiddleHills(canvas, size);
    
    // 4. Colinas principales onduladas
    _drawMainRollingHills(canvas, size);
    
    // 5. Sendero serpenteante
    _drawWindingPath(canvas, size);
    
    // 6. Detalles decorativos
    _drawDecorations(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF87CEEB), // Azul cielo claro
        const Color(0xFFB0E2FF), // Azul más claro
        const Color(0xFFE0F6FF), // Casi blanco
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = skyGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
      );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
      paint,
    );
  }

  void _drawBackgroundMountains(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Montañas lejanas (más claras)
    paint.color = const Color(0xFF9CC69B);
    final distantMountains = Path();
    distantMountains.moveTo(0, size.height * 0.35);
    
    for (double x = 0; x <= size.width; x += 40) {
      final height = size.height * 0.25 + 
                    math.sin((x / size.width) * math.pi * 3) * 30 +
                    math.cos((x / size.width) * math.pi * 5) * 20;
      distantMountains.lineTo(x, height);
    }
    
    distantMountains.lineTo(size.width, size.height);
    distantMountains.lineTo(0, size.height);
    distantMountains.close();
    canvas.drawPath(distantMountains, paint);
  }

  void _drawMiddleHills(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Colinas medias
    paint.color = const Color(0xFF7CB342);
    final middleHills = Path();
    middleHills.moveTo(0, size.height * 0.5);
    
    for (double x = 0; x <= size.width; x += 25) {
      final height = size.height * 0.4 + 
                    math.sin((x / size.width) * math.pi * 4) * 40 +
                    math.cos((x / size.width) * math.pi * 2.5) * 25;
      middleHills.lineTo(x, height);
    }
    
    middleHills.lineTo(size.width, size.height);
    middleHills.lineTo(0, size.height);
    middleHills.close();
    canvas.drawPath(middleHills, paint);
  }

  void _drawMainRollingHills(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Colinas principales con múltiples capas para profundidad
    final hillColors = [
      const Color(0xFF4CAF50), // Verde más oscuro (frente)
      const Color(0xFF66BB6A), // Verde medio
      const Color(0xFF81C784), // Verde claro
    ];
    
    for (int layer = 2; layer >= 0; layer--) {
      paint.color = hillColors[layer];
      final hills = Path();
      final baseHeight = size.height * (0.6 + layer * 0.05);
      
      hills.moveTo(0, baseHeight);
      
      for (double x = 0; x <= size.width; x += 15) {
        final wave1 = math.sin((x / size.width + layer * 0.2) * math.pi * 6) * (30 - layer * 5);
        final wave2 = math.cos((x / size.width + layer * 0.3) * math.pi * 4) * (20 - layer * 3);
        final wave3 = math.sin((x / size.width + layer * 0.1) * math.pi * 8) * (15 - layer * 2);
        
        final height = baseHeight + wave1 + wave2 + wave3;
        hills.lineTo(x, height);
      }
      
      hills.lineTo(size.width, size.height);
      hills.lineTo(0, size.height);
      hills.close();
      canvas.drawPath(hills, paint);
      
      // Sombras suaves para dar profundidad
      if (layer > 0) {
        paint.color = Colors.black.withOpacity(0.1);
        final shadowHills = Path();
        shadowHills.moveTo(0, baseHeight + 3);
        
        for (double x = 0; x <= size.width; x += 15) {
          final wave1 = math.sin((x / size.width + layer * 0.2) * math.pi * 6) * (30 - layer * 5);
          final wave2 = math.cos((x / size.width + layer * 0.3) * math.pi * 4) * (20 - layer * 3);
          final wave3 = math.sin((x / size.width + layer * 0.1) * math.pi * 8) * (15 - layer * 2);
          
          final height = baseHeight + wave1 + wave2 + wave3 + 3;
          shadowHills.lineTo(x, height);
        }
        
        shadowHills.lineTo(size.width, size.height);
        shadowHills.lineTo(0, size.height);
        shadowHills.close();
        canvas.drawPath(shadowHills, paint);
      }
    }
  }

  void _drawWindingPath(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFFD2B48C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    final pathOutline = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    final windingPath = Path();
    windingPath.moveTo(size.width * 0.1, size.height * 0.9);
    
    // Sendero serpenteante que sigue las colinas
    for (double t = 0; t <= 1; t += 0.02) {
      final x = size.width * t;
      final pathCurve = math.sin(t * math.pi * 5) * 80;
      final hillFollow = math.sin(t * math.pi * 4) * 20;
      final y = size.height * (0.85 - t * 0.3) + pathCurve + hillFollow;
      
      windingPath.lineTo(x, y);
    }
    
    // Dibujar contorno y luego el sendero
    canvas.drawPath(windingPath, pathOutline);
    canvas.drawPath(windingPath, pathPaint);
  }

  void _drawDecorations(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Árboles dispersos
    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.6 + random.nextDouble() * 0.3);
      
      _drawTree(canvas, Offset(x, y), 15 + random.nextDouble() * 10);
    }
    
    // Arbustos pequeños
    paint.color = const Color(0xFF2E7D32);
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.7 + random.nextDouble() * 0.25);
      final radius = 3 + random.nextDouble() * 5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Flores dispersas
    final flowerColors = [
      Colors.red[300]!,
      Colors.yellow[300]!,
      Colors.purple[300]!,
      Colors.pink[300]!,
      Colors.orange[300]!,
    ];
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.75 + random.nextDouble() * 0.2);
      paint.color = flowerColors[random.nextInt(flowerColors.length)];
      
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
    
    // Nubes suaves
    paint.color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.1 + random.nextDouble() * 0.2);
      
      _drawCloud(canvas, Offset(x, y), 20 + random.nextDouble() * 15);
    }
  }

  void _drawTree(Canvas canvas, Offset position, double size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Tronco
    paint.color = const Color(0xFF8D6E63);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(position.dx, position.dy + size * 0.3),
          width: size * 0.2,
          height: size * 0.6,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    
    // Copa del árbol
    paint.color = const Color(0xFF2E7D32);
    canvas.drawCircle(
      Offset(position.dx, position.dy - size * 0.2),
      size * 0.4,
      paint,
    );
    
    // Hojas más claras para profundidad
    paint.color = const Color(0xFF4CAF50);
    canvas.drawCircle(
      Offset(position.dx - size * 0.1, position.dy - size * 0.3),
      size * 0.25,
      paint,
    );
  }

  void _drawCloud(Canvas canvas, Offset position, double size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // Nube con múltiples círculos
    canvas.drawCircle(position, size * 0.5, paint);
    canvas.drawCircle(
      Offset(position.dx + size * 0.3, position.dy),
      size * 0.4,
      paint,
    );
    canvas.drawCircle(
      Offset(position.dx - size * 0.3, position.dy),
      size * 0.4,
      paint,
    );
    canvas.drawCircle(
      Offset(position.dx, position.dy - size * 0.2),
      size * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}