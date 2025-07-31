import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
// import 'letter_details_screen.dart'; // No se usa actualmente
import 'interactive_letter_games_screen.dart';
import '../widgets/progress_header.dart';
import '../widgets/reference_style_house.dart';
import '../widgets/rolling_hills_terrain.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late AnimationController _animatedElementsController;
  late Animation<double> _gridAnimation;
  final AudioService _audioService = AudioService();
  
  // Lista para almacenar posiciones ocupadas (detección de colisiones)
  final List<Map<String, double>> _occupiedPositions = [];

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animatedElementsController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeOutBack,
    );

    _gridAnimationController.forward();
    _animatedElementsController.repeat();
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioService.speakText('¡Hola pequeño explorador! Soy Luna, tu guía en este parque mágico de letras. ¿Estás listo para descubrir todas las aventuras que tengo preparadas?');
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _animatedElementsController.dispose();
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
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFB0E2FF),
              Color(0xFF98FB98),
              Color(0xFF90EE90),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: CustomPaint(
                painter: _ParkBackgroundPainter(),
                size: Size.infinite,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const ProgressHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      // CONFIGURACIÓN OPTIMIZADA PARA ANDROID
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(), // Scroll suave tipo iOS
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          _buildLetterGrid(),
                          // ESPACIO EXTRA PARA SCROLL COMPLETO EN TELÉFONOS
                          const SizedBox(height: 100),
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

  Widget _buildWelcomeCard() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Icon(Icons.park, size: 30, color: Color(0xFF10B981)),
                const SizedBox(height: 6),
                Text(
                  provider.playerName.isNotEmpty
                      ? '¡Hola, ${provider.playerName}!'
                      : '¡Bienvenido al Parque!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.totalStars} estrellas',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAvatarMode(),
                icon: const Icon(Icons.person),
                label: const Text('Modo Jugador'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSettingsDialog(),
                icon: const Icon(Icons.settings),
                label: const Text('Configurar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7280),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLetterGrid() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        final sortedLetters = List.from(provider.letters)
          ..sort((a, b) => a.character.compareTo(b.character));

        return AnimatedBuilder(
          animation: _gridAnimation,
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            // ALTURA DINÁMICA PARA SCROLL EN ANDROID
            final screenHeight = MediaQuery.of(context).size.height;
            final isPhone = screenHeight < 800; // Detectar teléfonos
            final contentHeight = isPhone ? 1400.0 : 1000.0; // Más altura en teléfonos para scroll
            
            return SizedBox(
              height: contentHeight,
              child: Stack(
                children: [
                  // Paisaje ondulado con montañas y valles
                  Positioned.fill(
                    child: RollingHillsTerrain(
                      terrainSize: Size(size.width, 700),
                    ),
                  ),
                  
                  // Sol animado
                  _buildAnimatedSun(),
                  
                  // Globos flotantes
                  ..._buildFloatingBalloons(),
                  
                  // Efectos de videojuego: partículas brillantes
                  ..._buildSparkleEffects(),
                  
                  // Mariposas animadas
                  ..._buildAnimatedButterflies(),

                  // Avatar del jugador en el sendero
                  Positioned(
                    left: size.width * 0.15,
                    top: 500,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF42A5F5),
                            Color(0xFF1976D2),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(2, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Casas coloridas distribuidas naturalmente por el terreno
                  ...sortedLetters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final letter = entry.value;
                    // final delay = index * 0.08; // No se usa - reemplazado por alphabetDelay
                    final position = _calculateOptimalPosition(index, sortedLetters.length, size);
                    final elevation = position['elevation']!;
                    final row = position['row']!.toInt();
                    // final col = position['col']!.toInt(); // No se usa en este contexto
                    
                    // EFECTOS VISUALES MEJORADOS PARA CASAS GRANDES
                    final depthScale = 1.0 - (row * 0.02); // Efecto profundidad más sutil
                    final depthOpacity = 1.0 - (row * 0.015); // Transparencia muy sutil
                    
                    // ANIMACIÓN EN CASCADA ALFABÉTICA MEJORADA
                    final alphabetDelay = index * 60; // Delay más rápido y fluido

                    return Positioned(
                      left: position['x'],
                      top: position['y'],
                      child: Transform.scale(
                        scale: _gridAnimation.value * depthScale.clamp(0.92, 1.0), // Escala más consistente
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500 + alphabetDelay),
                          opacity: (_gridAnimation.value * depthOpacity).clamp(0.0, 1.0), // Opacidad segura
                          child: Container(
                            // SOMBRAS MEJORADAS PARA CASAS GRANDES
                            decoration: BoxDecoration(
                              boxShadow: [
                                // Sombra principal más prominente
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12 + (elevation * 6), // Sombras más suaves y grandes
                                  offset: Offset(
                                    4 + (elevation * 3), // Sombra hacia la derecha
                                    6 + (elevation * 4), // Sombra hacia abajo
                                  ),
                                ),
                                // Sombra secundaria para más profundidad
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20 + (elevation * 8),
                                  offset: Offset(
                                    6 + (elevation * 4),
                                    8 + (elevation * 5),
                                  ),
                                ),
                              ],
                            ),
                            child: ReferenceStyleHouse(
                              letter: letter.character,
                              size: position['size']!,
                              onTap: () => _onLetterTap(letter.character),
                              isUnlocked: letter.isUnlocked,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, double> _calculateOptimalPosition(int index, int totalLetters, Size size) {
    // Limpiar posiciones si es el primer elemento
    if (index == 0) {
      _occupiedPositions.clear();
    }
    
    // === CONFIGURACIÓN RESPONSIVA ===
    final screenWidth = size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    // CASAS GRANDES Y RESPONSIVAS
    double houseSize;
    if (isSmallScreen) {
      houseSize = 85.0;
    } else if (isMediumScreen) {
      houseSize = 95.0;
    } else {
      houseSize = 105.0;
    }
    
    final parkWidth = screenWidth - 40;
    final parkHeight = 1200.0; // Mayor altura para acomodar scroll
    
    // === DISEÑO TIPO COLINA NATURAL ===
    // Crear un sendero alfabético serpenteante a través de colinas
    
    // Progreso a lo largo del sendero alfabético (0.0 a 1.0)
    final progress = index / (totalLetters - 1);
    
    // SENDERO SERPENTEANTE: zigzag natural a través del paisaje
    final pathCenterX = parkWidth * 0.5; // Centro del sendero
    final pathAmplitude = parkWidth * 0.35; // Qué tan ancho es el zigzag
    
    // Crear ondas múltiples para sendero natural
    final wave1 = math.sin(progress * math.pi * 4) * pathAmplitude * 0.6;
    final wave2 = math.cos(progress * math.pi * 2.5) * pathAmplitude * 0.3;
    final wave3 = math.sin(progress * math.pi * 6) * pathAmplitude * 0.1;
    
    final baseX = pathCenterX + wave1 + wave2 + wave3;
    
    // DISTRIBUCIÓN VERTICAL TIPO COLINA
    // Las casas suben y bajan como en colinas
    final hillWave1 = math.sin(progress * math.pi * 3) * 80;
    final hillWave2 = math.cos(progress * math.pi * 2) * 50;
    final hillWave3 = math.sin(progress * math.pi * 5) * 30;
    
    final baseY = 150 + (progress * (parkHeight - 300)) + hillWave1 + hillWave2 + hillWave3;
    
    // SEPARACIÓN NATURAL - Evitar superposiciones
    final minDistance = houseSize + 70.0; // Distancia mínima entre casas
    
    // Buscar posición libre con algoritmo de separación natural
    double finalX = baseX;
    double finalY = baseY;
    int attempts = 0;
    const maxAttempts = 50;
    
    while (attempts < maxAttempts && !_isPositionFree(finalX, finalY, houseSize)) {
      // Mover en espiral desde la posición base
      final angle = (attempts * 0.5) * math.pi;
      final radius = (attempts * 8.0) + 20;
      
      finalX = baseX + math.cos(angle) * radius;
      finalY = baseY + math.sin(angle) * radius;
      
      // Mantener dentro de los límites
      finalX = finalX.clamp(houseSize / 2, parkWidth - houseSize / 2);
      finalY = finalY.clamp(120.0, parkHeight - houseSize);
      
      attempts++;
    }
    
    // Registrar posición ocupada
    _occupiedPositions.add({
      'x': finalX,
      'y': finalY,
      'size': houseSize,
    });
    
    // Calcular elevación para efectos visuales
    final elevation = (parkHeight - finalY) / parkHeight;
    
    return {
      'x': finalX,
      'y': finalY,
      'size': houseSize,
      'row': (finalY / 120).floor().toDouble(), // Fila aproximada para efectos
      'col': (finalX / 120).floor().toDouble(), // Columna aproximada
      'elevation': elevation,
      'progress': progress, // Progreso alfabético para debugging
    };
  }
  
  bool _isPositionFree(double x, double y, double size) {
    // VERIFICACIÓN DE COLISIONES PARA DISEÑO NATURAL DE COLINAS
    
    const padding = 75.0; // Padding generoso para separación natural
    
    for (final occupied in _occupiedPositions) {
      final occupiedX = occupied['x']!;
      final occupiedY = occupied['y']!;
      final occupiedSize = occupied['size']!;
      
      // Verificación de distancia euclidiana
      final distance = math.sqrt(
        math.pow(x - occupiedX, 2) + math.pow(y - occupiedY, 2)
      );
      final minDistance = (size + occupiedSize) / 2 + padding;
      
      if (distance < minDistance) {
        return false; // Muy cerca
      }
      
      // Verificación adicional rectangular para mayor seguridad
      final rect1 = Rect.fromCenter(
        center: Offset(x, y), 
        width: size + padding, 
        height: size + padding
      );
      final rect2 = Rect.fromCenter(
        center: Offset(occupiedX, occupiedY), 
        width: occupiedSize + padding, 
        height: occupiedSize + padding
      );
      
      if (rect1.overlaps(rect2)) {
        return false; // Superposición rectangular
      }
    }
    return true; // Posición completamente libre
  }

  Widget _buildAnimatedSun() {
    return AnimatedBuilder(
      animation: _animatedElementsController,
      builder: (context, child) {
        final bounce = math.sin(_animatedElementsController.value * 2 * math.pi) * 5;
        return Positioned(
          top: 30 + bounce,
          right: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.yellow[300]!, Colors.orange[400]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                ...List.generate(8, (index) {
                  final angle = (index / 8) * 2 * math.pi;
                  final rayLength = 15.0;
                  return Positioned(
                    left: 40 + (rayLength + 25) * math.cos(angle) - 1,
                    top: 40 + (rayLength + 25) * math.sin(angle) - 8,
                    child: Transform.rotate(
                      angle: angle + math.pi / 2,
                      child: Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.yellow[600],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 25,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 3,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
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
      },
    );
  }

  List<Widget> _buildFloatingBalloons() {
    final balloons = <Widget>[];
    final balloonColors = [
      Colors.red[300]!, Colors.blue[300]!, Colors.green[300]!,
      Colors.yellow[300]!, Colors.purple[300]!, Colors.pink[300]!,
    ];

    for (int i = 0; i < 6; i++) {
      balloons.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final float = math.sin((_animatedElementsController.value + i * 0.3) * 2 * math.pi) * 15;
            final sway = math.cos((_animatedElementsController.value + i * 0.2) * 2 * math.pi) * 10;

            return Positioned(
              left: 60 + (i * 50) + sway,
              top: 80 + (i % 3) * 40 + float,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        colors: [
                          Colors.white.withOpacity(0.8),
                          balloonColors[i],
                          balloonColors[i].withOpacity(0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: balloonColors[i].withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return balloons;
  }

  List<Widget> _buildSparkleEffects() {
    final sparkles = <Widget>[];
    
    // Partículas brillantes dispersas por el paisaje
    for (int i = 0; i < 15; i++) {
      sparkles.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final sparkleTime = (_animatedElementsController.value + i * 0.2) % 1.0;
            final opacity = math.sin(sparkleTime * math.pi * 2) * 0.5 + 0.5;
            final scale = 0.5 + math.sin(sparkleTime * math.pi * 3) * 0.3;
            
            return Positioned(
              left: 50 + (i * 25) + math.sin(sparkleTime * math.pi * 4) * 10,
              top: 200 + (i % 4) * 80 + math.cos(sparkleTime * math.pi * 3) * 15,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.yellow[200]!,
                          Colors.orange[300]!,
                          Colors.pink[200]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return sparkles;
  }

  List<Widget> _buildAnimatedButterflies() {
    final butterflies = <Widget>[];
    
    for (int i = 0; i < 4; i++) {
      butterflies.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final progress = (_animatedElementsController.value + i * 0.25) % 1.0;
            final size = MediaQuery.of(context).size;
            
            // Movimiento en figura de 8
            final x = size.width * 0.2 + 
                     math.sin(progress * math.pi * 2) * 100 +
                     i * size.width * 0.2;
            final y = 300 + 
                     math.sin(progress * math.pi * 4) * 60 +
                     math.cos(progress * math.pi * 2) * 40;
            
            final flutter = math.sin(progress * math.pi * 20) * 0.1 + 1.0;
            
            return Positioned(
              left: x,
              top: y,
              child: Transform.scale(
                scale: flutter,
                child: Container(
                  width: 20,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[300]!,
                        Colors.pink[200]!,
                        Colors.orange[200]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🦋',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return butterflies;
  }



  Widget _buildWalkingCat(double offset, double baseY, Color color, String emoji) {
    return AnimatedBuilder(
      animation: _animatedElementsController,
      builder: (context, child) {
        final progress = (_animatedElementsController.value + offset) % 1.0;
        final x = progress * (MediaQuery.of(context).size.width - 60);
        final bounce = math.sin(progress * 20) * 2;

        return Positioned(
          left: x,
          top: baseY + bounce,
          child: Transform.scale(
            scaleX: progress > 0.5 ? -1 : 1,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalkingDog(double offset, double baseY, Color color, String emoji) {
    return AnimatedBuilder(
      animation: _animatedElementsController,
      builder: (context, child) {
        final progress = (_animatedElementsController.value + offset) % 1.0;
        final x = progress * (MediaQuery.of(context).size.width - 60);
        final bounce = math.sin(progress * 25) * 3;

        return Positioned(
          left: x,
          top: baseY + bounce,
          child: Transform.scale(
            scaleX: progress > 0.5 ? -1 : 1,
            child: Container(
              width: 45,
              height: 35,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onLetterTap(String character) async {
    final provider = context.read<LetterCityProvider>();
    final letter = provider.getLetterByCharacter(character);

    if (letter == null) return;

    await _audioService.playClickSound();

    if (!letter.isUnlocked) {
      await _audioService.speakText('Esta letra aún no está disponible');
      return;
    }

    provider.selectLetter(character);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractiveLetterGamesScreen(letter: letter),
        ),
      );
    }
  }

  void _navigateToAvatarMode() {
    _showAvatarModeDialog();
  }

  void _showAvatarModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue[600], size: 28),
            const SizedBox(width: 8),
            const Text('Modo Jugador'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color(0xFF1976D2),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.child_care,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Hola ${context.read<LetterCityProvider>().playerName.isNotEmpty ? context.read<LetterCityProvider>().playerName : 'pequeño explorador'}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Soy Luna, tu guía en este parque mágico de letras. ¿Estás listo para una nueva aventura de aprendizaje?',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Estrellas: ${context.read<LetterCityProvider>().totalStars}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Nivel: Explorador Principiante',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _audioService.speakText('¡Genial! Vamos a explorar juntos las casitas de las letras. ¡Toca cualquier casa que te llame la atención!');
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('¡Vamos a Jugar!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Cambiar nombre'),
              onTap: () => _showNameDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Configurar audio'),
              onTap: () => _showAudioSettings(),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reiniciar progreso'),
              onTap: () => _showResetDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Modo Demo Activo'),
              subtitle: const Text('Todas las letras están desbloqueadas'),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showNameDialog() {
    final controller = TextEditingController();
    final provider = context.read<LetterCityProvider>();
    controller.text = provider.playerName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cuál es tu nombre?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe tu nombre aquí',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setPlayerName(controller.text.trim());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAudioSettings() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Audio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Volumen: ${(_audioService.volume * 100).round()}%'),
            Slider(
              value: _audioService.volume,
              onChanged: (value) => _audioService.setVolume(value),
            ),
            Text('Velocidad: ${(_audioService.speechRate * 100).round()}%'),
            Slider(
              value: _audioService.speechRate,
              onChanged: (value) => _audioService.setSpeechRate(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Reiniciar Progreso?'),
        content: const Text(
          'Se perderá todo tu progreso actual. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LetterCityProvider>().resetProgress();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}

class _ParkBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = const Color(0xFF228B22);
    final grassPath = Path();
    grassPath.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 20) {
      grassPath.quadraticBezierTo(
          x + 10,
          size.height * 0.65 + (x % 40 == 0 ? 5 : -5),
          x + 20,
          size.height * 0.7
      );
    }
    grassPath.lineTo(size.width, size.height);
    grassPath.lineTo(0, size.height);
    grassPath.close();
    canvas.drawPath(grassPath, paint);

    paint.color = const Color(0xFFDEB887);
    paint.strokeWidth = 15;
    paint.style = PaintingStyle.stroke;
    final pathPaint = Paint()
      ..color = const Color(0xFFCD853F)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final pathPath = Path();
    pathPath.moveTo(0, size.height * 0.8);
    pathPath.quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.6,
        size.height * 0.75
    );
    pathPath.quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.85,
        size.width,
        size.height * 0.7
    );
    canvas.drawPath(pathPath, pathPaint);
    canvas.drawPath(pathPath, paint);

    paint.style = PaintingStyle.fill;

    paint.color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.4, 8, 30),
        const Radius.circular(4),
      ),
      paint,
    );
    paint.color = const Color(0xFF228B22);
    canvas.drawCircle(
      Offset(size.width * 0.19, size.height * 0.35),
      20,
      paint,
    );

    paint.color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.8, size.height * 0.3, 8, 35),
        const Radius.circular(4),
      ),
      paint,
    );
    paint.color = const Color(0xFF32CD32);
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.25),
      25,
      paint,
    );

    paint.color = const Color(0xFFFFB6C1);
    for (int i = 0; i < 8; i++) {
      final x = (size.width * 0.2) + (i * size.width * 0.1);
      final y = size.height * 0.75 + (i % 2 == 0 ? 5 : -5);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }

    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(size.width * 0.2, 50), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.25, 45), 18, paint);
    canvas.drawCircle(Offset(size.width * 0.3, 50), 15, paint);

    canvas.drawCircle(Offset(size.width * 0.7, 40), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.75, 35), 22, paint);
    canvas.drawCircle(Offset(size.width * 0.8, 40), 18, paint);

    paint.color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.6, 40, 8),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.42, size.height * 0.68, 4, 12),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.46, size.height * 0.68, 4, 12),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
