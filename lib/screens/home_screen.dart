import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
// import 'letter_details_screen.dart'; // No se usa actualmente
import 'interactive_letter_games_screen.dart';
import 'letter_park_3d_screen.dart';
// import 'first_person_park_screen.dart'; // Removido
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
    // DETENER VOZ AL SALIR DE LA PÁGINA PRINCIPAL
    _audioService.stop();
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
                      // SCROLL VERTICAL PRINCIPAL
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          // GRID DE LETRAS SIN SCROLL HORIZONTAL
                          _buildLetterGrid(),
                          // ESPACIO EXTRA PARA SCROLL COMPLETO
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
        return Column(
          children: [
            Row(
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateTo3DPark(),
                    icon: const Icon(Icons.threesixty),
                    label: const Text('Parque 3D'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLetterGrid() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        // USAR ORDEN ALFABÉTICO ESPAÑOL CORRECTO (tal como está definido en letters_data.dart)
        // Ordenar las letras según el alfabeto español correcto (A-Z, con Ñ entre N y O)
        const spanishAlphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
        final sortedLetters = List.from(provider.letters)
          ..sort((a, b) {
            final indexA = spanishAlphabet.indexOf(a.character.toUpperCase());
            final indexB = spanishAlphabet.indexOf(b.character.toUpperCase());
            return indexA.compareTo(indexB);
          });

        return AnimatedBuilder(
          animation: _gridAnimation,
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            // ALTURA DINÁMICA PARA SCROLL EN ANDROID
            final screenHeight = MediaQuery.of(context).size.height;
            final isPhone = screenHeight < 800; // Detectar teléfonos
            // ALTURA SIMPLE Y DIRECTA
            final lettersPerRow = size.width < 500 ? 5 : 6;
            final totalRows = (27 / lettersPerRow).ceil(); // 27 letras total incluyendo Ñ
            final rowHeight = 180.0; 
            final baseHeight = 150.0; // Espacio superior
            final extraSpace = 300.0; // Espacio extra para scroll
            final contentHeight = baseHeight + (totalRows * rowHeight) + extraSpace;
            
            return SizedBox(
              width: size.width, // Solo el ancho visible de la pantalla
              height: contentHeight,
              child: Stack(
                children: [
                  // COLINAS Y LOMAS DEL PARQUE
                  ..._buildParkHills(size),
                  
                  // Paisaje de parque real con senderos y áreas verdes
                  Positioned.fill(
                    child: RollingHillsTerrain(
                      terrainSize: Size(size.width, 800),
                    ),
                  ),
                  
                  // Senderos curvos del parque
                  ..._buildParkPaths(size),
                  
                  // Carrusel central divertido
                  _buildCentralPlayground(size),
                  
                  // Árboles decorativos
                  ..._buildParkTrees(size),
                  
                  // Sol animado
                  _buildAnimatedSun(),
                  
                  // Globos flotantes
                  ..._buildFloatingBalloons(),
                  
                  // Efectos de videojuego: partículas brillantes
                  ..._buildSparkleEffects(),
                  
                  // Mariposas animadas
                  ..._buildAnimatedButterflies(),

                  // Avatar del jugador caminando por el sendero del parque
                  AnimatedBuilder(
                    animation: _animatedElementsController,
                    builder: (context, child) {
                      final walkBounce = math.sin(_animatedElementsController.value * 6 * math.pi) * 3;
                      return Positioned(
                        left: size.width * 0.2,
                        top: 200 + walkBounce,
                        child: Container(
                          width: 50,
                          height: 50,
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
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(2, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.child_care,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Casas coloridas distribuidas naturalmente por el terreno
                  ...sortedLetters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final letter = entry.value;
                    final position = _calculateOptimalPosition(index, sortedLetters.length, size);
                    final elevation = position['elevation'] ?? 0.0;
                    final zone = position['zone'] ?? 0;
                    
                    // EFECTOS VISUALES MEJORADOS PARA CASAS GRANDES
                    final depthScale = 1.0 - (zone * 0.02); // Efecto profundidad basado en zona
                    final depthOpacity = 1.0 - (zone * 0.015); // Transparencia basada en zona
                    
                    // ANIMACIÓN EN CASCADA ALFABÉTICA MEJORADA
                    final alphabetDelay = index * 60; // Delay más rápido y fluido

                    return Positioned(
                      left: position['x'] ?? 0.0,
                      top: position['y'] ?? 0.0,
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
                              size: position['size'] ?? 75.0,
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
    
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isMobile = screenWidth < 600;
    
    if (isMobile) {
      // === MÓVIL: ALINEADO Y ORDENADO ===
      return _calculateMobilePosition(index, totalLetters, size);
    } else {
      // === WEB: DISPERSO PERO ORDENADO ===
      return _calculateWebPosition(index, totalLetters, size);
    }
  }
  
  // POSICIONAMIENTO MÓVIL: ORGÁNICO PERO CON ORDEN ALFABÉTICO VISUAL
  Map<String, double> _calculateMobilePosition(int index, int totalLetters, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    final houseSize = 55.0;
    
    // USAR TODA LA PÁGINA MÓVIL
    final headerSpace = 120.0;
    final bottomSpace = 80.0;
    final sideSpace = 20.0;
    final availableHeight = screenHeight - headerSpace - bottomSpace;
    final availableWidth = screenWidth - (sideSpace * 2);
    
    // FLUJO ALFABÉTICO MÓVIL: 3 CASAS POR FILA PERO ORGÁNICO
    final housesPerRow = 3; // Ideal para móvil
    final totalRows = (totalLetters / housesPerRow).ceil();
    final row = (index / housesPerRow).floor();
    final col = index % housesPerRow;
    
    // ZONA ALFABÉTICA BASE EN MÓVIL (flujo de lectura)
    final baseX = sideSpace + (col * (availableWidth / housesPerRow));
    final baseY = headerSpace + (row * (availableHeight / totalRows));
    
    // VARIACIONES ORGÁNICAS DENTRO DE CADA ZONA ALFABÉTICA MÓVIL
    final letterSeed = index * 89 + 23; // Diferentes semillas para móvil
    
    // Tamaño de zona alfabética más pequeño en móvil
    final zoneWidth = availableWidth / housesPerRow;
    final zoneHeight = availableHeight / totalRows;
    
    // Variaciones orgánicas dentro de cada zona (más pequeñas para móvil)
    final organicX = ((letterSeed * 67 + index * 37) % 1000) / 1000 * (zoneWidth * 0.6);
    final organicY = ((letterSeed * 79 + index * 59) % 1000) / 1000 * (zoneHeight * 0.6);
    
    // Variaciones adicionales para efecto natural (adaptadas a móvil)
    final majorVariationX = ((index * 131 + 41) % 40) - 20; // ±20px
    final majorVariationY = ((index * 173 + 61) % 30) - 15; // ±15px
    final microVariationX = ((index * 199 + 83) % 20) - 10; // ±10px
    final microVariationY = ((index * 227 + 101) % 16) - 8; // ±8px
    
    // POSICIÓN FINAL: ORGÁNICA PERO CON FLUJO ALFABÉTICO MÓVIL
    final naturalX = baseX + organicX + majorVariationX + microVariationX;
    final naturalY = baseY + organicY + majorVariationY + microVariationY;
    
    // ASEGURAR QUE ESTÉN DENTRO DE LA PANTALLA
    final finalX = naturalX.clamp(sideSpace, screenWidth - houseSize - sideSpace);
    final finalY = naturalY.clamp(headerSpace, screenHeight - houseSize - bottomSpace);
    
    // EVITAR COLISIONES MANTENIENDO ORDEN ALFABÉTICO
    final position = _avoidCollisions(finalX, finalY, houseSize, index);
    
    // PROPIEDADES VISUALES ORGÁNICAS PARA MÓVIL
    final radiusGenerator = (letterSeed * 47 + index * 19) % 10000;
    final elevation = 0.4 + (radiusGenerator / 10000) * 0.6;
    final walkSpeed = 0.6 + ((index * 113) % 100) / 300.0;
    
    return {
      'x': position['x']!,
      'y': position['y']!,
      'size': houseSize + ((index * 71) % 10) - 5, // Variaciones más pequeñas en móvil
      'walkProgress': walkSpeed,
      'elevation': elevation,
      'zone': row.toDouble(), // Zona basada en fila alfabética
      'progress': index / (totalLetters - 1),
    };
  }
  
  // POSICIONAMIENTO WEB: ORGÁNICO PERO CON ORDEN ALFABÉTICO VISUAL
  Map<String, double> _calculateWebPosition(int index, int totalLetters, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    final houseSize = 70.0; // Casas más grandes para web
    
    // USAR TODA LA PÁGINA COMPLETA
    final headerSpace = 140.0;
    final bottomSpace = 100.0;
    final sideSpace = 60.0;
    final availableHeight = screenHeight - headerSpace - bottomSpace;
    final availableWidth = screenWidth - (sideSpace * 2);
    
    // FLUJO ALFABÉTICO ORGÁNICO: SEGUIR PATRÓN DE LECTURA PERO SIN RIGIDEZ
    // Dividir en "franjas" horizontales flexibles que sigan el orden alfabético
    final housesPerRow = screenWidth > 1200 ? 6 : (screenWidth > 900 ? 5 : 4);
    final totalRows = (totalLetters / housesPerRow).ceil();
    final row = (index / housesPerRow).floor();
    final col = index % housesPerRow;
    
    // ZONA ALFABÉTICA BASE (flujo de lectura natural)
    final baseX = sideSpace + (col * (availableWidth / housesPerRow));
    final baseY = headerSpace + (row * (availableHeight / totalRows));
    
    // VARIACIONES ORGÁNICAS GRANDES DENTRO DE CADA ZONA ALFABÉTICA
    // Cada casa se mueve naturalmente dentro de su "zona alfabética"
    final letterSeed = index * 97 + 31;
    
    // Variaciones dentro de la zona para mantener orden pero ser orgánico
    final zoneWidth = availableWidth / housesPerRow;
    final zoneHeight = availableHeight / totalRows;
    
    // Variaciones orgánicas dentro de cada zona alfabética
    final organicX = ((letterSeed * 73 + index * 41) % 1000) / 1000 * (zoneWidth * 0.8);
    final organicY = ((letterSeed * 89 + index * 67) % 1000) / 1000 * (zoneHeight * 0.8);
    
    // Variaciones adicionales para efecto natural
    final majorVariationX = ((index * 137 + 43) % 80) - 40; // ±40px
    final majorVariationY = ((index * 181 + 71) % 60) - 30; // ±30px
    final microVariationX = ((index * 211 + 91) % 30) - 15; // ±15px
    final microVariationY = ((index * 241 + 113) % 20) - 10; // ±10px
    
    // POSICIÓN FINAL: ORGÁNICA PERO MANTENIENDO FLUJO ALFABÉTICO
    final naturalX = baseX + organicX + majorVariationX + microVariationX;
    final naturalY = baseY + organicY + majorVariationY + microVariationY;
    
    // ASEGURAR QUE ESTÉN DENTRO DE LA PANTALLA
    final finalX = naturalX.clamp(sideSpace, screenWidth - houseSize - sideSpace);
    final finalY = naturalY.clamp(headerSpace, screenHeight - houseSize - bottomSpace);
    
    // EVITAR COLISIONES MANTENIENDO ORDEN ALFABÉTICO
    final position = _avoidCollisions(finalX, finalY, houseSize, index);
    
    // PROPIEDADES VISUALES ORGÁNICAS
    final radiusGenerator = (letterSeed * 53 + index * 23) % 10000;
    final elevation = 0.3 + (radiusGenerator / 10000) * 0.7;
    final walkSpeed = 0.5 + ((index * 127) % 100) / 200.0;
    
    return {
      'x': position['x']!,
      'y': position['y']!,
      'size': houseSize + ((index * 83) % 20) - 10, // Tamaños ligeramente diferentes
      'walkProgress': walkSpeed,
      'elevation': elevation,
      'zone': row.toDouble(), // Zona basada en fila alfabética
      'progress': index / (totalLetters - 1),
    };
  }
  
  // EVITAR COLISIONES SIMPLES PARA DISTRIBUCIÓN ORGÁNICA
  Map<String, double> _avoidCollisions(double x, double y, double size, int index) {
    double finalX = x;
    double finalY = y;
    final minDistance = size + 20; // Distancia mínima entre casas
    
    // Revisar colisiones con casas ya posicionadas
    for (final occupied in _occupiedPositions) {
      final dx = finalX - occupied['x']!;
      final dy = finalY - occupied['y']!;
      final distance = math.sqrt(dx * dx + dy * dy);
      
      if (distance < minDistance) {
        // Mover ligeramente para evitar colisión
        final angle = math.atan2(dy, dx);
        finalX = occupied['x']! + math.cos(angle) * minDistance;
        finalY = occupied['y']! + math.sin(angle) * minDistance;
      }
    }
    
    // Registrar nueva posición
    _occupiedPositions.add({'x': finalX, 'y': finalY, 'size': size});
    
    return {'x': finalX, 'y': finalY};
  }
  
  // VERIFICAR COLISIONES SOLO EN WEB
  Map<String, double> _ensureNoCollisionWeb(double x, double y, double size, int index) {
    double adjustedX = x;
    double adjustedY = y;
    final minDistance = size * 1.4;
    
    // Verificar contra posiciones ya ocupadas
    for (final occupied in _occupiedPositions) {
      final distance = math.sqrt(
        math.pow(adjustedX - occupied['x']!, 2) + 
        math.pow(adjustedY - occupied['y']!, 2)
      );
      
      if (distance < minDistance) {
        // Mover ligeramente manteniendo el orden alfabético
        adjustedX += (index % 2 == 0) ? 40 : -40;
        adjustedY += (index % 3 == 0) ? 30 : -30;
        
        // RE-APLICAR LÍMITES DESPUÉS DEL AJUSTE
        final screenWidth = 1200.0; // Estimado para web
        final screenHeight = 800.0; // Estimado para web  
        adjustedX = adjustedX.clamp(size * 0.5, screenWidth - size * 1.5);
        adjustedY = adjustedY.clamp(200.0, screenHeight - size - 150.0);
        
        break; // Solo un ajuste para mantener orden
      }
    }
    
    // Registrar posición ocupada
    _occupiedPositions.add({'x': adjustedX, 'y': adjustedY, 'size': minDistance});
    
    return {'x': adjustedX, 'y': adjustedY};
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

  // Método removido: _navigateToFirstPersonPark

  void _navigateToAvatarMode() {
    _showAvatarModeDialog();
  }

  void _navigateTo3DPark() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LetterPark3DScreen(),
      ),
    );
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

  // Métodos para crear elementos del parque real tipo videojuego
  List<Widget> _buildParkPaths(Size size) {
    return [
      // Sendero principal curvo
      Positioned(
        top: 150,
        left: size.width * 0.1,
        child: CustomPaint(
          size: Size(size.width * 0.8, 400),
          painter: _CurvedPathPainter(),
        ),
      ),
      // Sendero secundario en forma de 8
      Positioned(
        top: 600,
        left: size.width * 0.2,
        child: CustomPaint(
          size: Size(size.width * 0.6, 300),
          painter: _FigureEightPathPainter(),
        ),
      ),
    ];
  }

  Widget _buildCentralPlayground(Size size) {
    return AnimatedBuilder(
      animation: _animatedElementsController,
      builder: (context, child) {
        final bounce = math.sin(_animatedElementsController.value * 2 * math.pi) * 3;
        return Positioned(
          left: size.width * 0.5 - 50,
          top: 450,
          child: SizedBox(
            width: 100,
            height: 80,
            child: Stack(
              children: [
                // CARRUSEL DIVERTIDO
                Positioned(
                  left: 20,
                  top: 10 + bounce,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.pink[300]!,
                          Colors.purple[400]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Rayitas del carrusel que giran
                        ...List.generate(8, (index) {
                          final angle = (index / 8) * 2 * math.pi + _animatedElementsController.value * 2 * math.pi;
                          return Positioned(
                            left: 30 + math.cos(angle) * 20 - 1,
                            top: 30 + math.sin(angle) * 20 - 8,
                            child: Container(
                              width: 2,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.yellow[300],
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          );
                        }),
                        Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.child_friendly,
                              color: Colors.pink[400],
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // BANDERITAS DECORATIVAS
                ...List.generate(3, (index) {
                  final flagColors = [Colors.red[400]!, Colors.blue[400]!, Colors.green[400]!];
                  return Positioned(
                    left: 10 + index * 30.0,
                    top: -5 + math.sin(_animatedElementsController.value * 3 * math.pi + index) * 2,
                    child: Container(
                      width: 8,
                      height: 12,
                      decoration: BoxDecoration(
                        color: flagColors[index],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParkTrees(Size size) {
    final trees = <Widget>[];
    final treePositions = [
      {'x': 0.1, 'y': 200.0, 'size': 60.0},
      {'x': 0.9, 'y': 180.0, 'size': 70.0},
      {'x': 0.15, 'y': 500.0, 'size': 55.0},
      {'x': 0.85, 'y': 520.0, 'size': 65.0},
      {'x': 0.05, 'y': 800.0, 'size': 50.0},
      {'x': 0.95, 'y': 820.0, 'size': 60.0},
      {'x': 0.2, 'y': 1000.0, 'size': 55.0},
      {'x': 0.8, 'y': 1020.0, 'size': 65.0},
    ];

    for (int i = 0; i < treePositions.length; i++) {
      final pos = treePositions[i];
      trees.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final sway = math.sin(_animatedElementsController.value * 2 * math.pi + i * 0.5) * 3;
            return Positioned(
              left: size.width * (pos['x']!) - (pos['size']!) / 2,
              top: (pos['y']!) + sway,
              child: SizedBox(
                width: pos['size']!,
                height: (pos['size']!) * 1.2,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Tronco
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: (pos['size']!) * 0.2,
                        height: (pos['size']!) * 0.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    // Copa del árbol con frutas
                    Positioned(
                      bottom: (pos['size']!) * 0.3,
                      child: Container(
                        width: pos['size']!,
                        height: (pos['size']!) * 0.8,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF32CD32),
                              const Color(0xFF228B22),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // FRUTAS EN EL ÁRBOL
                            ...List.generate(4, (fruitIndex) {
                              final fruits = ['🍎', '🍊', '🍋', '🍒'];
                              final fruitAngles = [0.5, 1.2, 2.1, 3.4];
                              final radius = (pos['size']!) * 0.3;
                              return Positioned(
                                left: (pos['size']!) * 0.5 + math.cos(fruitAngles[fruitIndex]) * radius - 8,
                                top: (pos['size']!) * 0.4 + math.sin(fruitAngles[fruitIndex]) * radius - 8,
                                child: Text(
                                  fruits[fruitIndex % fruits.length],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }),
                          ],
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
    return trees;
  }

  // COLINAS Y LOMAS DIVERTIDAS DEL PARQUE
  List<Widget> _buildParkHills(Size size) {
    return [
      // Colina izquierda
      Positioned(
        left: -50,
        top: 200,
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7CB342),
                const Color(0xFF8BC34A),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
          ),
        ),
      ),
      // Colina central
      Positioned(
        left: size.width * 0.3,
        top: 300,
        child: Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF689F38),
                const Color(0xFF7CB342),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(90),
              topRight: Radius.circular(90),
            ),
          ),
        ),
      ),
      // Colina derecha
      Positioned(
        right: -30,
        top: 250,
        child: Container(
          width: 160,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8BC34A),
                const Color(0xFF9CCC65),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(80),
              topRight: Radius.circular(80),
            ),
          ),
        ),
      ),
      // Loma trasera
      Positioned(
        left: size.width * 0.1,
        top: 600,
        child: Container(
          width: size.width * 0.8,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7CB342),
                const Color(0xFF689F38),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(200),
              topRight: Radius.circular(200),
            ),
          ),
        ),
      ),
    ];
  }
}

// Pintores personalizados para senderos curvos
class _CurvedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.7)
      ..strokeWidth = 25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    
    // Sendero en S suave
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.6, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.7,
      size.width, size.height * 0.3,
    );
    
    canvas.drawPath(path, paint);
    
    // Bordes del sendero
    paint.color = const Color(0xFFCD853F);
    paint.strokeWidth = 30;
    canvas.drawPath(path, paint);
    
    paint.color = const Color(0xFFDEB887);
    paint.strokeWidth = 20;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FigureEightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.6)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Figura de 8 acostada (∞)
    path.moveTo(size.width * 0.2, size.height * 0.5);
    
    // Primera curva
    path.cubicTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.7, size.height * 0.2,
      size.width * 0.8, size.height * 0.5,
    );
    
    // Cruce central
    path.cubicTo(
      size.width * 0.7, size.height * 0.8,
      size.width * 0.3, size.height * 0.8,
      size.width * 0.2, size.height * 0.5,
    );
    
    canvas.drawPath(path, paint);
    
    // Bordes
    paint.color = const Color(0xFFCD853F);
    paint.strokeWidth = 25;
    canvas.drawPath(path, paint);
    
    paint.color = const Color(0xFFDEB887);
    paint.strokeWidth = 15;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
