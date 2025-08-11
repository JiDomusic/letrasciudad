import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/letter_city_provider.dart';
import 'home_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animalAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animalAnimationController = AnimationController(
      duration: const Duration(seconds: 25),  // Aumentado de 15 a 25 segundos
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
    _animalAnimationController.repeat();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 5));
    
    if (mounted) {
      await _requestPermissions();
      _navigateToHome();
    }
  }

  Future<void> _requestPermissions() async {
    final provider = context.read<LetterCityProvider>();
    
    if (kIsWeb) {
      // En web, asumimos que los permisos están disponibles
      provider.setCameraPermission(true);
    } else {
      // Solo solicitar permisos en dispositivos móviles
      try {
        // Este código solo se ejecutará en mobile
        provider.setCameraPermission(true);
      } catch (e) {
        provider.setCameraPermission(false);
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF74ACDF), // Celeste argentino
              Color(0xFFFFDD44), // Amarillo sol
              Color(0xFF4CAF50), // Verde pampa
            ],
          ),
        ),
        child: Stack(
          children: [
            // PAISAJE PAMPEANO DE FONDO
            _buildPampaBackground(),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.home_outlined, // Icono de casa más claro y apropiado
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black87,
                        offset: Offset(3.0, 3.0),
                      ),
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Parque de Letras',
                        speed: const Duration(milliseconds: 120),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '¡A aprender che!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black87,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureIcon(Icons.music_note, 'Canciones'),
                          _buildFeatureIcon(Icons.stars, 'Mate y letras'),
                          _buildFeatureIcon(Icons.emoji_emotions, '¡Che, qué bueno!'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Preparando tu aventura argentina...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black87,
                              offset: Offset(1.5, 1.5),
                            ),
                          ],
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
    );
  }

  Widget _buildPampaBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PampaPainter(),
        child: Stack(
          children: [
            // Árboles estáticos bien separados
            const Positioned(
              left: 30,
              bottom: 200,
              child: Text('🌳', style: TextStyle(fontSize: 50)),
            ),
            const Positioned(
              right: 40,
              bottom: 220,
              child: Text('🌳', style: TextStyle(fontSize: 45)),
            ),
            const Positioned(
              left: 300,
              bottom: 180,
              child: Text('🌲', style: TextStyle(fontSize: 40)),
            ),
            
            // Animales animados bien separados por el campo
            ..._buildAnimatedAnimals(),
            
            // Vegetación estática
            const Positioned(
              left: 15,
              bottom: 60,
              child: Text('🌾', style: TextStyle(fontSize: 28)),
            ),
            const Positioned(
              right: 25,
              bottom: 65,
              child: Text('🌾', style: TextStyle(fontSize: 25)),
            ),
            const Positioned(
              left: 180,
              bottom: 50,
              child: Text('🌿', style: TextStyle(fontSize: 22)),
            ),
            const Positioned(
              right: 200,
              bottom: 55,
              child: Text('🌿', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedAnimals() {
    final animals = <Widget>[];
    
    // Vacas caminando por diferentes partes del campo
    animals.add(_buildMovingAnimal('🐄', 0.15, 120, 35, 0.2));
    animals.add(_buildMovingAnimal('🐄', 0.75, 110, 32, 0.35));
    animals.add(_buildMovingAnimal('🐄', 0.45, 130, 38, 0.6));
    
    // Caballos quietos pastando
    animals.add(_buildStaticAnimal('🐎', 0.25, 150, 35));
    animals.add(_buildStaticAnimal('🐴', 0.75, 140, 33));
    
    // Chanchos caminando
    animals.add(_buildMovingAnimal('🐷', 0.35, 100, 28, 0.4));
    animals.add(_buildMovingAnimal('🐷', 0.65, 115, 30, 0.7));
    
    // Ovejas
    animals.add(_buildBouncingAnimal('🐑', 0.55, 125, 32, 0.25));
    animals.add(_buildBouncingAnimal('🐐', 0.1, 105, 26, 0.9));
    
    // Gallinas y gallos picoteando
    animals.add(_buildPeckingAnimal('🐔', 0.2, 85, 25, 0.3));
    animals.add(_buildPeckingAnimal('🐓', 0.8, 90, 28, 0.1));
    animals.add(_buildPeckingAnimal('🐔', 0.5, 95, 26, 0.65));
    animals.add(_buildPeckingAnimal('🐔', 0.9, 88, 24, 0.85));
    
    // Pollitos siguiendo
    animals.add(_buildFollowingAnimal('🐤', 0.22, 80, 18, 0.32));
    animals.add(_buildFollowingAnimal('🐤', 0.52, 88, 20, 0.67));
    
    return animals;
  }
  
  // Animales estáticos (para caballos que no se mueven)
  Widget _buildStaticAnimal(String emoji, double xFactor, double baseY, double fontSize) {
    return AnimatedBuilder(
      animation: _animalAnimationController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final x = size.width * xFactor;
        // Solo un pequeño movimiento de respiración
        final breathe = math.sin(_animalAnimationController.value * 1 * math.pi) * 1;
        
        return Positioned(
          left: x,
          bottom: baseY + breathe,
          child: Text(
            emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }
  
  Widget _buildMovingAnimal(String emoji, double xFactor, double baseY, double fontSize, double offset) {
    return AnimatedBuilder(
      animation: _animalAnimationController,
      builder: (context, child) {
        final progress = (_animalAnimationController.value + offset) % 1.0;
        final size = MediaQuery.of(context).size;
        final x = progress * (size.width - 60) + 30;
        final bounce = math.sin(progress * 8) * 1;
        
        return Positioned(
          left: x,
          bottom: baseY + bounce,
          child: Text(
            emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }
  
  Widget _buildBouncingAnimal(String emoji, double xFactor, double baseY, double fontSize, double offset) {
    return AnimatedBuilder(
      animation: _animalAnimationController,
      builder: (context, child) {
        final bounce = math.sin((_animalAnimationController.value + offset) * 2 * math.pi) * 2;
        final sway = math.cos((_animalAnimationController.value + offset) * 1.5 * math.pi) * 5;
        final size = MediaQuery.of(context).size;
        
        return Positioned(
          left: size.width * xFactor + sway,
          bottom: baseY + bounce,
          child: Text(
            emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }
  
  Widget _buildPeckingAnimal(String emoji, double xFactor, double baseY, double fontSize, double offset) {
    return AnimatedBuilder(
      animation: _animalAnimationController,
      builder: (context, child) {
        final peck = math.sin((_animalAnimationController.value + offset) * 4 * math.pi) * 2;
        final waddle = math.sin((_animalAnimationController.value + offset) * 1 * math.pi) * 3;
        final size = MediaQuery.of(context).size;
        
        return Positioned(
          left: size.width * xFactor + waddle,
          bottom: baseY + peck,
          child: Text(
            emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }
  
  Widget _buildFollowingAnimal(String emoji, double xFactor, double baseY, double fontSize, double offset) {
    return AnimatedBuilder(
      animation: _animalAnimationController,
      builder: (context, child) {
        final follow = math.sin((_animalAnimationController.value + offset) * 2 * math.pi) * 3;
        final hop = math.sin((_animalAnimationController.value + offset) * 6 * math.pi) * 1;
        final size = MediaQuery.of(context).size;
        
        return Positioned(
          left: size.width * xFactor + follow,
          bottom: baseY + hop,
          child: Text(
            emoji,
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PampaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Cielo gradiente
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        Color(0xFF87CEEB), // Celeste cielo
        Color(0xFFE0F6FF), // Celeste muy claro
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      paint,
    );
    
    // HORIZONTE CON ÁRBOLES
    _paintTreeHorizon(canvas, size);
    
    // Pasto pampeano
    paint.shader = LinearGradient(
      begin: Alignment.center,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF98FB98), // Verde claro
        Color(0xFF228B22), // Verde más oscuro
        Color(0xFF006400), // Verde muy oscuro
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));
    
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      paint,
    );
    
    // Líneas de pasto eliminadas por solicitud del usuario
  }
  
  void _paintTreeHorizon(Canvas canvas, Size size) {
    final treePaint = Paint()
      ..color = Color(0xFF228B22) // Verde oscuro para árboles
      ..style = PaintingStyle.fill;
    
    final horizonY = size.height * 0.5; // Línea del horizonte
    
    // Dibujar muchos árboles en el horizonte
    for (int i = 0; i < 15; i++) {
      final x = (size.width / 14) * i;
      final treeHeight = 40.0 + (i % 3) * 20; // Árboles de diferentes alturas
      final treeWidth = 25.0 + (i % 2) * 15;
      
      // Tronco del árbol
      final trunkPaint = Paint()..color = Color(0xFF8B4513); // Marrón
      canvas.drawRect(
        Rect.fromLTWH(x - 3, horizonY - 15, 6, 15),
        trunkPaint,
      );
      
      // Copa del árbol (forma ovalada)
      canvas.drawOval(
        Rect.fromLTWH(
          x - treeWidth / 2, 
          horizonY - treeHeight, 
          treeWidth, 
          treeHeight * 0.8
        ),
        treePaint,
      );
      
      // Segundo nivel de copa (más pequeño)
      if (i % 3 == 0) {
        canvas.drawOval(
          Rect.fromLTWH(
            x - treeWidth / 3, 
            horizonY - treeHeight * 0.7, 
            treeWidth * 0.6, 
            treeHeight * 0.5
          ),
          treePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}