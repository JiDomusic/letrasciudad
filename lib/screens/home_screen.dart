import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
// import 'letter_details_screen.dart'; // No se usa actualmente
import 'letter_park_3d_screen.dart';
import 'house_preview_screen.dart';
// import 'first_person_park_screen.dart'; // Removido
import '../widgets/progress_header.dart';
import '../widgets/rounded_letter_house.dart';
import '../widgets/rolling_hills_terrain.dart';
import 'alphabet_main_screen.dart';

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
    // Detener cualquier audio anterior antes de reproducir bienvenida
    await _audioService.stop();
    await Future.delayed(const Duration(milliseconds: 500));
    final provider = context.read<LetterCityProvider>();
    
    // Check if player name needs to be set
    if (provider.playerName.isEmpty || provider.playerName == 'Pequeño Explorador') {
      _showNameInputDialog();
    } else {
      // Solo dar bienvenida si es la primera vez o si realmente es necesario
      // Evitar "hola otra vez" que suena raro - usar mensajes sin interpolación
      final messages = [
        '¡Hola! ¿Qué tal si jugamos con las letras?',
        '¡Holi! Me alegra verte. ¿Vamos a aprender juntos?',
        '¡Qué bueno que estés aquí! ¿Estás listo para nuevas aventuras con las letras?',
        'Qué bueno verte de nuevo. ¿Seguimos explorando el mundo de las letras?',
        '¡Hola otra vez! ¿Continuamos nuestra aventura?'
      ];
      
      // Usar un mensaje aleatorio para que no sea repetitivo
      final randomIndex = DateTime.now().millisecondsSinceEpoch % messages.length;
      await _audioService.speakText(messages[randomIndex]);
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _animatedElementsController.dispose();
    // DETENER COMPLETAMENTE la voz al salir de la página principal
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
                          // GRID DE LETRAS CON SCROLL VERTICAL
                          _buildLetterGrid(),
                          // ESPACIO EXTRA AL FINAL PARA SCROLL COMPLETO
                          const SizedBox(height: 50),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAlphabetGame(),
                    icon: const Icon(Icons.abc),
                    label: const Text('Alfabeto Completo A-Z'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
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
            // CONFIGURACIÓN RESPONSIVA
            final screenWidth = size.width;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 900;
            
            // CALCULAR ALTURA NECESARIA PARA MÓVIL
            if (isMobile) {
              final housesPerRow = screenWidth < 350 ? 2 : (screenWidth < 500 ? 3 : 4);
              final totalRows = (sortedLetters.length / housesPerRow).ceil(); // Usar sortedLetters.length para exactitud
              final houseSize = 85.0; // Tamaño máximo de casa
              final verticalSpacing = houseSize + 30;
              final mobileContentHeight = 50.0 + (totalRows * verticalSpacing) + 100.0; // Espacio extra al final
              
              return SizedBox(
                width: size.width,
                height: mobileContentHeight,
                child: Stack(
                  children: [
                    // Casas de letras en grid ordenado para móvil
                    ...sortedLetters.asMap().entries.map((entry) {
                      final index = entry.key;
                      final letter = entry.value;
                      final position = _calculateOptimalPosition(index, sortedLetters.length, size);
                      
                      return Positioned(
                        left: position['x']!,
                        top: position['y']!,
                        child: Transform.scale(
                          scale: _gridAnimation.value,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            opacity: _gridAnimation.value,
                            child: RoundedLetterHouse(
                              letter: letter.character,
                              size: position['size']!,
                              onTap: () => _onLetterTap(letter.character),
                              isUnlocked: letter.isUnlocked,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            } else {
              // VERSIÓN WEB CON TODOS LOS EFECTOS
              final contentHeight = size.height * 2.0; // Altura para web
              
              return SizedBox(
                width: size.width,
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
                    
                    // Animales de granja en el parque
                    ..._buildFarmAnimals(),

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
                                  color: Colors.blue.withValues(alpha: 0.3),
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
                    
                    // Casas coloridas distribuidas naturalmente por el terreno (WEB)
                    ...sortedLetters.asMap().entries.map((entry) {
                      final index = entry.key;
                      final letter = entry.value;
                      final position = _calculateOptimalPosition(index, sortedLetters.length, size);
                      final elevation = position['elevation'] ?? 0.0;
                      final zone = position['zone'] ?? 0;
                      
                      // EFECTOS VISUALES PARA WEB
                      final depthScale = 1.0 - (zone * 0.02);
                      final depthOpacity = 1.0 - (zone * 0.015);
                      final alphabetDelay = index * 60;
                      
                      return Positioned(
                        left: position['x']!,
                        top: position['y']!,
                        child: Transform.scale(
                          scale: _gridAnimation.value * depthScale.clamp(0.92, 1.0),
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 500 + alphabetDelay),
                            opacity: (_gridAnimation.value * depthOpacity).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 12 + (elevation * 6),
                                    offset: Offset(
                                      4 + (elevation * 3),
                                      6 + (elevation * 4),
                                    ),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20 + (elevation * 8),
                                    offset: Offset(
                                      6 + (elevation * 4),
                                      8 + (elevation * 5),
                                    ),
                                  ),
                                ],
                              ),
                              child: RoundedLetterHouse(
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
            }
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
    final isMobile = screenWidth < 600;
    
    if (isMobile) {
      // === MÓVIL: ALINEADO Y ORDENADO ===
      return _calculateMobilePosition(index, totalLetters, size);
    } else {
      // === WEB: DISPERSO PERO ORDENADO ===
      return _calculateWebPosition(index, totalLetters, size);
    }
  }
  
  // POSICIONAMIENTO MÓVIL: GRID ORGANIZADO Y RESPONSIVO
  Map<String, double> _calculateMobilePosition(int index, int totalLetters, Size size) {
    final screenWidth = size.width;
    
    // ESPACIADO RESPONSIVO PARA MÓVIL
    final sideSpace = 16.0; // Espacio lateral fijo
    final availableWidth = screenWidth - (sideSpace * 2);
    
    // CASAS POR FILA RESPONSIVAS
    final housesPerRow = screenWidth < 350 ? 2 : (screenWidth < 500 ? 3 : 4);
    
    // TAMAÑO DE CASA RESPONSIVO
    final spacing = 12.0; // Espaciado entre casas
    final maxHouseSize = (availableWidth - ((housesPerRow - 1) * spacing)) / housesPerRow;
    final houseSize = math.min(maxHouseSize, 85.0).clamp(50.0, 85.0);
    
    final row = (index / housesPerRow).floor();
    final col = index % housesPerRow;
    
    // POSICIÓN X: CENTRADO PERFECTO
    final totalContentWidth = (housesPerRow * houseSize) + ((housesPerRow - 1) * spacing);
    final startX = (screenWidth - totalContentWidth) / 2;
    final x = startX + (col * (houseSize + spacing));
    
    // POSICIÓN Y: ESPACIADO VERTICAL AMPLIO PARA SCROLL
    final verticalSpacing = houseSize + 30; // Más espacio vertical
    final y = 50.0 + (row * verticalSpacing); // Empezar desde arriba
    
    return {
      'x': x,
      'y': y,
      'size': houseSize,
      'walkProgress': 0.5,
      'elevation': 0.5,
      'zone': row.toDouble(),
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
    
    // POSICIÓN FINAL: ORGÁNICA PERO MANTENIENDO FLUJO ALFABÉTICO
    final majorVariationX = ((index * 137 + 43) % 80) - 40; // ±40px
    final majorVariationY = ((index * 181 + 71) % 60) - 30; // ±30px
    final microVariationX = ((index * 211 + 91) % 30) - 15; // ±15px
    final microVariationY = ((index * 241 + 113) % 20) - 10; // ±10px
    
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
                  color: Colors.yellow.withValues(alpha: 0.3),
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
                          Colors.white.withValues(alpha: 0.8),
                          balloonColors[i],
                          balloonColors[i].withValues(alpha: 0.7),
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
                          color: balloonColors[i].withValues(alpha: 0.3),
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
                          color: Colors.yellow.withValues(alpha: 0.6),
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
                        color: Colors.purple.withValues(alpha: 0.3),
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

  List<Widget> _buildFarmAnimals() {
    final animals = <Widget>[];
    final size = MediaQuery.of(context).size;
    
    // VACAS CAMINANDO POR EL PARQUE (movimiento continuo hacia adelante)
    for (int i = 0; i < 2; i++) {
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            // Movimiento continuo hacia adelante (de izquierda a derecha)
            final progress = (_animatedElementsController.value * 0.2 + i * 0.5) % 1.0;
            final x = progress * (size.width + 100) - 80; // De izquierda a derecha
            final bounce = math.sin(progress * 10) * 3; // Movimiento de caminar más realista
            final sway = math.sin(progress * 12) * 1; // Balanceo lateral sutil
            
            return Positioned(
              left: x,
              top: 380.0 + bounce + (i * 60.0), // Vacas en diferentes alturas
              child: Transform.scale(
                scaleX: -1, // Voltear horizontalmente para que mire hacia adelante
                child: Container(
                  width: 60,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.brown[400]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(2 + sway, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐄', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // PLANTAS Y FLORES DECORATIVAS EN EL PARQUE
    final flowerTypes = ['🌸', '🌺', '🌻', '🌷', '🌹', '🌼', '🪻'];
    final plantTypes = ['🌿', '🌱', '🍀', '🌾', '🪴'];
    
    // Flores distribuidas por el parque
    for (int i = 0; i < 12; i++) {
      final flower = flowerTypes[i % flowerTypes.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final sway = math.sin((_animatedElementsController.value + i * 0.2) * 2 * math.pi) * 2;
            final baseX = (size.width / 13) * (i + 1);
            final baseY = 300.0 + (i % 3) * 150.0; // Diferentes alturas en 3 filas
            
            return Positioned(
              left: baseX + sway,
              top: baseY,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(flower, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Plantas verdes adicionales
    for (int i = 0; i < 8; i++) {
      final plant = plantTypes[i % plantTypes.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final rustle = math.sin((_animatedElementsController.value + i * 0.3) * 3 * math.pi) * 1;
            final baseX = 50.0 + (size.width / 9) * i;
            final baseY = 250.0 + (i % 2) * 200.0;
            
            return Positioned(
              left: baseX + rustle,
              top: baseY,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green[300]!, width: 1),
                ),
                child: Center(
                  child: Text(plant, style: const TextStyle(fontSize: 20)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Árboles ornamentales
    for (int i = 0; i < 4; i++) {
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final treeX = (size.width / 5) * (i + 1);
            final treeY = 200.0 + (i % 2) * 300.0;
            
            return Positioned(
              left: treeX,
              top: treeY,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.green[600]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌳', style: TextStyle(fontSize: 35)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // FLORES SILVESTRES ADICIONALES (más pequeñas y dispersas)
    final wildFlowers = ['🌼', '🌻', '🌺', '🏵️', '💐', '🌷', '🌸', '🪷'];
    for (int i = 0; i < 15; i++) {
      final flower = wildFlowers[i % wildFlowers.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final flutter = math.sin((_animatedElementsController.value + i * 0.4) * 4 * math.pi) * 1;
            final baseX = 30.0 + (size.width / 16) * i;
            final baseY = 150.0 + (i % 4) * 120.0; // 4 filas de flores silvestres
            
            return Positioned(
              left: baseX + flutter,
              top: baseY,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.pink[100]!, width: 1),
                ),
                child: Center(
                  child: Text(flower, style: const TextStyle(fontSize: 18)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // ARBUSTOS CON FRUTOS
    final berryBushes = ['🫐', '🍓', '🍇', '🍒'];
    for (int i = 0; i < 6; i++) {
      final berry = berryBushes[i % berryBushes.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final baseX = 80.0 + (size.width / 7) * i;
            final baseY = 180.0 + (i % 2) * 350.0;
            
            return Positioned(
              left: baseX,
              top: baseY,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[300],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[700]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(berry, style: const TextStyle(fontSize: 25)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // PLANTAS AROMÁTICAS Y HIERBAS
    final herbs = ['🌿', '🌱', '☘️', '🍃', '🌾'];
    for (int i = 0; i < 10; i++) {
      final herb = herbs[i % herbs.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final sway = math.sin((_animatedElementsController.value + i * 0.25) * 3 * math.pi) * 1.5;
            final baseX = 40.0 + (size.width / 11) * i;
            final baseY = 320.0 + (i % 3) * 100.0;
            
            return Positioned(
              left: baseX + sway,
              top: baseY,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.lightGreen[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[400]!, width: 1),
                ),
                child: Center(
                  child: Text(herb, style: const TextStyle(fontSize: 16)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // CACTUS Y SUCULENTAS (para variedad)
    final succulents = ['🌵', '🪴', '🌿'];
    for (int i = 0; i < 4; i++) {
      final succulent = succulents[i % succulents.length];
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final baseX = 120.0 + (size.width / 5) * i;
            final baseY = 500.0;
            
            return Positioned(
              left: baseX,
              top: baseY,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.green[500]!, width: 2),
                ),
                child: Center(
                  child: Text(succulent, style: const TextStyle(fontSize: 22)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // GALLINAS PICOTEANDO
    for (int i = 0; i < 3; i++) {
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final peck = math.sin((_animatedElementsController.value + i * 0.3) * 8 * math.pi) * 3;
            final waddle = math.sin((_animatedElementsController.value + i * 0.2) * 3 * math.pi) * 10;
            
            return Positioned(
              left: 100 + (i * 80) + waddle,
              top: 600 + peck,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange[300]!, width: 1),
                ),
                child: const Center(
                  child: Text('🐓', style: TextStyle(fontSize: 24)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // POLLITOS SIGUIENDO A LAS GALLINAS
    for (int i = 0; i < 5; i++) {
      animals.add(
        AnimatedBuilder(
          animation: _animatedElementsController,
          builder: (context, child) {
            final follow = math.sin((_animatedElementsController.value + i * 0.4) * 4 * math.pi) * 5;
            final peep = math.sin((_animatedElementsController.value + i * 0.6) * 12 * math.pi) * 2;
            
            return Positioned(
              left: 80 + (i * 40) + follow,
              top: 640 + peep,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.yellow[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[200]!, width: 1),
                ),
                child: const Center(
                  child: Text('🐣', style: TextStyle(fontSize: 14)),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return animals;
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
          builder: (context) => HousePreviewScreen(letterData: letter),
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

  void _navigateToAlphabetGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlphabetMainScreen(
          audioService: _audioService,
        ),
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
                    color: Colors.black.withValues(alpha: 0.3),
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


  void _showNameInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.child_care, color: Colors.blue[600], size: 28),
            const SizedBox(width: 8),
            const Text('¡Hola! ¿Cómo te llamas?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Soy Luna, tu guía mágica. Me gustaría conocer tu nombre para poder llamarte por él durante nuestras aventuras.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu nombre aquí',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
              ),
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<LetterCityProvider>().setPlayerName(name);
                Navigator.of(context).pop();
                // Añadir delay antes del mensaje para evitar problemas de sincronización
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Mensaje de bienvenida sin interpolación del nombre
                  _audioService.speakText('¡Hola! Qué nombre tan bonito. Soy Luna, tu guía en este parque mágico de letras. ¿Estás listo para descubrir todas las aventuras que tengo preparadas?');
                });
              } else {
                context.read<LetterCityProvider>().setPlayerName('Pequeño Explorador');
                Navigator.of(context).pop();
                // Añadir delay antes del mensaje para evitar problemas de sincronización
                Future.delayed(const Duration(milliseconds: 300), () {
                  _audioService.speakText('¡Hola pequeño explorador! Soy Luna, tu guía en este parque mágico de letras. ¿Estás listo para descubrir todas las aventuras que tengo preparadas?');
                });
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('¡Empezar a Jugar!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
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

  // ignore: unused_element
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

  // ignore: unused_element
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
                          color: Colors.black.withValues(alpha: 0.2),
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
                              color: Colors.black.withValues(alpha: 0.2),
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
      ..color = const Color(0xFFDEB887).withValues(alpha: 0.7)
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
      ..color = const Color(0xFFDEB887).withValues(alpha: 0.6)
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

    // Pequeñas flores rosadas decorativas originales
    paint.color = const Color(0xFFFFB6C1);
    for (int i = 0; i < 8; i++) {
      final x = (size.width * 0.2) + (i * size.width * 0.1);
      final y = size.height * 0.75 + (i % 2 == 0 ? 5 : -5);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
    
    // NUEVAS FLORES ADICIONALES para más belleza en el parque
    
    // Flores amarillas pequeñas
    paint.color = const Color(0xFFFFD700);
    for (int i = 0; i < 12; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.08);
      final y = size.height * 0.78 + (i % 3 == 0 ? 8 : i % 3 == 1 ? -3 : 2);
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
    
    // Flores violetas medianas
    paint.color = const Color(0xFF9370DB);
    final violetPositions = [
      Offset(size.width * 0.12, size.height * 0.68),
      Offset(size.width * 0.35, size.height * 0.72),
      Offset(size.width * 0.58, size.height * 0.69),
      Offset(size.width * 0.78, size.height * 0.74),
      Offset(size.width * 0.88, size.height * 0.71),
    ];
    for (final pos in violetPositions) {
      canvas.drawCircle(pos, 4, paint);
    }
    
    // Flores rojas pequeñas
    paint.color = const Color(0xFFFF6347);
    final redPositions = [
      Offset(size.width * 0.25, size.height * 0.82),
      Offset(size.width * 0.45, size.height * 0.79),
      Offset(size.width * 0.65, size.height * 0.83),
      Offset(size.width * 0.85, size.height * 0.80),
    ];
    for (final pos in redPositions) {
      canvas.drawCircle(pos, 3, paint);
    }
    
    // Flores blancas delicadas
    paint.color = const Color(0xFFFFFAFA);
    final whitePositions = [
      Offset(size.width * 0.18, size.height * 0.73),
      Offset(size.width * 0.38, size.height * 0.76),
      Offset(size.width * 0.55, size.height * 0.74),
      Offset(size.width * 0.72, size.height * 0.77),
      Offset(size.width * 0.92, size.height * 0.75),
    ];
    for (final pos in whitePositions) {
      canvas.drawCircle(pos, 2, paint);
    }
    
    // Flores naranjas vibrantes
    paint.color = const Color(0xFFFF8C00);
    final orangePositions = [
      Offset(size.width * 0.08, size.height * 0.76),
      Offset(size.width * 0.28, size.height * 0.71),
      Offset(size.width * 0.48, size.height * 0.77),
      Offset(size.width * 0.68, size.height * 0.72),
    ];
    for (final pos in orangePositions) {
      canvas.drawCircle(pos, 3.5, paint);
    }

    paint.color = Colors.white.withValues(alpha: 0.8);
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
