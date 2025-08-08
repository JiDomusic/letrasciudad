import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_service.dart';

class SyllableGameScreen extends StatefulWidget {
  final String letter;
  final String targetWord;
  final List<String> syllables;

  const SyllableGameScreen({
    super.key,
    required this.letter,
    required this.targetWord,
    required this.syllables,
  });

  @override
  State<SyllableGameScreen> createState() => _SyllableGameScreenState();
}

class _SyllableGameScreenState extends State<SyllableGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _celebrationController;
  late List<String> shuffledSyllables;
  List<String?> placedSyllables = [];
  List<GlobalKey> cardKeys = [];
  final AudioService _audioService = AudioService();
  bool gameCompleted = false;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _initializeGame();
    _cardAnimationController.forward();
    _playGameIntroduction();
  }

  void _initializeGame() {
    shuffledSyllables = List.from(widget.syllables);
    shuffledSyllables.shuffle();
    placedSyllables = List.filled(widget.syllables.length, null);
    cardKeys = List.generate(widget.syllables.length, (index) => GlobalKey());
    gameCompleted = false;
    attempts = 0;
  }

  void _playGameIntroduction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioService.speakText(
        '¡Hola! Vamos a jugar con las sílabas de la letra ${widget.letter}. '
        'Tienes que formar la palabra "${widget.targetWord}" arrastrando las sílabas al lugar correcto. ¡Es súper divertido!');
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF98FB98),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width < 400 ? 12 : 20,
                        right: MediaQuery.of(context).size.width < 400 ? 12 : 20,
                        top: MediaQuery.of(context).size.width < 400 ? 12 : 20,
                        bottom: 150, // Espacio para el contenedor inferior
                      ),
                      child: Column(
                        children: [
                          _buildSyllableCards(),
                          const SizedBox(height: 40),
                          if (gameCompleted) _buildCelebration(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Contenedor fijo en la parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _buildTargetWordArea(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    final titleFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
    final subtitleFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 16.0);
    final attemptsFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final headerPadding = isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(headerPadding),
      child: Row(
        children: [
          const Spacer(),
          Flexible(
            child: Column(
              children: [
                Text(
                  'Sílabas de ${widget.letter}',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Forma: ${widget.targetWord.toUpperCase()}',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12, 
              vertical: isSmallScreen ? 4 : 6
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isSmallScreen ? '$attempts' : 'Intentos: $attempts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: attemptsFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWordArea() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    final targetWidth = isSmallScreen ? 50.0 : (isMediumScreen ? 60.0 : 70.0);
    final targetHeight = isSmallScreen ? 45.0 : (isMediumScreen ? 52.0 : 60.0);
    final targetFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final titleFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final horizontalPadding = isSmallScreen ? 4.0 : (isMediumScreen ? 6.0 : 8.0);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Arrastra las sílabas aquí:',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        // Usar Wrap en lugar de Row para manejar pantallas pequeñas
        Wrap(
          alignment: WrapAlignment.center,
          spacing: horizontalPadding,
          runSpacing: 8,
          children: List.generate(widget.syllables.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  _placeSyllable(index, details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHighlighted = candidateData.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: targetWidth,
                    height: targetHeight,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.blue[100]
                          : (placedSyllables[index] != null
                              ? Colors.green[100]
                              : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isHighlighted
                            ? Colors.blue
                            : (placedSyllables[index] != null
                                ? Colors.green
                                : Colors.grey),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        placedSyllables[index] ?? '${index + 1}',
                        style: TextStyle(
                          fontSize: targetFontSize,
                          fontWeight: FontWeight.bold,
                          color: placedSyllables[index] != null
                              ? Colors.green[800]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSyllableCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    final spacing = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final runSpacing = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: WrapAlignment.center,
          children: shuffledSyllables.asMap().entries.map((entry) {
            final index = entry.key;
            final syllable = entry.value;
            final isUsed = placedSyllables.contains(syllable);
            
            if (isUsed) return const SizedBox.shrink();
            
            final delay = index * 0.1;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _cardAnimationController,
              curve: Interval(
                delay,
                math.min(1.0, delay + 0.3),
                curve: Curves.elasticOut,
              ),
            ));

            return Transform.scale(
              scale: animation.value,
              child: Draggable<String>(
                data: syllable,
                feedback: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: _buildSyllableCard(syllable, isDragging: true),
                ),
                childWhenDragging: _buildSyllableCard(syllable, isGhost: true),
                onDragStarted: () {
                  _audioService.speakText(syllable);
                },
                child: _buildSyllableCard(syllable),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSyllableCard(String syllable, {bool isDragging = false, bool isGhost = false}) {
    final colors = [
      Colors.pink[300]!, Colors.purple[300]!, Colors.indigo[300]!,
      Colors.blue[300]!, Colors.teal[300]!, Colors.green[300]!,
      Colors.orange[300]!, Colors.red[300]!,
    ];
    final color = colors[syllable.hashCode % colors.length];
    
    // Tamaños responsivos basados en el ancho de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    final cardWidth = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);
    final cardHeight = isSmallScreen ? 60.0 : (isMediumScreen ? 70.0 : 80.0);
    final fontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 21.0 : 24.0);
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGhost 
            ? [Colors.grey[300]!, Colors.grey[400]!]
            : [color.withValues(alpha: 0.8), color],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDragging || isGhost ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          syllable,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: isGhost ? Colors.grey[600] : Colors.white,
            shadows: isGhost ? null : [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationController.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow[300]!, Colors.orange[300]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🎉 ¡EXCELENTE! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Formaste "${widget.targetWord}" correctamente',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _restartGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Jugar otra vez'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.home),
                      label: const Text('Volver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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

  void _placeSyllable(int position, String syllable) {
    setState(() {
      // Remover la sílaba de su posición anterior si ya estaba colocada
      final previousIndex = placedSyllables.indexOf(syllable);
      if (previousIndex != -1) {
        placedSyllables[previousIndex] = null;
      }
      
      // Colocar la sílaba en la nueva posición
      placedSyllables[position] = syllable;
      attempts++;
    });

    _checkGameCompletion();
  }

  void _checkGameCompletion() {
    if (placedSyllables.every((syllable) => syllable != null)) {
      final formedWord = placedSyllables.join('');
      if (formedWord.toLowerCase() == widget.targetWord.toLowerCase()) {
        setState(() {
          gameCompleted = true;
        });
        _celebrationController.forward();
        _audioService.speakEncouragement();
        _audioService.speakText('¡Perfecto! Formaste la palabra ${widget.targetWord} con la letra ${widget.letter}. ¡Eres increíble!');
      } else {
        _audioService.speakTryAgain();
        // Limpiar las posiciones después de un intento incorrecto
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            placedSyllables = List.filled(widget.syllables.length, null);
          });
        });
      }
    }
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
    _cardAnimationController.reset();
    _celebrationController.reset();
    _cardAnimationController.forward();
    _audioService.speakText('¡Vamos a jugar otra vez! Forma la palabra ${widget.targetWord}');
  }
}
