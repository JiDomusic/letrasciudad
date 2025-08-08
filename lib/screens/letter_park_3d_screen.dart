import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../models/letter.dart';
import 'interactive_letter_games_screen.dart';

class LetterPark3DScreen extends StatefulWidget {
  const LetterPark3DScreen({super.key});

  @override
  State<LetterPark3DScreen> createState() => _LetterPark3DScreenState();
}

class _LetterPark3DScreenState extends State<LetterPark3DScreen> 
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _animationController;
  final AudioService _audioService = AudioService();
  
  double _currentRotation = 0.0;
  double _lastPanUpdate = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _animationController.repeat();
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioService.speakText(
      '¡Bienvenido al parque mágico de letras! Puedes girar para explorar las 27 casitas de las letras del alfabeto argentino. ¡Toca cualquier casa para empezar a aprender!'
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _animationController.dispose();
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
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFB0E2FF), // Light blue
              Color(0xFF98FB98), // Light green
              Color(0xFF90EE90), // Light green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _build3DParkView(),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parque 3D de Letras',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '27 letras del alfabeto argentino',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.threesixty,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DParkView() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onPanStart: (details) {
            _isDragging = true;
            _lastPanUpdate = details.globalPosition.dx;
          },
          onPanUpdate: (details) {
            if (_isDragging) {
              double delta = details.globalPosition.dx - _lastPanUpdate;
              setState(() {
                _currentRotation += delta * 0.01;
              });
              _lastPanUpdate = details.globalPosition.dx;
            }
          },
          onPanEnd: (details) {
            _isDragging = false;
          },
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Environment elements
                _buildSkyElements(),
                _buildMountainBackground(),
                _buildTreesAndFlowers(),
                _buildGround(),
                
                // 27 Letter houses in circular arrangement
                ..._build27LetterHouses(provider.letters),
                
                // Player avatar in center
                _buildCenterPlayer(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _build27LetterHouses(List<Letter> letters) {
    final houses = <Widget>[];
    final sortedLetters = List.from(letters);
    
    // Argentine alphabet order: A B C D E F G H I J K L M N Ñ O P Q R S T U V W X Y Z
    final argentineOrder = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    
    for (int i = 0; i < argentineOrder.length; i++) {
      final letterChar = argentineOrder[i];
      final letter = sortedLetters.firstWhere(
        (l) => l.character.toUpperCase() == letterChar,
        orElse: () => Letter(
          character: letterChar.toLowerCase(),
          name: 'Letra ${letterChar.toUpperCase()}',
          exampleWords: ['ejemplo'],
          primaryColor: _getColorForLetter(letterChar),
          phoneme: letterChar.toLowerCase(),
          audioPath: 'audio/${letterChar.toLowerCase()}.mp3',
          imagePath: 'images/${letterChar.toLowerCase()}.png',
          syllables: [letterChar.toLowerCase()],
        ),
      );

      // Perfect 360-degree distribution for 27 letters
      final angle = (i / 27.0) * 2 * math.pi + _currentRotation;
      final radius = MediaQuery.of(context).size.width * 0.35; // Responsive radius
      final x = math.cos(angle) * radius;
      final z = math.sin(angle) * radius;
      
      // Enhanced 3D perspective calculation
      final perspective = 1.0 + z * 0.002;
      final scale = (0.6 + perspective * 0.4).clamp(0.4, 1.0);
      final screenX = MediaQuery.of(context).size.width / 2 + x;
      final screenY = MediaQuery.of(context).size.height / 2 + (z > 0 ? -30 : 30) * scale;
      
      houses.add(
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final bounce = math.sin(_animationController.value * 2 * math.pi + i * 0.2) * 3;
            final sparkle = math.sin(_animationController.value * 4 * math.pi + i * 0.1) * 0.1 + 1.0;
            
            return Positioned(
              left: (screenX - 40).clamp(10, MediaQuery.of(context).size.width - 90),
              top: (screenY - 40 + bounce).clamp(120, MediaQuery.of(context).size.height - 180),
              child: Transform.scale(
                scale: scale * sparkle,
                child: Opacity(
                  opacity: 1.0, // Always fully visible
                  child: GestureDetector(
                    onTap: () => _onLetterHouseTap(letter),
                    child: Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            letter.primaryColor,
                            letter.primaryColor.withOpacity(0.7),
                            letter.primaryColor.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8 * scale,
                            offset: Offset(2 * scale, 4 * scale),
                          ),
                          BoxShadow(
                            color: letter.primaryColor.withOpacity(0.4),
                            blurRadius: 15 * scale,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // House roof
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                          ),
                          // House body with letter
                          Expanded(
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.brown, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    letter.character.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: letter.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[600],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return houses;
  }

  Widget _buildCenterPlayer() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final bounce = math.sin(_animationController.value * 2 * math.pi) * 2;
        
        return Center(
          child: Transform.translate(
            offset: Offset(0, bounce),
            child: Container(
              width: 60,
              height: 60,
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
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.child_care,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkyElements() {
    return Stack(
      children: [
        // Sun
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final bounce = math.sin(_animationController.value * 2 * math.pi) * 5;
            return Positioned(
              top: 50 + bounce,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('☀️', style: TextStyle(fontSize: 40)),
                ),
              ),
            );
          },
        ),
        // Clouds
        ..._buildClouds(),
        // Flying butterflies
        ..._buildButterflies(),
      ],
    );
  }

  List<Widget> _buildClouds() {
    return List.generate(5, (index) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final float = math.sin(_animationController.value * 2 * math.pi + index * 0.7) * 10;
          final drift = _animationController.value * 20 + index * 80;
          
          return Positioned(
            top: 80 + index * 20 + float,
            left: (drift + index * 100) % (MediaQuery.of(context).size.width + 100) - 50,
            child: Container(
              width: 60 + index * 10,
              height: 30 + index * 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildButterflies() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final progress = (_animationController.value + index * 0.33) % 1.0;
          final x = MediaQuery.of(context).size.width * 0.1 + 
                   math.sin(progress * math.pi * 2) * 100 +
                   index * MediaQuery.of(context).size.width * 0.3;
          final y = 150 + 
                   math.sin(progress * math.pi * 4) * 50 +
                   math.cos(progress * math.pi * 2) * 30;
          
          return Positioned(
            left: x,
            top: y,
            child: Transform.rotate(
              angle: progress * math.pi * 8,
              child: const Text('🦋', style: TextStyle(fontSize: 24)),
            ),
          );
        },
      );
    });
  }

  Widget _buildMountainBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MountainPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildTreesAndFlowers() {
    return Stack(
      children: [
        // Trees around the park
        ..._buildTrees(),
        // Flowers scattered around
        ..._buildFlowers(),
      ],
    );
  }

  List<Widget> _buildTrees() {
    final trees = <Widget>[];
    final treePositions = [
      {'x': 0.1, 'y': 0.3, 'size': 50.0},
      {'x': 0.9, 'y': 0.25, 'size': 60.0},
      {'x': 0.05, 'y': 0.7, 'size': 45.0},
      {'x': 0.95, 'y': 0.75, 'size': 55.0},
      {'x': 0.2, 'y': 0.8, 'size': 40.0},
      {'x': 0.8, 'y': 0.85, 'size': 50.0},
    ];

    for (int i = 0; i < treePositions.length; i++) {
      final pos = treePositions[i];
      trees.add(
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final sway = math.sin(_animationController.value * 2 * math.pi + i * 0.5) * 2;
            return Positioned(
              left: MediaQuery.of(context).size.width * (pos['x']!) - (pos['size']!) / 2,
              top: MediaQuery.of(context).size.height * (pos['y']!) + sway,
              child: Column(
                children: [
                  // Tree crown
                  Container(
                    width: pos['size']!,
                    height: (pos['size']!) * 0.8,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF32CD32), Color(0xFF228B22)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🌳', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                  // Tree trunk
                  Container(
                    width: (pos['size']!) * 0.2,
                    height: (pos['size']!) * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    
    return trees;
  }

  List<Widget> _buildFlowers() {
    return List.generate(15, (index) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final flutter = math.sin(_animationController.value * 3 * math.pi + index * 0.3) * 2;
          final x = (index * 37 + 50) % MediaQuery.of(context).size.width.toInt();
          final y = MediaQuery.of(context).size.height * 0.7 + (index % 3) * 50;
          
          final flowers = ['🌸', '🌺', '🌻', '🌷', '🌹'];
          
          return Positioned(
            left: x.toDouble(),
            top: y + flutter,
            child: Text(
              flowers[index % flowers.length],
              style: const TextStyle(fontSize: 20),
            ),
          );
        },
      );
    });
  }

  Widget _buildGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF90EE90).withOpacity(0.8),
              const Color(0xFF228B22),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _GrassPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rotation indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threesixty, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Arrastra para girar el parque',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Auto-rotate button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _startAutoRotation,
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Auto Girar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _stopAutoRotation,
                icon: const Icon(Icons.pause_circle_filled),
                label: const Text('Parar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetView,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startAutoRotation() {
    _rotationController.repeat();
    _rotationController.addListener(() {
      setState(() {
        _currentRotation = _rotationController.value * 2 * math.pi;
      });
    });
  }

  void _stopAutoRotation() {
    _rotationController.stop();
  }

  void _resetView() {
    setState(() {
      _currentRotation = 0.0;
    });
    _rotationController.reset();
  }

  Color _getColorForLetter(String letter) {
    final colors = {
      'A': Colors.red[400]!,
      'B': Colors.blue[400]!,
      'C': Colors.cyan[400]!,
      'D': Colors.deepOrange[400]!,
      'E': Colors.green[400]!,
      'F': Colors.purple[400]!,
      'G': Colors.teal[400]!,
      'H': Colors.amber[400]!,
      'I': Colors.indigo[400]!,
      'J': Colors.lime[400]!,
      'K': Colors.pink[400]!,
      'L': Colors.lightBlue[400]!,
      'M': Colors.orange[400]!,
      'N': Colors.deepPurple[400]!,
      'Ñ': Colors.red[600]!, // Special color for Ñ
      'O': Colors.lightGreen[400]!,
      'P': Colors.blueAccent[400]!,
      'Q': Colors.redAccent[400]!,
      'R': Colors.greenAccent[400]!,
      'S': Colors.yellowAccent[700]!,
      'T': Colors.purpleAccent[400]!,
      'U': Colors.cyanAccent[400]!,
      'V': Colors.pinkAccent[400]!,
      'W': Colors.brown[400]!,
      'X': Colors.grey[600]!,
      'Y': Colors.yellow[600]!,
      'Z': Colors.deepOrange[600]!,
    };
    return colors[letter] ?? Colors.blue[400]!;
  }

  void _onLetterHouseTap(Letter letter) async {
    await _audioService.playClickSound();
    
    if (!letter.isUnlocked) {
      await _audioService.speakText('Esta letra aún no está disponible');
      return;
    }

    await _audioService.speakText('¡Entremos a la casa de la letra ${letter.character.toUpperCase()}!');
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InteractiveLetterGamesScreen(letter: letter),
        ),
      );
    }
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background mountains
    paint.color = const Color(0xFF8B7D6B).withOpacity(0.3);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.8, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.5);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Foreground mountains
    paint.color = const Color(0xFF8B7D6B).withOpacity(0.5);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.6, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.6);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF32CD32)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grass blades
    for (double x = 0; x < size.width; x += 10) {
      final height = 15 + (x % 20);
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + 2, size.height - height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}