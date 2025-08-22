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
              Color(0xFF1E3A8A), // Azul profundo nocturno (arriba)
              Color(0xFF3B82F6), // Azul cielo medio
              Color(0xFF60A5FA), // Azul cielo claro
              Color(0xFFFBBF24), // Amarillo dorado horizonte
              Color(0xFFEA580C), // Naranja atardecer
              Color(0xFFDC2626), // Rojo atardecer intenso
              Color(0xFF7C2D12), // Marrón rojizo (horizonte bajo)
            ],
            stops: [0.0, 0.2, 0.4, 0.6, 0.75, 0.85, 1.0], // Distribución de colores
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
                    color: Color(0xFF7B1FA2), // Color violeta
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 36 : 52,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia', // Tipografía elegante y educativa
                      color: const Color(0xFFFFFFFF), // Blanco puro
                      letterSpacing: 2.0,
                      height: 1.2,
                      shadows: [
                        // Efecto 3D con gradiente de sombras
                        const Shadow(
                          blurRadius: 2.0,
                          color: Color(0xFF2E7D32), // Verde oscuro
                          offset: Offset(1.0, 1.0),
                        ),
                        const Shadow(
                          blurRadius: 4.0,
                          color: Color(0xFF1B5E20), // Verde más oscuro
                          offset: Offset(2.0, 2.0),
                        ),
                        const Shadow(
                          blurRadius: 6.0,
                          color: Color(0xFF0D3D14), // Verde muy oscuro
                          offset: Offset(3.0, 3.0),
                        ),
                        // Contorno dorado
                        const Shadow(
                          blurRadius: 1.0,
                          color: Color(0xFFFFD700), // Dorado
                          offset: Offset(0.5, 0.5),
                        ),
                        // Brillo sutil
                        const Shadow(
                          blurRadius: 8.0,
                          color: Color(0x40FFFFFF), // Blanco transparente
                          offset: Offset(0, 0),
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
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50).withValues(alpha: 0.2),
                        const Color(0xFF2E7D32).withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '¡A aprender che!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 22 : 28,
                      fontFamily: 'Comic Sans MS', // Fuente divertida y educativa
                      color: const Color(0xFFFFFFFF), // Blanco puro
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      height: 1.1,
                      shadows: [
                        // Efecto de profundidad argentino
                        const Shadow(
                          blurRadius: 2.0,
                          color: Color(0xFF0277BD), // Azul cielo argentino
                          offset: Offset(1.0, 1.0),
                        ),
                        const Shadow(
                          blurRadius: 4.0,
                          color: Color(0xFF01579B), // Azul más profundo
                          offset: Offset(2.0, 2.0),
                        ),
                        // Brillo dorado sutil
                        const Shadow(
                          blurRadius: 6.0,
                          color: Color(0x60FFD700), // Dorado transparente
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
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
                      Text(
                        'Preparando tu aventura argentina...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 20, // Responsivo
                          fontWeight: FontWeight.w600,
                          shadows: [
                            // Sombra verde oscuro principal
                            const Shadow(
                              blurRadius: 5.0,
                              color: Color(0xFF1B5E20), // Verde oscuro
                              offset: Offset(2.5, 2.5),
                            ),
                            // Sombra negra para mayor contraste
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.black87,
                              offset: Offset(1.5, 1.5),
                            ),
                            // Contorno adicional
                            const Shadow(
                              blurRadius: 12.0,
                              color: Color(0xFF2E7D32), // Verde medio
                              offset: Offset(3.0, 3.0),
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
    
    // Vacas estáticas pastando en diferentes partes del campo
    animals.add(_buildStaticAnimal('🐄', 0.15, 120, 35));
    animals.add(_buildStaticAnimal('🐄', 0.75, 110, 32));
    animals.add(_buildStaticAnimal('🐄', 0.45, 130, 38));
    
    // Caballos quietos pastando
    animals.add(_buildStaticAnimal('🐎', 0.25, 150, 35));
    animals.add(_buildStaticAnimal('🐴', 0.75, 140, 33));
    
    // Chanchos estáticos descansando
    animals.add(_buildStaticAnimal('🐷', 0.35, 100, 28));
    animals.add(_buildStaticAnimal('🐷', 0.65, 115, 30));
    
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
  
  /*
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
  */
  
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 50 : 70,
          height: isSmallScreen ? 50 : 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 35),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 25 : 35,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white, // Cambiado a blanco para mayor contraste
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w800, // Aumentado peso de fuente
            shadows: [
              // Sombra negra principal más gruesa
              const Shadow(
                blurRadius: 4.0,
                color: Colors.black87,
                offset: Offset(2.0, 2.0),
              ),
              // Contorno negro completo para mejor legibilidad
              const Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(-1.5, -1.5),
              ),
              const Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(1.5, -1.5),
              ),
              const Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(-1.5, 1.5),
              ),
              const Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(1.5, 1.5),
              ),
              // Sombra adicional azul oscuro para mayor profundidad
              const Shadow(
                blurRadius: 6.0,
                color: Color(0xFF1B5E20),
                offset: Offset(3.0, 3.0),
              ),
            ],
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
    
    // Dibujar muchos árboles en el horizonte con FRUTAS Y VERDURAS intercaladas
    for (int i = 0; i < 20; i++) { // Aumentamos a 20 elementos
      final x = (size.width / 19) * i;
      
      // Alternamos entre árboles frutales y cultivos de verduras
      if (i % 4 == 0) {
        _paintFruitTree(canvas, x, horizonY, i);
      } else if (i % 4 == 1) {
        _paintVegetableField(canvas, x, horizonY, i);
      } else if (i % 4 == 2) {
        _paintRegularTree(canvas, x, horizonY, i);
      } else {
        _paintBerryBush(canvas, x, horizonY, i);
      }
    }
  }
  
  void _paintFruitTree(Canvas canvas, double x, double horizonY, int index) {
    // Árboles frutales (manzanos, naranjos, etc.)
    final trunkPaint = Paint()..color = Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(x - 4, horizonY - 20, 8, 20),
      trunkPaint,
    );
    
    // Copa verde
    final leafPaint = Paint()..color = Color(0xFF228B22);
    canvas.drawOval(
      Rect.fromLTWH(x - 20, horizonY - 50, 40, 35),
      leafPaint,
    );
    
    // Frutas colgando (manzanas rojas, naranjas, etc.)
    final fruitColors = [Color(0xFFFF4444), Color(0xFFFF8800), Color(0xFFFFDD00)];
    final fruitPaint = Paint()..color = fruitColors[index % 3];
    
    // Varias frutas en el árbol
    canvas.drawCircle(Offset(x - 8, horizonY - 35), 3, fruitPaint);
    canvas.drawCircle(Offset(x + 6, horizonY - 40), 3, fruitPaint);
    canvas.drawCircle(Offset(x - 2, horizonY - 45), 3, fruitPaint);
    canvas.drawCircle(Offset(x + 12, horizonY - 30), 3, fruitPaint);
  }
  
  void _paintVegetableField(Canvas canvas, double x, double horizonY, int index) {
    // Campos de verduras (zanahorias, lechugas, tomates)
    final soilPaint = Paint()..color = Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(x - 15, horizonY - 8, 30, 8),
      soilPaint,
    );
    
    // Diferentes tipos de verduras
    if (index % 3 == 0) {
      // Zanahorias (hojas verdes)
      final leafPaint = Paint()..color = Color(0xFF32CD32);
      for (int j = 0; j < 4; j++) {
        final carrotX = x - 12 + (j * 8);
        canvas.drawRect(
          Rect.fromLTWH(carrotX - 1, horizonY - 15, 2, 8),
          leafPaint,
        );
        // Parte naranja de la zanahoria (underground)
        final carrotPaint = Paint()..color = Color(0xFFFF8C00);
        canvas.drawCircle(Offset(carrotX, horizonY - 3), 2, carrotPaint);
      }
    } else if (index % 3 == 1) {
      // Lechugas
      final lettucePaint = Paint()..color = Color(0xFF90EE90);
      for (int j = 0; j < 3; j++) {
        final lettuceX = x - 10 + (j * 10);
        canvas.drawOval(
          Rect.fromLTWH(lettuceX - 4, horizonY - 12, 8, 8),
          lettucePaint,
        );
      }
    } else {
      // Tomateras
      final stemPaint = Paint()..color = Color(0xFF228B22);
      final tomatoPaint = Paint()..color = Color(0xFFFF6347);
      for (int j = 0; j < 3; j++) {
        final tomatoX = x - 8 + (j * 8);
        // Tallo
        canvas.drawRect(
          Rect.fromLTWH(tomatoX - 1, horizonY - 20, 2, 15),
          stemPaint,
        );
        // Tomates
        canvas.drawCircle(Offset(tomatoX - 3, horizonY - 15), 2.5, tomatoPaint);
        canvas.drawCircle(Offset(tomatoX + 3, horizonY - 12), 2.5, tomatoPaint);
      }
    }
  }
  
  void _paintRegularTree(Canvas canvas, double x, double horizonY, int index) {
    // Árboles regulares (como el código original)
    final treeHeight = 40.0 + (index % 3) * 20;
    final treeWidth = 25.0 + (index % 2) * 15;
    
    final trunkPaint = Paint()..color = Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(x - 3, horizonY - 15, 6, 15),
      trunkPaint,
    );
    
    final treePaint = Paint()..color = Color(0xFF228B22);
    canvas.drawOval(
      Rect.fromLTWH(
        x - treeWidth / 2, 
        horizonY - treeHeight, 
        treeWidth, 
        treeHeight * 0.8
      ),
      treePaint,
    );
  }
  
  void _paintBerryBush(Canvas canvas, double x, double horizonY, int index) {
    // Arbustos de frutos del bosque (frutillas, arándanos)
    final bushPaint = Paint()..color = Color(0xFF32CD32);
    
    // Arbusto base
    canvas.drawOval(
      Rect.fromLTWH(x - 12, horizonY - 25, 24, 20),
      bushPaint,
    );
    
    // Frutos pequeños
    final berryColors = [Color(0xFFFF1493), Color(0xFF4169E1), Color(0xFF8B008B)];
    final berryPaint = Paint()..color = berryColors[index % 3];
    
    // Varios frutos en el arbusto
    canvas.drawCircle(Offset(x - 6, horizonY - 18), 2, berryPaint);
    canvas.drawCircle(Offset(x + 4, horizonY - 20), 2, berryPaint);
    canvas.drawCircle(Offset(x - 2, horizonY - 15), 2, berryPaint);
    canvas.drawCircle(Offset(x + 8, horizonY - 12), 2, berryPaint);
    canvas.drawCircle(Offset(x - 8, horizonY - 10), 2, berryPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}