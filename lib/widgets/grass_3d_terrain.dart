import 'package:flutter/material.dart';
import 'dart:math' as math;

class Grass3DTerrain extends StatelessWidget {
  final Size terrainSize;
  final double elevation;

  const Grass3DTerrain({
    super.key,
    required this.terrainSize,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: Grass3DPainter(elevation: elevation),
      size: terrainSize,
    );
  }
}

class Grass3DPainter extends CustomPainter {
  final double elevation;
  
  Grass3DPainter({required this.elevation});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dibujar base del terreno 3D
    _drawTerrainBase(canvas, size);
    
    // 2. Dibujar pasto individual en 3D
    _drawGrassBlades(canvas, size);
    
    // 3. Dibujar flores dispersas
    _drawFlowers(canvas, size);
    
    // 4. Dibujar rocas pequeñas
    _drawRocks(canvas, size);
  }

  void _drawTerrainBase(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Degradado del terreno con profundidad
    final terrainGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF228B22), // Verde claro
        const Color(0xFF006400), // Verde oscuro
        const Color(0xFF2E7D32), // Verde medio
        const Color(0xFF1B5E20), // Verde muy oscuro
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    paint.shader = terrainGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    
    // Crear superficie irregular del terreno
    final terrainPath = Path();
    terrainPath.moveTo(0, size.height * 0.3);
    
    // Ondulaciones del terreno
    for (double x = 0; x <= size.width; x += 20) {
      final waveHeight = math.sin((x / size.width) * math.pi * 4) * 8;
      final depthVariation = math.cos((x / size.width) * math.pi * 2) * 5;
      terrainPath.lineTo(x, size.height * 0.3 + waveHeight + depthVariation + elevation);
    }
    
    terrainPath.lineTo(size.width, size.height);
    terrainPath.lineTo(0, size.height);
    terrainPath.close();
    
    canvas.drawPath(terrainPath, paint);
    
    // Sombras del terreno para dar profundidad
    paint.shader = null;
    paint.color = Colors.black.withValues(alpha: 0.1);
    
    for (double x = 0; x <= size.width; x += 40) {
      final shadowHeight = math.sin((x / size.width) * math.pi * 3) * 4;
      final shadowPath = Path();
      shadowPath.moveTo(x, size.height * 0.3 + shadowHeight + elevation);
      shadowPath.lineTo(x + 20, size.height * 0.3 + shadowHeight + elevation + 2);
      shadowPath.lineTo(x + 20, size.height);
      shadowPath.lineTo(x, size.height);
      shadowPath.close();
      canvas.drawPath(shadowPath, paint);
    }
  }

  void _drawGrassBlades(Canvas canvas, Size size) {
    final random = math.Random(42); // Semilla fija
    final grassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Dibujar briznas de pasto individuales
    for (int i = 0; i < 800; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * 0.3 + 
                   math.sin((x / size.width) * math.pi * 4) * 8 + 
                   elevation;
      
      // Altura variable del pasto
      final grassHeight = 8 + random.nextDouble() * 12;
      final grassWidth = 0.8 + random.nextDouble() * 1.2;
      
      // Color del pasto con variación
      final grassColors = [
        const Color(0xFF228B22),
        const Color(0xFF32CD32),
        const Color(0xFF90EE90),
        const Color(0xFF006400),
      ];
      
      grassPaint.color = grassColors[random.nextInt(grassColors.length)];
      grassPaint.strokeWidth = grassWidth;
      
      // Pasto curvado (más realista)
      final curvature = (random.nextDouble() - 0.5) * 6;
      final controlX = x + curvature;
      final controlY = baseY - grassHeight * 0.6;
      final endX = x + curvature * 0.7;
      final endY = baseY - grassHeight;
      
      final grassPath = Path();
      grassPath.moveTo(x, baseY);
      grassPath.quadraticBezierTo(controlX, controlY, endX, endY);
      
      canvas.drawPath(grassPath, grassPaint);
      
      // Sombra del pasto para profundidad 3D
      if (random.nextDouble() > 0.7) {
        grassPaint.color = Colors.black.withValues(alpha: 0.2);
        grassPaint.strokeWidth = grassWidth * 0.5;
        
        final shadowPath = Path();
        shadowPath.moveTo(x + 1, baseY + 0.5);
        shadowPath.quadraticBezierTo(controlX + 1, controlY + 0.5, endX + 1, endY + 0.5);
        
        canvas.drawPath(shadowPath, grassPaint);
      }
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final random = math.Random(123); // Semilla diferente
    final flowerPaint = Paint()..style = PaintingStyle.fill;
    
    final flowerColors = [
      Colors.red[300]!,
      Colors.yellow[300]!,
      Colors.blue[300]!,
      Colors.pink[300]!,
      Colors.purple[300]!,
      Colors.orange[300]!,
    ];
    
    // Flores dispersas
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * 0.3 + 
                   math.sin((x / size.width) * math.pi * 4) * 8 + 
                   elevation;
      
      flowerPaint.color = flowerColors[random.nextInt(flowerColors.length)];
      
      // Pétalos de la flor
      for (int petal = 0; petal < 5; petal++) {
        final angle = (petal / 5) * 2 * math.pi;
        final petalX = x + math.cos(angle) * 3;
        final petalY = baseY - 5 + math.sin(angle) * 3;
        
        canvas.drawCircle(Offset(petalX, petalY), 2, flowerPaint);
      }
      
      // Centro de la flor
      flowerPaint.color = Colors.yellow;
      canvas.drawCircle(Offset(x, baseY - 5), 1.5, flowerPaint);
      
      // Tallo
      flowerPaint.color = const Color(0xFF228B22);
      canvas.drawLine(
        Offset(x, baseY - 5),
        Offset(x, baseY),
        Paint()
          ..color = const Color(0xFF228B22)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawRocks(Canvas canvas, Size size) {
    final random = math.Random(456); // Otra semilla
    final rockPaint = Paint()..style = PaintingStyle.fill;
    
    final rockColors = [
      const Color(0xFF696969),
      const Color(0xFF808080),
      const Color(0xFF556B2F),
      const Color(0xFF2F4F4F),
    ];
    
    // Rocas pequeñas dispersas
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * 0.3 + 
                   math.sin((x / size.width) * math.pi * 4) * 8 + 
                   elevation;
      
      final rockSize = 2 + random.nextDouble() * 4;
      rockPaint.color = rockColors[random.nextInt(rockColors.length)];
      
      // Forma irregular de la roca
      final rockPath = Path();
      final sides = 6 + random.nextInt(3);
      
      for (int side = 0; side < sides; side++) {
        final angle = (side / sides) * 2 * math.pi;
        final radius = rockSize * (0.7 + random.nextDouble() * 0.6);
        final pointX = x + math.cos(angle) * radius;
        final pointY = baseY + math.sin(angle) * radius * 0.6; // Aplastada
        
        if (side == 0) {
          rockPath.moveTo(pointX, pointY);
        } else {
          rockPath.lineTo(pointX, pointY);
        }
      }
      rockPath.close();
      
      canvas.drawPath(rockPath, rockPaint);
      
      // Sombra de la roca
      rockPaint.color = Colors.black.withValues(alpha: 0.3);
      final shadowPath = Path();
      for (int side = 0; side < sides; side++) {
        final angle = (side / sides) * 2 * math.pi;
        final radius = rockSize * (0.7 + random.nextDouble() * 0.6);
        final pointX = x + math.cos(angle) * radius + 1;
        final pointY = baseY + math.sin(angle) * radius * 0.6 + 0.5;
        
        if (side == 0) {
          shadowPath.moveTo(pointX, pointY);
        } else {
          shadowPath.lineTo(pointX, pointY);
        }
      }
      shadowPath.close();
      
      canvas.drawPath(shadowPath, rockPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}