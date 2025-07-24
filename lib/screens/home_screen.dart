import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import 'ar_city_screen.dart';
import 'letter_details_screen.dart';
import '../widgets/letter_house_widget.dart';
import '../widgets/progress_header.dart';

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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          _buildLetterGrid(),
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
                onPressed: provider.isCameraPermissionGranted
                    ? () => _navigateToARCity()
                    : () => _showCameraPermissionDialog(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Vista AR'),
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
            return SizedBox(
              height: 700,
              child: Stack(
                children: [
                  _buildAnimatedSun(),
                  ..._buildFloatingBalloons(),
                  ..._buildWalkingAnimals(),
                  Positioned(
                    left: (size.width - 40) / 2 - 25,
                    top: 400 - 25,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  ...sortedLetters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final letter = entry.value;
                    final delay = index * 0.1;
                    final position = _calculatePathPosition(index, sortedLetters.length, size);

                    return Positioned(
                      left: position['x'],
                      top: position['y'],
                      child: Transform.scale(
                        scale: _gridAnimation.value,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300 + (delay * 100).round()),
                          opacity: _gridAnimation.value,
                          child: SizedBox(
                            width: position['size'],
                            height: position['size']! * 1.3,
                            child: LetterHouseWidget(
                              letter: letter,
                              showPhonetic: false, // Esto oculta el texto interno
                              onTap: () => _onLetterTap(letter.character),
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

  Map<String, double> _calculatePathPosition(int index, int totalLetters, Size size) {
    final parkWidth = size.width - 80; // Más margen
    final baseSize = 60.0; // Casas un poco más pequeñas
    
    // Configuración del paseo serpenteante
    final housesPerRow = (parkWidth / (baseSize + 20)).floor(); // Espaciado de 20px entre casas
    final rowHeight = baseSize + 30; // Espaciado vertical entre filas
    
    final row = index ~/ housesPerRow;
    final col = index % housesPerRow;
    
    // Alternar dirección en filas pares/impares para efecto serpenteante
    final adjustedCol = row % 2 == 0 ? col : (housesPerRow - 1 - col);
    
    // Posición base
    final baseX = 40 + adjustedCol * (baseSize + 20);
    final baseY = 50 + row * rowHeight;
    
    // Añadir pequeña variación para efecto de sendero natural
    final xVariation = (index % 3 - 1) * 5; // Variación de -5 a +5
    final yVariation = (index % 2) * 3; // Pequeña variación vertical
    
    return {
      'x': baseX + xVariation,
      'y': baseY + yVariation,
      'size': baseSize,
    };
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

  List<Widget> _buildWalkingAnimals() {
    final animals = <Widget>[];

    animals.add(_buildWalkingCat(0, 150, Colors.orange[300]!, '🐱'));
    animals.add(_buildWalkingCat(0.5, 250, Colors.grey[400]!, '🐱'));
    animals.add(_buildWalkingDog(0.3, 350, Colors.brown[300]!, '🐶'));
    animals.add(_buildWalkingDog(0.8, 450, Colors.yellow[700]!, '🐕'));

    return animals;
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
          builder: (context) => LetterDetailsScreen(letter: letter),
        ),
      );
    }
  }

  void _navigateToARCity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ARCityScreen(),
      ),
    );
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de Cámara'),
        content: const Text(
          'Para usar la realidad aumentada necesitamos acceso a tu cámara.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
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