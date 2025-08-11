import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/letter_city_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
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
        child: Container(
          child: Stack(
            children: [
              // Árboles
              const Positioned(
                left: 50,
                bottom: 180,
                child: Text('🌳', style: TextStyle(fontSize: 60)),
              ),
              const Positioned(
                right: 80,
                bottom: 200,
                child: Text('🌳', style: TextStyle(fontSize: 45)),
              ),
              const Positioned(
                left: 150,
                bottom: 160,
                child: Text('🌲', style: TextStyle(fontSize: 40)),
              ),
              // Vacas
              const Positioned(
                right: 120,
                bottom: 120,
                child: Text('🐄', style: TextStyle(fontSize: 35)),
              ),
              const Positioned(
                left: 200,
                bottom: 100,
                child: Text('🐄', style: TextStyle(fontSize: 30)),
              ),
              // Gallinas y pollitos
              const Positioned(
                left: 80,
                bottom: 90,
                child: Text('🐔', style: TextStyle(fontSize: 25)),
              ),
              const Positioned(
                left: 110,
                bottom: 85,
                child: Text('🐤', style: TextStyle(fontSize: 20)),
              ),
              const Positioned(
                left: 130,
                bottom: 88,
                child: Text('🐤', style: TextStyle(fontSize: 18)),
              ),
              const Positioned(
                right: 60,
                bottom: 95,
                child: Text('🐓', style: TextStyle(fontSize: 28)),
              ),
              // MÁS ANIMALES DE GRANJA
              const Positioned(
                left: 300,
                bottom: 110,
                child: Text('🐷', style: TextStyle(fontSize: 28)), // Cerdito
              ),
              const Positioned(
                right: 150,
                bottom: 130,
                child: Text('🐑', style: TextStyle(fontSize: 32)), // Oveja
              ),
              const Positioned(
                left: 40,
                bottom: 110,
                child: Text('🐐', style: TextStyle(fontSize: 26)), // Cabra
              ),
              // MÁS VACAS, GALLINAS Y CABALLOS
              const Positioned(
                left: 350,
                bottom: 140,
                child: Text('🐄', style: TextStyle(fontSize: 38)), // Vaca grande
              ),
              const Positioned(
                right: 250,
                bottom: 90,
                child: Text('🐄', style: TextStyle(fontSize: 32)), // Otra vaca
              ),
              const Positioned(
                left: 180,
                bottom: 120,
                child: Text('🐔', style: TextStyle(fontSize: 28)), // Más gallinas
              ),
              const Positioned(
                right: 180,
                bottom: 85,
                child: Text('🐓', style: TextStyle(fontSize: 30)), // Más gallos
              ),
              const Positioned(
                left: 260,
                bottom: 95,
                child: Text('🐔', style: TextStyle(fontSize: 26)), // Otra gallina
              ),
              // CABALLOS
              const Positioned(
                right: 90,
                bottom: 140,
                child: Text('🐎', style: TextStyle(fontSize: 35)), // Caballo
              ),
              const Positioned(
                left: 320,
                bottom: 160,
                child: Text('🐴', style: TextStyle(fontSize: 33)), // Otro caballo
              ),
              // MÁS CERDITOS
              const Positioned(
                right: 200,
                bottom: 110,
                child: Text('🐷', style: TextStyle(fontSize: 30)), // Más cerditos
              ),
              const Positioned(
                left: 150,
                bottom: 135,
                child: Text('🐷', style: TextStyle(fontSize: 25)), // Otro cerdito
              ),
              // Yuyos y pasto
              const Positioned(
                left: 20,
                bottom: 60,
                child: Text('🌾', style: TextStyle(fontSize: 30)),
              ),
              const Positioned(
                right: 40,
                bottom: 65,
                child: Text('🌾', style: TextStyle(fontSize: 25)),
              ),
              const Positioned(
                left: 250,
                bottom: 70,
                child: Text('🌿', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
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