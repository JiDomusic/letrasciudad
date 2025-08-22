import 'package:flutter/material.dart';
import '../models/letter.dart';
import 'interactive_letter_games_screen.dart';
import '../services/audio_service.dart';
import 'dart:math' as math;

class HousePreviewScreen extends StatefulWidget {
  final Letter letterData;
  final bool isReturningFromGame;

  const HousePreviewScreen({
    super.key, 
    required this.letterData,
    this.isReturningFromGame = false,
  });

  @override
  State<HousePreviewScreen> createState() => _HousePreviewScreenState();
}

class _HousePreviewScreenState extends State<HousePreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _houseController;
  late AnimationController _characterController;
  late AnimationController _doorController;
  late AnimationController _animalsController;
  final AudioService _audioService = AudioService();
  late Animation<double> _houseAnimation;
  late Animation<double> _characterAnimation;
  late Animation<double> _doorAnimation;
  bool _isNarrationPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playNarration();
  }

  void _setupAnimations() {
    _houseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _doorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animalsController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _houseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _houseController, curve: Curves.bounceOut),
    );
    _characterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.elasticOut),
    );
    _doorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _doorController, curve: Curves.easeInOut),
    );

    _houseController.forward();
    _animalsController.repeat();
    Future.delayed(const Duration(milliseconds: 800), () {
      _characterController.forward();
    });
  }

  Future<void> _playNarration() async {
    setState(() {
      _isNarrationPlaying = true;
    });

    try {
      final letter = widget.letterData.character.toUpperCase();
      
      if (widget.isReturningFromGame) {
        // Mensaje de bienvenida de regreso
        await _audioService.speakText(
          '¡Hola otra vez! ¡Qué bueno que regresaste! '
          'Puedes seguir explorando las otras casas. '
          'Hay muchas más letras esperándote para jugar.'
        );
      } else {
        // Mensaje de primera visita
        await _audioService.speakText(
          '¡Hola! ¡Bienvenido a mi casa de la letra $letter! '
          'Puedes entrar a mi puerta y jugar en mi casa a juegos divertidos. '
          'Haz clic en mi puerta para entrar.'
        );
      }
    } catch (e) {
      debugPrint('Error playing narration: $e');
    } finally {
      setState(() {
        _isNarrationPlaying = false;
      });
    }
  }

  String _getNarrationText() {
    String letter = widget.letterData.character.toUpperCase();
    
    if (letter == 'Ñ') {
      return "Elegiste entrar a la casa de la letra $letter. Aquí vamos a jugar con palabras que contienen la letra Ñ, como niño o caña.";
    } else if (letter == 'X') {
      return "Elegiste entrar a la casa de la letra $letter. Aquí vamos a jugar con palabras que contienen la letra X, como taxi o examen.";
    } else {
      return "Elegiste entrar a la casa de la letra $letter. Ahora vamos a jugar con palabras que empiezan con $letter.";
    }
  }

  @override
  void dispose() {
    _houseController.dispose();
    _characterController.dispose();
    _doorController.dispose();
    _animalsController.dispose();
    _audioService.stop();
    super.dispose();
  }

  void _stopNarrationAndNavigate() {
    if (_isNarrationPlaying) {
      _audioService.stop();
      setState(() {
        _isNarrationPlaying = false;
      });
    }
    _openDoorAndEnter();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;
    final isVerySmallScreen = screenSize.height < 600;
    
    return Scaffold(
      body: GestureDetector(
        onTap: _stopNarrationAndNavigate,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB), // Azul cielo
                Color(0xFF90EE90), // Verde claro
                Color(0xFF32CD32), // Verde lima
              ],
            ),
          ),
          child: SafeArea(
            child: isMobile ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: screenSize.height - MediaQuery.of(context).padding.top + 100, // Extra space for house roof
                child: Stack(
                  clipBehavior: Clip.none, // Allow content to overflow if needed
              children: [
              // Sol animado
              _buildAnimatedSun(),
              
              // Colinas de fondo con pasto
              _buildBackgroundHills(),
              
              // Pasto detallado
              _buildDetailedGrass(),
              
              // Tierra extra y vegetación
              _buildExtraGround(),
              
              // Plantas extra (árboles y arbustos)
              ..._buildExtraPlants(),
              
              // Flores dispersas
              ..._buildFlowers(),
              
              // Elementos decorativos adicionales
              ..._buildDecorativeElements(),
              
              // Sendero hacia la casa
              _buildPath(),
              
              // Animales de granja
              ..._buildFarmAnimals(),
              
              // Pajaritos volando
              ..._buildFlyingBirds(),
              
              // Casa principal mejorada - centrada verticalmente
              Positioned.fill(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _houseAnimation,
                    builder: (context, child) {
                      // Responsive scaling based on screen size
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isMobile = screenWidth < 600;
                      final scale = isMobile ? 1.2 : 1.8; // Smaller scale for mobile
                      
                      return Transform.scale(
                        scale: _houseAnimation.value * scale,
                        child: _buildEnhancedHouse(),
                      );
                    },
                  ),
                ),
              ),
              
              // Personaje
              Positioned(
                bottom: MediaQuery.of(context).size.width < 600 ? 80 : 100, // Lower on mobile
                right: MediaQuery.of(context).size.width < 600 ? 40 : 80, // Closer to center on mobile
                child: AnimatedBuilder(
                  animation: _characterAnimation,
                  builder: (context, child) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;
                    final scale = isMobile ? 0.8 : 1.0; // Smaller character on mobile
                    
                    return Transform.scale(
                      scale: _characterAnimation.value * scale,
                      child: _buildCharacter(),
                    );
                  },
                ),
              ),
              
              
              // BOTÓN SÚPER DIVERTIDO PARA VOLVER AL PARQUE
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50),
                        const Color(0xFF2E7D32),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        _audioService.stop(); // Detener audio antes de navegar
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('🏠', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Volver al Parque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Comic Sans MS',
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Indicador de narración e invitación
              if (_isNarrationPlaying)
                Positioned(
                  top: MediaQuery.of(context).size.width < 600 ? 60 : 80, // Higher on mobile
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 600 ? 10 : 20, // Less margin on mobile
                    ),
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 600 ? 15 : 20, // Less padding on mobile
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isReturningFromGame ? Icons.home : Icons.volume_up, 
                              color: Colors.white, 
                              size: 24
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.isReturningFromGame 
                                  ? '🎉 ¡Bienvenido de vuelta!' 
                                  : '🏠 Casa ${widget.letterData.character.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.isReturningFromGame
                              ? 'Puedes seguir explorando las otras casas. Hay muchas más letras esperándote.'
                              : 'Puedes entrar a mi puerta y jugar en mi casa a juegos divertidos.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (widget.isReturningFromGame) ...[
                          // Botón lúdico para volver al home
                          ElevatedButton(
                            onPressed: () {
                              _audioService.stop(); // Detener audio antes de navegar
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.explore, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  '🏘️ Ver todas las casas',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '✨ O puedes entrar otra vez a esta casa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '👆 Haz clic en mi puerta para entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
                ),
              ),
            ) : Stack(
              clipBehavior: Clip.none, // Allow content to overflow if needed
              children: [
              // Sol animado
              _buildAnimatedSun(),
              
              // Colinas de fondo con pasto
              _buildBackgroundHills(),
              
              // Pasto detallado
              _buildDetailedGrass(),
              
              // Tierra extra y vegetación
              _buildExtraGround(),
              
              // Animales de granja
              ..._buildFarmAnimals(),
              
              // Pájaros volando
              ..._buildFlyingBirds(),
              
              // Elementos decorativos (contiene mariposas, rocas, hongos, etc.)
              ..._buildDecorativeElements(),
              
              // Casa principal mejorada - centrada
              Positioned.fill(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _houseAnimation,
                    builder: (context, child) {
                      // Responsive scaling based on screen size
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isMobile = screenWidth < 600;
                      final scale = isMobile ? 1.2 : 1.8; // Smaller scale for mobile
                      
                      return Transform.scale(
                        scale: scale * _houseAnimation.value,
                        child: _buildEnhancedHouse(),
                      );
                    },
                  ),
                ),
              ),
              
              // Personaje
              Positioned(
                bottom: MediaQuery.of(context).size.width < 600 ? 80 : 100, // Lower on mobile
                right: MediaQuery.of(context).size.width < 600 ? 40 : 80, // Closer to center on mobile
                child: AnimatedBuilder(
                  animation: _characterAnimation,
                  builder: (context, child) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;
                    final scale = isMobile ? 0.8 : 1.0; // Smaller character on mobile
                    
                    return Transform.scale(
                      scale: scale * _characterAnimation.value,
                      child: _buildCharacter(),
                    );
                  },
                ),
              ),
              
              
              // BOTÓN SÚPER DIVERTIDO PARA VOLVER AL PARQUE (DESKTOP)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50),
                        const Color(0xFF2E7D32),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        _audioService.stop(); // Detener audio antes de navegar
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('🏠', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Volver al Parque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Comic Sans MS',
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Indicador de narración e invitación
              if (_isNarrationPlaying)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width < 600 ? 10 : 20, // Less margin on mobile
                    ),
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width < 600 ? 15 : 20, // Less padding on mobile
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isReturningFromGame ? Icons.home : Icons.volume_up, 
                              color: Colors.white, 
                              size: 24
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.isReturningFromGame 
                                ? '¡Bienvenido de vuelta!' 
                                : '¡Hola! Soy la letra ${widget.letterData.character.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.isReturningFromGame
                            ? '¿Quieres seguir explorando o regresar al parque?'
                            : '¡Estoy muy emocionado de jugar contigo!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (widget.isReturningFromGame) ...[
                          // Botón lúdico para volver al home
                          ElevatedButton(
                            onPressed: () {
                              _audioService.stop(); // Detener audio antes de navegar
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.home, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '🏡 Volver al Parque',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '✨ O puedes entrar otra vez a esta casa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '👆 Haz clic en mi puerta para entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundHills() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HillsPainter(),
      ),
    );
  }

  Widget _buildEnhancedHouse() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return SizedBox(
      width: isMobile ? 300 : 350, // Smaller house on mobile
      height: isMobile ? 240 : 280, // Proportionally smaller height
      child: Stack(
        children: [
          // 0. CAMINO LARGO ADELANTE DE LA PUERTA
          Positioned(
            bottom: 0,
            left: 120,
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDEB887), // Beige
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCD853F), width: 2),
              ),
            ),
          ),
          
          // LADO DERECHO 3D DE LA CASA (para efecto de profundidad)
          Positioned(
            bottom: 28,
            left: 245,
            child: Container(
              width: 50,
              height: 155,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE0E0E0), // Gris claro
                    const Color(0xFFBDBDBD), // Gris medio
                    const Color(0xFF9E9E9E), // Gris oscuro
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(6, 8),
                  ),
                ],
              ),
            ),
          ),
          
          // Base de la casa con efectos 3D mejorados
          Positioned(
            bottom: 20,
            left: 30,
            child: Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF8F8F8),
                    const Color(0xFFF0F0F0),
                  ],
                ),
                borderRadius: BorderRadius.circular(45),
                border: Border.all(color: const Color(0xFF9C27B0), width: 4),
                boxShadow: [
                  // Sombra principal profunda
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 25,
                    offset: const Offset(8, 12),
                  ),
                  // Sombra secundaria suave
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(12, 16),
                  ),
                  // Brillo interior
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 8,
                    offset: const Offset(-3, -3),
                  ),
                  // Efecto de color violeta
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                    blurRadius: 35,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          
          
          // Techo mejorado con perspectiva (más grande)
          Positioned(
            bottom: 140,
            left: 10,
            child: SizedBox(
              width: 280,
              height: 110,
              child: CustomPaint(
                painter: EnhancedRoofPainter(),
              ),
            ),
          ),
          
          // Camino hacia la puerta
          Positioned(
            bottom: 0,
            left: 120,
            child: Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDEB887),
                    const Color(0xFFCD853F),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          
          // Puerta animada con perspectiva 3D (más grande y clickeable)
          Positioned(
            bottom: 25,
            left: 85, // Ajustado para centrar la puerta más grande
            child: AnimatedBuilder(
                animation: _doorAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Marco de la puerta 3D con profundidad
                      Container(
                        width: 85,
                        height: 105,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF8D6E63), // Marrón marco
                              const Color(0xFF5D4037),
                              const Color(0xFF3E2723),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(42),
                            topRight: Radius.circular(42),
                          ),
                          border: Border.all(color: const Color(0xFF2E1A0F), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(4, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(6, 8),
                            ),
                          ],
                        ),
                      ),
                      // Puerta que se abre con perspectiva 3D
                      Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                        ..rotateY(-_doorAnimation.value * math.pi * 0.7),
                      child: Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6D4C41),
                              const Color(0xFF5D4037),
                              const Color(0xFF4E342E),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border.all(
                            color: const Color(0xFF3E2723),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: Offset(3 + _doorAnimation.value * 5, 5),
                            ),
                            BoxShadow(
                              color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: Offset(-2, -2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Paneles decorativos de la puerta
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                width: 60,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 10,
                              child: Container(
                                width: 60,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Letra prominente en el centro con fondo circular
                            Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.9),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.letterData.character.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 28 : 32,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Arial Black',
                                      color: const Color(0xFF5D4037),
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Picaporte dorado 3D mejorado
                            Positioned(
                              right: 12,
                              top: 40,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFFE082), // Dorado claro
                                      const Color(0xFFFFD700), // Dorado medio
                                      const Color(0xFFFF8F00), // Dorado oscuro
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFFE082).withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      offset: const Offset(-1, -1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8F00),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Ventanas con cortinas
          Positioned(
            bottom: 70,
            left: 40,
            child: _buildWindow(),
          ),
          Positioned(
            bottom: 70,
            right: 60,
            child: _buildWindow(),
          ),
          
          // Chimenea con humo
          Positioned(
            bottom: 150,
            right: 35,
            child: _buildChimney(),
          ),
          
          // Macetas con flores
          Positioned(
            bottom: 5,
            left: 50,
            child: _buildFlowerPot(),
          ),
          Positioned(
            bottom: 5,
            right: 70,
            child: _buildFlowerPot(),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacter() {
    return SizedBox(
      width: 60,
      height: 80,
      child: Column(
        children: [
          // Cabeza
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDBAE), // Color piel
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 18)),
            ),
          ),
          // Cuerpo
          Flexible(
            child: Container(
              width: 36,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPath() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100,
      child: CustomPaint(
        painter: PathPainter(),
        size: Size.infinite,
      ),
    );
  }

  Future<void> _openDoorAndEnter() async {
    
    // Sonido de puerta abriéndose (simular sonido)
    print('🎵 ¡Sonido de puerta abriéndose!');
    
    _doorController.forward();
    
    // Esperar un poco para que se vea la animación
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              InteractiveLetterGamesScreen(letter: widget.letterData),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
      
      // Cuando regrese del juego, reemplazar esta pantalla con la versión de "regreso"
      if (mounted && !widget.isReturningFromGame) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HousePreviewScreen(
                  letterData: widget.letterData,
                  isReturningFromGame: true,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  // Métodos adicionales para elementos de la casa
  Widget _buildAnimatedSun() {
    return AnimatedBuilder(
      animation: _animalsController,
      builder: (context, child) {
        final bounce = math.sin(_animalsController.value * 2 * math.pi) * 8;
        final rotation = _animalsController.value * 2 * math.pi;
        
        return Positioned(
          top: 40 + bounce,
          right: 60,
          child: Transform.rotate(
            angle: rotation * 0.1,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow[200]!,
                    Colors.orange[300]!,
                    Colors.orange[600]!,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Rayos del sol
                  ...List.generate(12, (index) {
                    final angle = (index / 12) * 2 * math.pi;
                    return Positioned(
                      left: 50 + math.cos(angle + rotation) * 35 - 2,
                      top: 50 + math.sin(angle + rotation) * 35 - 12,
                      child: Transform.rotate(
                        angle: angle + math.pi / 2,
                        child: Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow[300]!,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }),
                  // Cara del sol
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.yellow[100]!, Colors.yellow[400]!],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '😊',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedGrass() {
    return Positioned.fill(
      child: CustomPaint(
        painter: DetailedGrassPainter(),
      ),
    );
  }

  Widget _buildExtraGround() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ExtraGroundPainter(),
      ),
    );
  }

  List<Widget> _buildExtraPlants() {
    final plants = <Widget>[];
    
    // Árboles en el fondo
    final treePositions = [
      {'x': 0.05, 'y': 0.3, 'size': 80.0, 'type': '🌳'},
      {'x': 0.15, 'y': 0.25, 'size': 70.0, 'type': '🌲'},
      {'x': 0.85, 'y': 0.28, 'size': 75.0, 'type': '🌳'},
      {'x': 0.95, 'y': 0.32, 'size': 65.0, 'type': '🌲'},
    ];

    for (final tree in treePositions) {
      plants.add(
        Positioned(
          left: MediaQuery.of(context).size.width * (tree['x'] as double),
          bottom: MediaQuery.of(context).size.height * (1 - (tree['y'] as double)),
          child: AnimatedBuilder(
            animation: _animalsController,
            builder: (context, child) {
              final sway = math.sin(_animalsController.value * 1.5 * math.pi) * 3;
              return Transform.translate(
                offset: Offset(sway, 0),
                child: Text(
                  tree['type'] as String,
                  style: TextStyle(fontSize: tree['size'] as double),
                ),
              );
            },
          ),
        ),
      );
    }

    // Arbustos y plantas más grandes
    final bushPositions = [
      {'x': 0.08, 'y': 0.6, 'emoji': '🌿', 'size': 35.0},
      {'x': 0.18, 'y': 0.62, 'emoji': '🍀', 'size': 30.0},
      {'x': 0.28, 'y': 0.58, 'emoji': '🌱', 'size': 25.0},
      {'x': 0.72, 'y': 0.6, 'emoji': '🌿', 'size': 32.0},
      {'x': 0.82, 'y': 0.63, 'emoji': '🍀', 'size': 28.0},
      {'x': 0.92, 'y': 0.58, 'emoji': '🌱', 'size': 30.0},
      {'x': 0.45, 'y': 0.65, 'emoji': '🌾', 'size': 28.0},
      {'x': 0.55, 'y': 0.67, 'emoji': '🌿', 'size': 26.0},
    ];

    for (int i = 0; i < bushPositions.length; i++) {
      final bush = bushPositions[i];
      plants.add(
        Positioned(
          left: MediaQuery.of(context).size.width * (bush['x'] as double),
          bottom: MediaQuery.of(context).size.height * (1 - (bush['y'] as double)),
          child: AnimatedBuilder(
            animation: _animalsController,
            builder: (context, child) {
              final sway = math.sin(_animalsController.value * 2 * math.pi + i * 0.3) * 2;
              return Transform.translate(
                offset: Offset(sway, 0),
                child: Text(
                  bush['emoji'] as String,
                  style: TextStyle(fontSize: bush['size'] as double),
                ),
              );
            },
          ),
        ),
      );
    }

    return plants;
  }

  List<Widget> _buildFlowers() {
    final flowers = <Widget>[];
    final flowerPositions = [
      {'x': 0.15, 'y': 0.75, 'colors': [Colors.white, Colors.pink[300]!, Colors.pink[600]!], 'size': 20.0},
      {'x': 0.85, 'y': 0.72, 'colors': [Colors.white, Colors.purple[300]!, Colors.purple[600]!], 'size': 18.0},
      {'x': 0.25, 'y': 0.68, 'colors': [Colors.white, Colors.red[300]!, Colors.red[600]!], 'size': 22.0},
      {'x': 0.75, 'y': 0.78, 'colors': [Colors.white, Colors.yellow[300]!, Colors.yellow[600]!], 'size': 16.0},
      {'x': 0.4, 'y': 0.82, 'colors': [Colors.white, Colors.blue[300]!, Colors.blue[600]!], 'size': 19.0},
      {'x': 0.6, 'y': 0.85, 'colors': [Colors.white, Colors.orange[300]!, Colors.orange[600]!], 'size': 21.0},
      // Flores adicionales para más diversidad
      {'x': 0.12, 'y': 0.65, 'colors': [Colors.white, Colors.indigo[300]!, Colors.indigo[600]!], 'size': 15.0},
      {'x': 0.88, 'y': 0.82, 'colors': [Colors.white, Colors.lime[300]!, Colors.lime[600]!], 'size': 17.0},
      {'x': 0.32, 'y': 0.75, 'colors': [Colors.white, Colors.teal[300]!, Colors.teal[600]!], 'size': 14.0},
      {'x': 0.68, 'y': 0.65, 'colors': [Colors.white, Colors.amber[300]!, Colors.amber[600]!], 'size': 20.0},
      {'x': 0.05, 'y': 0.85, 'colors': [Colors.white, Colors.deepPurple[300]!, Colors.deepPurple[600]!], 'size': 18.0},
      {'x': 0.95, 'y': 0.75, 'colors': [Colors.white, Colors.cyan[300]!, Colors.cyan[600]!], 'size': 16.0},
    ];

    for (int i = 0; i < flowerPositions.length; i++) {
      final flower = flowerPositions[i];
      flowers.add(
        AnimatedBuilder(
          animation: _animalsController,
          builder: (context, child) {
            final sway = math.sin(_animalsController.value * 2 * math.pi + i * 0.5) * 3;
            // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
            
            return Positioned(
              left: size.width * (flower['x'] as double) - (flower['size'] as double) / 2,
              bottom: size.height * (1 - (flower['y'] as double)) + sway,
              child: SizedBox(
                width: flower['size'] as double,
                height: (flower['size'] as double) * 1.5,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Tallo
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 3,
                        height: (flower['size'] as double) * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Flor
                    Positioned(
                      top: 0,
                      child: Container(
                        width: flower['size'] as double,
                        height: flower['size'] as double,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: flower['colors'] as List<Color>,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (flower['colors'] as List<Color>)[2].withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
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
    return flowers;
  }

  List<Widget> _buildDecorativeElements() {
    final decorativeElements = <Widget>[];

    // Mariposas volando
    final butterflyPositions = [
      {'x': 0.2, 'y': 0.4, 'color': Colors.orange, 'size': 25.0, 'offset': 0.0},
      {'x': 0.7, 'y': 0.3, 'color': Colors.purple, 'size': 22.0, 'offset': 0.5},
      {'x': 0.5, 'y': 0.5, 'color': Colors.blue, 'size': 20.0, 'offset': 1.0},
      {'x': 0.8, 'y': 0.45, 'color': Colors.pink, 'size': 18.0, 'offset': 0.3},
    ];

    for (int i = 0; i < butterflyPositions.length; i++) {
      final butterfly = butterflyPositions[i];
      decorativeElements.add(
        AnimatedBuilder(
          animation: _animalsController,
          builder: (context, child) {
            final flutter = math.sin((_animalsController.value + (butterfly['offset'] as double)) * 8 * math.pi) * 15;
            final bounce = math.cos((_animalsController.value + (butterfly['offset'] as double)) * 6 * math.pi) * 8;
            // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
            
            return Positioned(
              left: size.width * (butterfly['x'] as double) + flutter,
              bottom: size.height * (1 - (butterfly['y'] as double)) + bounce,
              child: Transform.rotate(
                angle: flutter * 0.1,
                child: Text(
                  '🦋',
                  style: TextStyle(
                    fontSize: butterfly['size'] as double,
                    color: butterfly['color'] as Color,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Rocas decorativas
    final rockPositions = [
      {'x': 0.1, 'y': 0.9, 'size': 12.0},
      {'x': 0.3, 'y': 0.85, 'size': 15.0},
      {'x': 0.65, 'y': 0.9, 'size': 10.0},
      {'x': 0.9, 'y': 0.88, 'size': 14.0},
      {'x': 0.45, 'y': 0.92, 'size': 8.0},
    ];

    for (final rock in rockPositions) {
      decorativeElements.add(
        Positioned(
          left: 400 * (rock['x'] as double), // Fixed width instead of MediaQuery
          bottom: 600 * (1 - (rock['y'] as double)), // Fixed height
          child: Container(
            width: rock['size'] as double,
            height: (rock['size'] as double) * 0.7,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFBDBDBD), // grey[400]
                  Color(0xFF757575), // grey[600] 
                  Color(0xFF424242), // grey[800]
                ],
              ),
              borderRadius: BorderRadius.circular((rock['size'] as double)
                  / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hongos pequeños
    final mushroomPositions = [
      {'x': 0.18, 'y': 0.8, 'emoji': '🍄'},
      {'x': 0.35, 'y': 0.83, 'emoji': '🍄'},
      {'x': 0.72, 'y': 0.8, 'emoji': '🍄'},
    ];

    for (final mushroom in mushroomPositions) {
      decorativeElements.add(
        Positioned(
          left: 400 * (mushroom['x'] as double),
          bottom: 600 * (1 - (mushroom['y'] as double)),
          child: AnimatedBuilder(
            animation: _animalsController,
            builder: (context, child) {
              final sway = math.sin(_animalsController.value * 1.5 * math.pi) * 2;
              return Transform.translate(
                offset: Offset(sway, 0),
                child: Text(
                  mushroom['emoji'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      );
    }

    // Hierba alta decorativa
    final tallGrassPositions = [
      {'x': 0.08, 'y': 0.75},
      {'x': 0.22, 'y': 0.78},
      {'x': 0.42, 'y': 0.72},
      {'x': 0.58, 'y': 0.77},
      {'x': 0.78, 'y': 0.74},
      {'x': 0.92, 'y': 0.76},
    ];

    for (int i = 0; i < tallGrassPositions.length; i++) {
      final grassPos = tallGrassPositions[i];
      decorativeElements.add(
        Positioned(
          left: 400 * (grassPos['x'] as double),
          bottom: 600 * (1 - (grassPos['y'] as double)),
          child: AnimatedBuilder(
            animation: _animalsController,
            builder: (context, child) {
              final sway = math.sin(_animalsController.value * 2 * math.pi + i * 0.3) * 4;
              return Transform.translate(
                offset: Offset(sway, 0),
                child: Text(
                  '🌾',
                  style: TextStyle(
                    fontSize: 20 + (i % 3) * 3,
                    color: Colors.green[700],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return decorativeElements;
  }

  List<Widget> _buildFarmAnimals() {
    final animals = <Widget>[];

    // Gallinas
    for (int i = 0; i < 3; i++) {
      animals.add(_buildChicken(i));
    }

    // Chanchos
    animals.add(_buildPig());

    // Caballos
    animals.add(_buildHorse());

    return animals;
  }

  Widget _buildChicken(int index) {
    return AnimatedBuilder(
      animation: _animalsController,
      builder: (context, child) {
        final progress = (_animalsController.value + index * 0.3) % 1.0;
        // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
        final x = 80 + (index * 60) + math.sin(progress * 4 * math.pi) * 20;
        final peck = math.sin(progress * 12 * math.pi) * 5;
        
        return Positioned(
          left: x,
          bottom: 60 + peck,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white, Colors.orange[100]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🐔', style: TextStyle(fontSize: 28)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPig() {
    return AnimatedBuilder(
      animation: _animalsController,
      builder: (context, child) {
        final progress = (_animalsController.value * 0.4) % 1.0;
        // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
        final x = progress * (size.width - 120) + 60;
        final snort = math.sin(progress * 10 * math.pi) * 3;
        
        return Positioned(
          left: x,
          bottom: 45 + snort,
          child: Transform.scale(
            scaleX: 1, // Siempre hacia adelante
            child: Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.pink[200]!, Colors.pink[400]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(2, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🐷', style: TextStyle(fontSize: 32)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorse() {
    return AnimatedBuilder(
      animation: _animalsController,
      builder: (context, child) {
        final progress = (_animalsController.value * 0.3) % 1.0;
        // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
        final x = size.width * 0.8 - progress * (size.width * 0.6);
        final gallop = math.sin(progress * 15 * math.pi) * 4;
        
        return Positioned(
          left: x,
          bottom: 35 + gallop,
          child: Transform.scale(
            scaleX: 1, // Caballo también hacia adelante
            child: Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown[300]!, Colors.brown[600]!],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🐴', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFlyingBirds() {
    final birds = <Widget>[];
    
    for (int i = 0; i < 4; i++) {
      birds.add(
        AnimatedBuilder(
          animation: _animalsController,
          builder: (context, child) {
            final progress = (_animalsController.value + i * 0.25) % 1.0;
            // ignore: unused_local_variable
        final size = MediaQuery.of(context).size;
            
            // Movimiento en forma de onda
            final x = progress * (size.width + 100) - 50;
            final y = 80 + i * 40 + math.sin(progress * math.pi * 4) * 30;
            final flap = math.sin(progress * math.pi * 20) * 0.2 + 1.0;
            
            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: flap,
                child: Container(
                  width: 25,
                  height: 15,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[200]!, Colors.blue[400]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐦', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return birds;
  }

  Widget _buildWindow() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[100]!, Colors.lightBlue[300]!],
        ),
        border: Border.all(color: Colors.brown[800]!, width: 4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Reflejos modernos en el cristal
          Positioned(
            top: 3,
            left: 3,
            child: Container(
              width: 12,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 3,
            child: Container(
              width: 8,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Pequeña decoración circular
          Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Cortinita decorativa (mantener)
          Positioned(
            top: 2,
            left: 2,
            right: 2,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[300]!, Colors.red[500]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChimney() {
    return AnimatedBuilder(
      animation: _animalsController,
      builder: (context, child) {
        final smokeOffset = _animalsController.value * 20;
        
        return Stack(
          children: [
            // Chimenea
            Container(
              width: 25,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red[600]!, Colors.red[800]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
            ),
            // Humo
            ...List.generate(4, (index) => Positioned(
              left: 8 + index * 2 + math.sin(smokeOffset + index) * 5,
              top: -10 - index * 8,
              child: Opacity(
                opacity: 0.6 - index * 0.15,
                child: Container(
                  width: 8 + index * 2.0,
                  height: 8 + index * 2.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildFlowerPot() {
    return SizedBox(
      width: 20,
      height: 25,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Maceta
          Positioned(
            bottom: 0,
            child: Container(
              width: 18,
              height: 15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown[400]!, Colors.brown[700]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Flor en la maceta
          Positioned(
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white, Colors.red[300]!, Colors.red[500]!],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Tallito
          Positioned(
            bottom: 8,
            child: Container(
              width: 2,
              height: 10,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Clases para CustomPainters
class EnhancedRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Techo inflable blanco brillante
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFFFFF), // Blanco brillante
        const Color(0xFFF5F5F5), // Blanco suave
        const Color(0xFFE8E8E8), // Blanco grisáceo
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path roof = Path();
    roof.moveTo(size.width * 0.1, size.height * 0.9);
    roof.lineTo(size.width * 0.5, size.height * 0.1); // Dejar espacio en la parte superior
    roof.lineTo(size.width * 0.9, size.height * 0.9);
    roof.close();
    canvas.drawPath(roof, paint);

    // Cara lateral del techo para efecto 3D
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFFD44415),
        const Color(0xFFB33A0F),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path sideRoof = Path();
    sideRoof.moveTo(size.width * 0.5, 0);
    sideRoof.lineTo(size.width * 0.9, size.height);
    sideRoof.lineTo(size.width * 0.95, size.height * 0.9);
    sideRoof.lineTo(size.width * 0.55, -5);
    sideRoof.close();
    canvas.drawPath(sideRoof, paint);

    // Tejas inflables redondeadas blancas
    paint.shader = null;
    paint.color = const Color(0xFFFFFFFF); // Blanco brillante
    
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 8; col++) {
        final x = size.width * 0.2 + col * (size.width * 0.6 / 8);
        final y = size.height * 0.9 - row * (size.height * 0.8 / 6);
        
        if (x < size.width * 0.5) {
          final tileY = y - ((size.width * 0.5 - x) / (size.width * 0.4)) * (size.height * 0.9);
          // Tejas más grandes y redondeadas como inflables
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, tileY), width: 12, height: 8),
              const Radius.circular(4),
            ),
            paint,
          );
        } else {
          final tileY = y - ((x - size.width * 0.5) / (size.width * 0.4)) * (size.height * 0.9);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, tileY), width: 12, height: 8),
              const Radius.circular(4),
            ),
            paint,
          );
        }
      }
    }

    // Borde del techo
    paint.color = const Color(0xFF8B2500);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawPath(roof, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DetailedGrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Pasto base
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF4CAF50),
        const Color(0xFF2E7D32),
        const Color(0xFF1B5E20),
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      paint,
    );

    // Briznas de pasto individuales
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;

    for (int i = 0; i < 200; i++) {
      final x = (i * 7.3) % size.width;
      final baseY = size.height * 0.6 + (i % 50) * 2;
      final height = 15 + (i % 8) * 3;
      
      paint.color = Color.lerp(
        const Color(0xFF4CAF50),
        const Color(0xFF2E7D32),
        (i % 10) / 10.0,
      )!;

      Path grassBlade = Path();
      grassBlade.moveTo(x, baseY + height);
      grassBlade.quadraticBezierTo(
        x + 2 + (i % 3),
        baseY + height * 0.7,
        x + 1 + (i % 2),
        baseY,
      );
      
      canvas.drawPath(grassBlade, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Colinas de fondo
    paint.color = const Color(0xFF32CD32).withValues(alpha: 0.3);
    Path hill1 = Path();
    hill1.moveTo(0, size.height * 0.4);
    hill1.quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.6, size.height * 0.4);
    hill1.quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.3);
    hill1.lineTo(size.width, size.height);
    hill1.lineTo(0, size.height);
    hill1.close();
    canvas.drawPath(hill1, paint);

    // Segunda colina
    paint.color = const Color(0xFF228B22).withValues(alpha: 0.2);
    Path hill2 = Path();
    hill2.moveTo(0, size.height * 0.5);
    hill2.quadraticBezierTo(size.width * 0.4, size.height * 0.3, size.width * 0.8, size.height * 0.5);
    hill2.lineTo(size.width, size.height * 0.5);
    hill2.lineTo(size.width, size.height);
    hill2.lineTo(0, size.height);
    hill2.close();
    canvas.drawPath(hill2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDEB887) // Beige/marrón claro
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3, size.width * 0.7, 0);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExtraGroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Tierra base más rica
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF8D6E63), // Marrón tierra
        const Color(0xFF6D4C41), // Marrón más oscuro
        const Color(0xFF5D4037), // Marrón profundo
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      paint,
    );

    // Parches de tierra con diferentes tonos
    paint.shader = null;
    paint.style = PaintingStyle.fill;
    
    // Varios parches de tierra
    final patches = [
      {'x': 0.1, 'y': 0.75, 'width': 0.15, 'height': 0.1, 'color': const Color(0xFF795548)},
      {'x': 0.3, 'y': 0.8, 'width': 0.2, 'height': 0.08, 'color': const Color(0xFF8D6E63)},
      {'x': 0.6, 'y': 0.77, 'width': 0.18, 'height': 0.12, 'color': const Color(0xFF6D4C41)},
      {'x': 0.8, 'y': 0.82, 'width': 0.15, 'height': 0.09, 'color': const Color(0xFF795548)},
    ];

    for (final patch in patches) {
      paint.color = patch['color'] as Color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (patch['x'] as double),
            size.height * (patch['y'] as double),
            size.width * (patch['width'] as double),
            size.height * (patch['height'] as double),
          ),
          const Radius.circular(8),
        ),
        paint,
      );
    }

    // Pequeñas piedras en la tierra
    paint.color = const Color(0xFF9E9E9E);
    for (int i = 0; i < 20; i++) {
      final x = size.width * (0.05 + (i * 0.043) % 0.9);
      final y = size.height * (0.75 + (i % 3) * 0.08);
      canvas.drawCircle(Offset(x, y), 2 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

