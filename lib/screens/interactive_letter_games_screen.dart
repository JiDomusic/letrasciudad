import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../models/letter.dart';

class InteractiveLetterGamesScreen extends StatefulWidget {
  final Letter letter;

  const InteractiveLetterGamesScreen({
    super.key, 
    required this.letter,
  });

  @override
  State<InteractiveLetterGamesScreen> createState() => _InteractiveLetterGamesScreenState();
}

class _InteractiveLetterGamesScreenState extends State<InteractiveLetterGamesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final AudioService _audioService = AudioService();
  int _selectedGameIndex = 0;
  
  // Word tracking system to prevent repetition
  final Set<String> _usedWords = {};
  final Set<String> _usedDistractors = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat();
    // Ensure used words lists start fresh
    _usedWords.clear();
    _usedDistractors.clear();
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // El niño puede interrumpir tocando la pantalla
    _audioService.speakText(
      '¡Bienvenido a la casa de la letra ${widget.letter.character}!'
    );
  }

  void _skipNarration() {
    // Permite al niño saltar la narración
    _audioService.stop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // DETENER VOZ AL SALIR DE LA PÁGINA
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // PERMITIR AL NINO INTERRUMPIR INMEDIATAMENTE LA NARRACION
      onTap: _skipNarration,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFFB0E2FF),
                Color(0xFF98FB98),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
              Expanded(
                child: _buildGameContent(),
              ),
              _buildGameSelector(),
              ],
            ),
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
            onPressed: () {
              // Detener la voz narradora antes de salir
              _audioService.stop();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80, // Aumentado de 60 a 80
            height: 80, // Aumentado de 60 a 80
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  widget.letter.primaryColor,
                  widget.letter.primaryColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                widget.letter.character.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32, // Aumentado de 24 a 32
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Casa de la ${widget.letter.character.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24, // Aumentado de 20 a 24
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¡Juegos interactivos!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18, // Aumentado de 14 a 18
                  ),
                ),
              ],
            ),
          ),
          Consumer<LetterCityProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.totalStars}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_selectedGameIndex) {
      case 0:
        return _buildObjectSelectionGame();
      case 1:
        return _buildLetterTracingGame();
      case 2:
        return _buildFindAllLettersGame();
      case 3:
        return _buildLetterSoundGame();
      default:
        return _buildObjectSelectionGame();
    }
  }

  Widget _buildGameSelector() {
    final games = [
      {'icon': Icons.touch_app, 'title': 'Seleccionar', 'color': Colors.green[400]!},
      {'icon': Icons.edit, 'title': 'Trazar', 'color': Colors.blue[400]!},
      {'icon': Icons.search, 'title': 'Buscar', 'color': Colors.purple[400]!},
      {'icon': Icons.volume_up, 'title': 'Sonidos', 'color': Colors.orange[400]!},
    ];

    // Detectar si es web o móvil
    final isWeb = MediaQuery.of(context).size.width > 800;
    final gameHeight = isWeb ? 120.0 : 100.0;
    final selectedSize = isWeb ? 110.0 : 90.0;
    final unselectedSize = isWeb ? 90.0 : 75.0;

    return Container(
      height: gameHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: games.asMap().entries.map((entry) {
          final index = entry.key;
          final game = entry.value;
          final isSelected = index == _selectedGameIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedGameIndex = index;
                // Reset used words when switching games
                _usedWords.clear();
                _usedDistractors.clear();
              });
              _audioService.speakText('¡${game['title']}! ¡Qué divertido!');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? selectedSize : unselectedSize,
              height: isSelected ? selectedSize : unselectedSize,
              decoration: BoxDecoration(
                color: game['color'] as Color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (game['color'] as Color).withOpacity(0.4),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game['icon'] as IconData,
                    color: Colors.white,
                    size: isSelected ? (isWeb ? 48 : 36) : (isWeb ? 40 : 30), // Más grande en web
                  ),
                  if (isSelected)
                    Text(
                      game['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 14 : 12, // Más grande en web
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildObjectSelectionGame() {
    // Get fresh objects that haven't been used
    final objectsForLetter = _getUnusedObjectsForLetter(widget.letter.character);
    final distractorObjects = _getUnusedDistractorObjects();
    final allObjects = [...objectsForLetter, ...distractorObjects]..shuffle();
    
    // ELIMINAR PERMANENTEMENTE: Solo mostrar objetos que nunca han sido seleccionados
    final availableObjects = allObjects.where((obj) {
      final objName = obj['name'] as String;
      // No mostrar si ya fue usado como palabra correcta o distractor
      return !_usedWords.contains(objName) && !_usedDistractors.contains(objName);
    }).toList();

    // Si no hay objetos disponibles, mostrar mensaje de completado
    if (availableObjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '¡Felicidades!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Has encontrado todos los objetos que empiezan con "${widget.letter.character.toUpperCase()}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Resetear solo cuando el usuario lo solicite explícitamente
                  _usedWords.clear();
                  _usedDistractors.clear();
                });
                _audioService.speakText('¡Vamos a jugar otra vez!');
              },
              child: const Text('¡Jugar de nuevo!'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[600], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toca todos los objetos que empiecen con "${widget.letter.character.toUpperCase()}"',
                    style: const TextStyle(
                      fontSize: 20, // Aumentado de 16 a 20
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = MediaQuery.of(context).size.width > 800;
                
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWeb ? 3 : 2, // 3 en web, 2 en móvil
                    childAspectRatio: isWeb ? 0.9 : 0.8, // Más cuadrado en web
                    crossAxisSpacing: isWeb ? 30 : 20, // Más espacio en web
                    mainAxisSpacing: isWeb ? 30 : 20, // Más espacio en web
                  ),
                  itemCount: availableObjects.length,
                  itemBuilder: (context, index) {
                    final obj = availableObjects[index];
                    return _buildSelectableObject(obj, isWeb);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // FUNCIÓN PARA VERIFICAR SI UNA PALABRA REALMENTE EMPIEZA CON LA LETRA DADA
  bool _verifyWordStartsWithLetter(String word, String letter) {
    if (word.isEmpty || letter.isEmpty) return false;
    
    final wordLower = word.toLowerCase();
    final letterLower = letter.toLowerCase();
    
    // Casos especiales del español argentino
    switch (letterLower) {
      case 'h':
        // H es muda pero se cuenta
        return wordLower.startsWith('h');
      case 'ñ':
        return wordLower.startsWith('ñ');
      case 'qu':
        return wordLower.startsWith('qu');
      default:
        return wordLower.startsWith(letterLower);
    }
  }

  Widget _buildSelectableObject(Map<String, dynamic> obj, bool isWeb) {
    final isCorrect = obj['correct'] as bool;
    final isSelected = obj['selected'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _handleObjectTap(obj),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // ULTRA-RESPONSIVO: 50% más rápido
        curve: Curves.easeOutQuart, // Curva más suave y rápida
        decoration: BoxDecoration(
          color: isSelected 
              ? (isCorrect ? Colors.green[200] : Colors.red[200]) // Más vibrante
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? (isCorrect ? Colors.green[600]! : Colors.red[600]!)
                : Colors.grey[300]!,
            width: isSelected ? 4 : 1, // Borde más prominente
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (isCorrect ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4))
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 6, // Sombra dinámica
              offset: Offset(0, isSelected ? 6 : 3),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EMOJI ADAPTATIVO: Más grande en web, normal en móvil
            Text(
              obj['emoji'] as String,
              style: TextStyle(fontSize: isWeb ? 120 : 70), // 120 en web, 70 en móvil
            ),
            SizedBox(height: isWeb ? 16 : 12),
            // QUITAR TEXTO PARA QUE EL NINO ADIVINE
            // Solo mostrar texto después de seleccionar
            if (isSelected) ...[
              Text(
                obj['name'] as String,
                style: TextStyle(
                  fontSize: isWeb ? 22 : 18, // Más grande en web
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWeb ? 12 : 8),
            ],
            // ICONOS DE FEEDBACK ADAPTATIVOS
            if (isSelected && isCorrect)
              Icon(Icons.check_circle, color: Colors.green, size: isWeb ? 36 : 28),
            if (isSelected && !isCorrect)
              Icon(Icons.cancel, color: Colors.red, size: isWeb ? 36 : 28),
          ],
        ),
      ),
    );
  }

  void _handleObjectTap(Map<String, dynamic> obj) {
    final wordName = obj['name'] as String;
    final isCorrect = obj['correct'] as bool;
    
    // VERIFICACIÓN REAL: ¿La palabra realmente empieza con la letra correcta?
    final actuallyCorrect = _verifyWordStartsWithLetter(wordName, widget.letter.character);
    
    if (isCorrect && actuallyCorrect) {
      // FEEDBACK POSITIVO SOLO SI ES REALMENTE CORRECTO
      _audioService.speakText('¡Excelente! ${obj['name']}');
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('object_selection_${widget.letter.character}', 15);
      
      // ELIMINACIÓN PERMANENTE: Marcar como usado y refrescar UI
      setState(() {
        _usedWords.add(wordName);
      });
      
    } else {
      // FEEDBACK PARA RESPUESTA INCORRECTA
      _audioService.speakText('¡Inténtalo de nuevo! Busca palabras que empiecen con ${widget.letter.character.toUpperCase()}');
      
      // ELIMINACIÓN PERMANENTE: Marcar como usado y refrescar UI
      setState(() {
        _usedDistractors.add(wordName);
      });
      
      // Mostrar feedback visual temporal
      _showFailureFeedback();
    }
  }

  Widget _buildLetterTracingGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Traza la letra ${widget.letter.character.toUpperCase()} con tu dedo o mouse',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPhone = MediaQuery.of(context).size.shortestSide < 600;
                final margin = isPhone ? 10.0 : 20.0;
                
                return Container(
                  width: double.infinity,
                  height: constraints.maxHeight,
                  margin: EdgeInsets.all(margin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _TracingCanvas(
                    letter: widget.letter.character.toUpperCase(),
                    audioService: _audioService,
                    onTracingComplete: () {
                      context.read<LetterCityProvider>().completeActivity('letter_tracing_${widget.letter.character}', 20);
                    },
                    onCelebrationStars: _showCelebrationStars,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindAllLettersGame() {
    final letters = _generateLetterGrid();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.purple[600], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Busca y marca todas las letras "${widget.letter.character.toUpperCase()}"',
                    style: const TextStyle(
                      fontSize: 20, // Aumentado de 16 a 20
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Reducido a 4 para letras aún más grandes
                  childAspectRatio: 1,
                  crossAxisSpacing: 12, // Más espacio entre letras
                  mainAxisSpacing: 12, // Más espacio vertical
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letterData = letters[index];
                  return _buildFindableLetter(letterData);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindableLetter(Map<String, dynamic> letterData) {
    final letter = letterData['letter'] as String;
    final isTarget = letterData['isTarget'] as bool;
    final isFound = letterData['found'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _handleLetterFind(letterData),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFound 
              ? (isTarget ? Colors.green[100] : Colors.red[100])
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFound 
                ? (isTarget ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isFound ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 42, // Aumentado aún más para mejor visibilidad
              fontWeight: FontWeight.bold,
              color: isFound 
                  ? (isTarget ? Colors.green[700] : Colors.red[700])
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLetterFind(Map<String, dynamic> letterData) {
    setState(() {
      letterData['found'] = true;
    });

    if (letterData['isTarget'] as bool) {
      _audioService.speakText('¡Correcto! Encontraste la ${widget.letter.character}');
      // CELEBRACIÓN CON ESTRELLAS Y GRATIFICACIÓN
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('find_letter_${widget.letter.character}', 10);
    } else {
      _audioService.speakText('Esa no es la letra ${widget.letter.character}');
      // CELEBRACIÓN ROJA CUANDO FALLA
      _showFailureFeedback();
    }
  }

  Widget _buildLetterSoundGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.volume_up, color: Colors.orange[600], size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '¡Escucha y aprende los sonidos!',
                    style: TextStyle(
                      fontSize: 20, // Aumentado de 16 a 20
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Letra grande animada
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + math.sin(_animationController.value * 2 * math.pi) * 0.1,
                      child: Container(
                        width: 200, // Aumentado de 150 a 200
                        height: 200, // Aumentado de 150 a 200
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              widget.letter.primaryColor,
                              widget.letter.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.letter.primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.letter.character.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 80, // Aumentado de 60 a 80
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Botones de sonido
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSoundButton(
                      'Letra',
                      Icons.abc,
                      Colors.blue,
                      () => _audioService.speakText(widget.letter.character),
                    ),
                    _buildSoundButton(
                      'Sonido',
                      Icons.hearing,
                      Colors.green,
                      () => _audioService.speakText(widget.letter.phoneme),
                    ),
                    _buildSoundButton(
                      'Palabra',
                      Icons.chat_bubble,
                      Colors.purple,
                      () => _audioService.speakText(widget.letter.exampleWords.first),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28), // Aumentado tamaño del icono
      label: Text(label, style: TextStyle(fontSize: 18)), // Aumentado tamaño del texto
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), // Botones más grandes
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getObjectsForLetter(String letter) {
    final objectsMap = {
      'A': [
        {'emoji': '🪡', 'name': 'Aguja', 'correct': true},
        {'emoji': '👵', 'name': 'Abuela', 'correct': true},
        {'emoji': '⚓', 'name': 'Ancla', 'correct': true},
        {'emoji': '🌳', 'name': 'Árbol', 'correct': true},
        {'emoji': '💍', 'name': 'Anillo', 'correct': true},
        {'emoji': '🟫', 'name': 'Alfombra', 'correct': true},
        {'emoji': '🛏️', 'name': 'Almohada', 'correct': true},
        {'emoji': '✈️', 'name': 'Avión', 'correct': true},
        {'emoji': '🧄', 'name': 'Ajo', 'correct': true},
        {'emoji': '🧮', 'name': 'Ábaco', 'correct': true},
        {'emoji': '🏠', 'name': 'Armario', 'correct': true},
        {'emoji': '🐛', 'name': 'Abeja', 'correct': true},
        // Palabras distractoras que NO empiezan con A
        {'emoji': '🐕', 'name': 'Perro', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🍌', 'name': 'Banana', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'B': [
        {'emoji': '🍌', 'name': 'Banana', 'correct': true},
        {'emoji': '🦉', 'name': 'Búho', 'correct': true},
        {'emoji': '⚽', 'name': 'Balón', 'correct': true},
        {'emoji': '🚌', 'name': 'Bus', 'correct': true},
        {'emoji': '🧸', 'name': 'Bebé', 'correct': true},
        {'emoji': '🚲', 'name': 'Bicicleta', 'correct': true},
        {'emoji': '🏖️', 'name': 'Barca', 'correct': true},
        {'emoji': '🍼', 'name': 'Biberón', 'correct': true},
        {'emoji': '👢', 'name': 'Bota', 'correct': true},
        {'emoji': '🌈', 'name': 'Bandera', 'correct': true},
        {'emoji': '🧺', 'name': 'Balde', 'correct': true},
        {'emoji': '🎺', 'name': 'Bocina', 'correct': true},
      ],
      'C': [
        {'emoji': '🚗', 'name': 'Carro', 'correct': true},
        {'emoji': '🎂', 'name': 'Cumpleaños', 'correct': true},
        {'emoji': '🏠', 'name': 'Casa', 'correct': true},
        {'emoji': '🛏️', 'name': 'Cama', 'correct': true},
        {'emoji': '🦓', 'name': 'Cebra', 'correct': true},
        {'emoji': '☁️', 'name': 'Cielo', 'correct': true},
        {'emoji': '🍒', 'name': 'Cereza', 'correct': true},
        {'emoji': '👑', 'name': 'Corona', 'correct': true},
        {'emoji': '🥄', 'name': 'Cuchara', 'correct': true},
        {'emoji': '🐔', 'name': 'Caballo', 'correct': true},
        {'emoji': '🏔️', 'name': 'Campo', 'correct': true},
        {'emoji': '🧿', 'name': 'Cuchillo', 'correct': true},
      ],
      'D': [
        {'emoji': '🐕', 'name': 'Dálmata', 'correct': true},
        {'emoji': '🦷', 'name': 'Diente', 'correct': true},
        {'emoji': '💎', 'name': 'Diamante', 'correct': true},
        {'emoji': '🎯', 'name': 'Diana', 'correct': true},
        {'emoji': '🐬', 'name': 'Delfín', 'correct': true},
        {'emoji': '🦕', 'name': 'Dinosaurio', 'correct': true},
        {'emoji': '🌅', 'name': 'Día', 'correct': true},
        {'emoji': '🔟', 'name': 'Diez', 'correct': true},
        {'emoji': '🏺', 'name': 'Dulce', 'correct': true},
        {'emoji': '🐈', 'name': 'Dragón', 'correct': true},
        {'emoji': '🍑', 'name': 'Durazno', 'correct': true},
        {'emoji': '💰', 'name': 'Dinero', 'correct': true},
      ],
      'E': [
        {'emoji': '🐘', 'name': 'Elefante', 'correct': true},
        {'emoji': '⭐', 'name': 'Estrella', 'correct': true},
        {'emoji': '🪜', 'name': 'Escalera', 'correct': true},
        {'emoji': '✉️', 'name': 'Sobre', 'correct': true},
        {'emoji': '🦅', 'name': 'Águila', 'correct': true},
        {'emoji': '🌍', 'name': 'Tierra', 'correct': true},
        {'emoji': '🏫', 'name': 'Escuela', 'correct': true},
        {'emoji': '🪞', 'name': 'Espejo', 'correct': true},
        {'emoji': '🥚', 'name': 'Huevo', 'correct': true},
        {'emoji': '🦔', 'name': 'Erizo', 'correct': true},
        {'emoji': '🌿', 'name': 'Espiga', 'correct': true},
        {'emoji': '⚒️', 'name': 'Espada', 'correct': true},
      ],
      'F': [
        {'emoji': '🌸', 'name': 'Flor', 'correct': true},
        {'emoji': '🍓', 'name': 'Fresa', 'correct': true},
        {'emoji': '🔥', 'name': 'Fuego', 'correct': true},
        {'emoji': '⚽', 'name': 'Fútbol', 'correct': true},
        {'emoji': '🎪', 'name': 'Feria', 'correct': true},
        {'emoji': '🏭', 'name': 'Fábrica', 'correct': true},
        {'emoji': '🍴', 'name': 'Tenedor', 'correct': true},
        {'emoji': '📱', 'name': 'Teléfono', 'correct': true},
        {'emoji': '🧊', 'name': 'Frío', 'correct': true},
        {'emoji': '🦅', 'name': 'Flamenco', 'correct': true},
        {'emoji': '🌙', 'name': 'Farol', 'correct': true},
        {'emoji': '🎆', 'name': 'Fuegos', 'correct': true},
      ],
      'G': [
        {'emoji': '🐱', 'name': 'Gato', 'correct': true},
        {'emoji': '🎈', 'name': 'Globo', 'correct': true},
        {'emoji': '🧤', 'name': 'Guante', 'correct': true},
        {'emoji': '🦒', 'name': 'Gacela', 'correct': true},
        {'emoji': '🎸', 'name': 'Guitarra', 'correct': true},
        {'emoji': '🍇', 'name': 'Grosella', 'correct': true},
        {'emoji': '🐸', 'name': 'Grillo', 'correct': true},
        {'emoji': '👓', 'name': 'Gafas', 'correct': true},
        {'emoji': '🍪', 'name': 'Galleta', 'correct': true},
        {'emoji': '🐓', 'name': 'Gallo', 'correct': true},
        {'emoji': '🌍', 'name': 'Geografía', 'correct': true},
        {'emoji': '🥅', 'name': 'Goma', 'correct': true},
      ],
      'H': [
        {'emoji': '🐜', 'name': 'Hormiga', 'correct': true},
        {'emoji': '🏠', 'name': 'Hogar', 'correct': true},
        {'emoji': '🌿', 'name': 'Hoja', 'correct': true},
        {'emoji': '🍯', 'name': 'Hongo', 'correct': true},
        {'emoji': '🔨', 'name': 'Herramienta', 'correct': true},
        {'emoji': '🦔', 'name': 'Hámster', 'correct': true},
        {'emoji': '🧊', 'name': 'Hielo', 'correct': true},
        {'emoji': '🌻', 'name': 'Harina', 'correct': true},
        {'emoji': '🏥', 'name': 'Hospital', 'correct': true},
        {'emoji': '🦅', 'name': 'Halcón', 'correct': true},
        {'emoji': '🥚', 'name': 'Huevo', 'correct': true},
        {'emoji': '🌿', 'name': 'Hierba', 'correct': true},
        {'emoji': '🍦', 'name': 'Helado', 'correct': true},
      ],
      'I': [
        {'emoji': '🏝️', 'name': 'Isla', 'correct': true},
        {'emoji': '🦎', 'name': 'Iguana', 'correct': true},
        {'emoji': '⛪', 'name': 'Iglesia', 'correct': true},
        {'emoji': '🧲', 'name': 'Imán', 'correct': true},
        {'emoji': '🍦', 'name': 'Helado', 'correct': false},
        {'emoji': '🌈', 'name': 'Iris', 'correct': true},
        {'emoji': '🐜', 'name': 'Hormiga', 'correct': false},
        {'emoji': '👁️', 'name': 'Ojo', 'correct': false},
        {'emoji': '🐻', 'name': 'Oso', 'correct': false},
        {'emoji': '🌞', 'name': 'Sol', 'correct': false},
      ],
      'J': [
        {'emoji': '🦒', 'name': 'Jirafa', 'correct': true},
        {'emoji': '🧴', 'name': 'Jabón', 'correct': true},
        {'emoji': '💎', 'name': 'Joya', 'correct': true},
        {'emoji': '🎮', 'name': 'Juego', 'correct': true},
        {'emoji': '🌻', 'name': 'Girasol', 'correct': true},
        {'emoji': '🌺', 'name': 'Jazmín', 'correct': true},
        {'emoji': '🧑', 'name': 'Joven', 'correct': true},
        {'emoji': '🏺', 'name': 'Jarrón', 'correct': true},
        {'emoji': '🪴', 'name': 'Jardín', 'correct': true},
        {'emoji': '🐎', 'name': 'Jaguar', 'correct': true},
        {'emoji': '🍷', 'name': 'Jugo', 'correct': true},
        {'emoji': '🦅', 'name': 'Jilguero', 'correct': true},
      ],
      'K': [
        {'emoji': '🥝', 'name': 'Kiwi', 'correct': true},
        {'emoji': '🥋', 'name': 'Karate', 'correct': true},
        {'emoji': '🐨', 'name': 'Koala', 'correct': true},
        {'emoji': '🔢', 'name': 'Kilo', 'correct': true},
        {'emoji': '🪁', 'name': 'Kayak', 'correct': true},
        {'emoji': '🏪', 'name': 'Kiosco', 'correct': true},
        {'emoji': '🧄', 'name': 'Karmen', 'correct': false},
        {'emoji': '🐧', 'name': 'Lobo', 'correct': false},
        {'emoji': '🦔', 'name': 'Erizo', 'correct': false},
        {'emoji': '🚗', 'name': 'Auto', 'correct': false},
      ],
      'L': [
        {'emoji': '🦁', 'name': 'León', 'correct': true},
        {'emoji': '📚', 'name': 'Libro', 'correct': true},
        {'emoji': '🔑', 'name': 'Llave', 'correct': true},
        {'emoji': '🌙', 'name': 'Luna', 'correct': true},
        {'emoji': '🍋', 'name': 'Limón', 'correct': true},
        {'emoji': '🪔', 'name': 'Lámpara', 'correct': true},
        {'emoji': '🐺', 'name': 'Lobo', 'correct': true},
        {'emoji': '🌊', 'name': 'Lago', 'correct': true},
        {'emoji': '🦎', 'name': 'Lagarto', 'correct': true},
        {'emoji': '🥛', 'name': 'Leche', 'correct': true},
        {'emoji': '🤓', 'name': 'Lentes', 'correct': true},
        {'emoji': '✏️', 'name': 'Lápiz', 'correct': true},
      ],
      'M': [
        {'emoji': '🐵', 'name': 'Mono', 'correct': true},
        {'emoji': '🍎', 'name': 'Manzana', 'correct': true},
        {'emoji': '👨‍⚕️', 'name': 'Médico', 'correct': true},
        {'emoji': '🏔️', 'name': 'Montaña', 'correct': true},
        {'emoji': '🎵', 'name': 'Música', 'correct': true},
        {'emoji': '🦋', 'name': 'Mariposa', 'correct': true},
        {'emoji': '🍯', 'name': 'Miel', 'correct': true},
        {'emoji': '🥭', 'name': 'Mango', 'correct': true},
        {'emoji': '🪑', 'name': 'Mesa', 'correct': true},
        {'emoji': '🐭', 'name': 'Ratón', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🪞', 'name': 'Espejo', 'correct': false},
      ],
      'N': [
        {'emoji': '☁️', 'name': 'Nube', 'correct': true},
        {'emoji': '🌃', 'name': 'Noche', 'correct': true},
        {'emoji': '🥜', 'name': 'Nuez', 'correct': true},
        {'emoji': '👃', 'name': 'Nariz', 'correct': true},
        {'emoji': '🍊', 'name': 'Naranja', 'correct': true},
        {'emoji': '❄️', 'name': 'Nieve', 'correct': true},
        {'emoji': '🪺', 'name': 'Nido', 'correct': true},
        {'emoji': '👶', 'name': 'Niño', 'correct': true},
        {'emoji': '🔢', 'name': 'Número', 'correct': true},
        {'emoji': '🚀', 'name': 'Nave', 'correct': true},
        {'emoji': '🎵', 'name': 'Nota', 'correct': true},
        {'emoji': '📰', 'name': 'Noticia', 'correct': true},
      ],
      'O': [
        {'emoji': '🐻', 'name': 'Oso', 'correct': true},
        {'emoji': '👁️', 'name': 'Ojo', 'correct': true},
        {'emoji': '🌊', 'name': 'Ola', 'correct': true},
        {'emoji': '👂', 'name': 'Oreja', 'correct': true},
        {'emoji': '🐑', 'name': 'Oveja', 'correct': true},
        {'emoji': '🌊', 'name': 'Océano', 'correct': true},
        {'emoji': '🐋', 'name': 'Orca', 'correct': true},
        {'emoji': '🌅', 'name': 'Oriente', 'correct': true},
        {'emoji': '🪙', 'name': 'Oro', 'correct': true},
        {'emoji': '🥚', 'name': 'Huevo', 'correct': false},
        {'emoji': '🦴', 'name': 'Hueso', 'correct': false},
        {'emoji': '🦉', 'name': 'Búho', 'correct': false},
      ],
      'P': [
        {'emoji': '🐧', 'name': 'Pingüino', 'correct': true},
        {'emoji': '🍕', 'name': 'Pizza', 'correct': true},
        {'emoji': '🌲', 'name': 'Pino', 'correct': true},
        {'emoji': '🎂', 'name': 'Pastel', 'correct': true},
        {'emoji': '🦆', 'name': 'Pato', 'correct': true},
        {'emoji': '☂️', 'name': 'Paraguas', 'correct': true},
        {'emoji': '🧩', 'name': 'Puzzle', 'correct': true},
        {'emoji': '🚪', 'name': 'Puerta', 'correct': true},
        {'emoji': '🍍', 'name': 'Piña', 'correct': true},
        {'emoji': '🕊️', 'name': 'Paloma', 'correct': true},
        {'emoji': '🥒', 'name': 'Pepino', 'correct': true},
        {'emoji': '🍑', 'name': 'Durazno', 'correct': false},
      ],
      'Q': [
        {'emoji': '🧀', 'name': 'Queso', 'correct': true},
        {'emoji': '🔥', 'name': 'Quemar', 'correct': true},
        {'emoji': '🤫', 'name': 'Quieto', 'correct': true},
        {'emoji': '❓', 'name': 'Qué', 'correct': true},
        {'emoji': '💕', 'name': 'Querer', 'correct': true},
        {'emoji': '🗣️', 'name': 'Queja', 'correct': true},
        {'emoji': '🧬', 'name': 'Química', 'correct': true},
        {'emoji': '💕', 'name': 'Querido', 'correct': true},
        {'emoji': '🔥', 'name': 'Quemadura', 'correct': true},
        {'emoji': '🌲', 'name': 'Quebracho', 'correct': true},
        {'emoji': '🏠', 'name': 'Hogar', 'correct': false},
        {'emoji': '🏃‍♂️', 'name': 'Correr', 'correct': false},
      ],
      'R': [
        {'emoji': '🌹', 'name': 'Rosa', 'correct': true},
        {'emoji': '🐭', 'name': 'Ratón', 'correct': true},
        {'emoji': '⚡', 'name': 'Rayo', 'correct': true},
        {'emoji': '🎁', 'name': 'Regalo', 'correct': true},
        {'emoji': '🐸', 'name': 'Rana', 'correct': true},
        {'emoji': '📻', 'name': 'Radio', 'correct': true},
        {'emoji': '🦏', 'name': 'Rinoceronte', 'correct': true},
        {'emoji': '🌊', 'name': 'Río', 'correct': true},
        {'emoji': '🤖', 'name': 'Robot', 'correct': true},
        {'emoji': '🚀', 'name': 'Cohete', 'correct': false},
        {'emoji': '💍', 'name': 'Anillo', 'correct': false},
        {'emoji': '🌈', 'name': 'Arcoíris', 'correct': false},
      ],
      'S': [
        {'emoji': '☀️', 'name': 'Sol', 'correct': true},
        {'emoji': '🐍', 'name': 'Serpiente', 'correct': true},
        {'emoji': '💺', 'name': 'Silla', 'correct': true},
        {'emoji': '💤', 'name': 'Sueño', 'correct': true},
        {'emoji': '🧂', 'name': 'Sal', 'correct': true},
        {'emoji': '🌙', 'name': 'Sombra', 'correct': true},
        {'emoji': '🍉', 'name': 'Sandía', 'correct': true},
        {'emoji': '🐸', 'name': 'Sapo', 'correct': true},
        {'emoji': '🦈', 'name': 'Tiburón', 'correct': false},
        {'emoji': '👟', 'name': 'Zapato', 'correct': false},
        {'emoji': '🍓', 'name': 'Fresa', 'correct': false},
        {'emoji': '🔔', 'name': 'Campana', 'correct': false},
      ],
      'T': [
        {'emoji': '🐅', 'name': 'Tigre', 'correct': true},
        {'emoji': '🌮', 'name': 'Taco', 'correct': true},
        {'emoji': '📺', 'name': 'Televisión', 'correct': true},
        {'emoji': '🎾', 'name': 'Tenis', 'correct': true},
        {'emoji': '🐢', 'name': 'Tortuga', 'correct': true},
        {'emoji': '🌪️', 'name': 'Tornado', 'correct': true},
        {'emoji': '🍅', 'name': 'Tomate', 'correct': true},
        {'emoji': '📞', 'name': 'Teléfono', 'correct': true},
        {'emoji': '🗼', 'name': 'Torre', 'correct': true},
        {'emoji': '🍵', 'name': 'Té', 'correct': true},
        {'emoji': '💃', 'name': 'Tango', 'correct': true},
        {'emoji': '🎭', 'name': 'Teatro', 'correct': true},
      ],
      'U': [
        {'emoji': '🍇', 'name': 'Uva', 'correct': true},
        {'emoji': '🦄', 'name': 'Unicornio', 'correct': true},
        {'emoji': '☂️', 'name': 'Paraguas', 'correct': false},
        {'emoji': '1️⃣', 'name': 'Uno', 'correct': true},
        {'emoji': '💅', 'name': 'Uña', 'correct': true},
        {'emoji': '🏛️', 'name': 'Universidad', 'correct': false},
        {'emoji': '🔊', 'name': 'Sonido', 'correct': false},
        {'emoji': '⭐', 'name': 'Único', 'correct': true},
        {'emoji': '🔧', 'name': 'Útil', 'correct': false},
        {'emoji': '🌈', 'name': 'Arcoíris', 'correct': false},
        {'emoji': '🦪', 'name': 'Uniforme', 'correct': false},
        {'emoji': '🌍', 'name': 'Universo', 'correct': false},
      ],
      'V': [
        {'emoji': '🐄', 'name': 'Vaca', 'correct': true},
        {'emoji': '✈️', 'name': 'Volar', 'correct': true},
        {'emoji': '🌋', 'name': 'Volcán', 'correct': true},
        {'emoji': '🪟', 'name': 'Ventana', 'correct': true},
        {'emoji': '🏐', 'name': 'Voleibol', 'correct': true},
        {'emoji': '🍷', 'name': 'Vino', 'correct': true},
        {'emoji': '👗', 'name': 'Vestido', 'correct': true},
        {'emoji': '🎻', 'name': 'Violín', 'correct': true},
        {'emoji': '🍃', 'name': 'Verde', 'correct': true},
        {'emoji': '🐍', 'name': 'Víbora', 'correct': true},
        {'emoji': '🌆', 'name': 'Valle', 'correct': true},
        {'emoji': '🦊', 'name': 'Zorro', 'correct': false},
      ],
      'W': [
        {'emoji': '🥪', 'name': 'Wafle', 'correct': true},
        {'emoji': '🌐', 'name': 'Web', 'correct': true},
        {'emoji': '📶', 'name': 'WiFi', 'correct': true},
        {'emoji': '🥃', 'name': 'Whisky', 'correct': true},
        {'emoji': '🪄', 'name': 'Wok', 'correct': true},
        {'emoji': '🦅', 'name': 'Walabi', 'correct': true},
        {'emoji': '⌚', 'name': 'Watch', 'correct': false},
        {'emoji': '💻', 'name': 'Windows', 'correct': false},
        {'emoji': '🌍', 'name': 'World', 'correct': false},
        {'emoji': '🎮', 'name': 'Wii', 'correct': false},
        {'emoji': '🔧', 'name': 'Workshop', 'correct': false},
        {'emoji': '🏆', 'name': 'Winner', 'correct': false},
      ],
      'X': [
        {'emoji': '❌', 'name': 'Equis', 'correct': true},
        {'emoji': '❌', 'name': 'Xi', 'correct': true},
        {'emoji': '🎷', 'name': 'Saxofón', 'correct': false},
        {'emoji': '🗂️', 'name': 'Expediente', 'correct': false},
        {'emoji': '🧪', 'name': 'Experimento', 'correct': false},
        {'emoji': '🦴', 'name': 'Hueso', 'correct': false},
        {'emoji': '🎭', 'name': 'Teatro', 'correct': false},
        {'emoji': '📱', 'name': 'Teléfono', 'correct': false},
        {'emoji': '🔍', 'name': 'Explorar', 'correct': false},
        {'emoji': '🏛️', 'name': 'Templo', 'correct': false},
        {'emoji': '📊', 'name': 'Examen', 'correct': false},
        {'emoji': '🖥️', 'name': 'Xerox', 'correct': false},
      ],
      'Y': [
        {'emoji': '🛥️', 'name': 'Yate', 'correct': true},
        {'emoji': '🧘', 'name': 'Yoga', 'correct': true},
        {'emoji': '🥄', 'name': 'Yema', 'correct': true},
        {'emoji': '🩹', 'name': 'Yeso', 'correct': true},
        {'emoji': '🌱', 'name': 'Hierba', 'correct': false},
        {'emoji': '💍', 'name': 'Joya', 'correct': false},
        {'emoji': '🧊', 'name': 'Hielo', 'correct': false},
        {'emoji': '💛', 'name': 'Amarillo', 'correct': false},
        {'emoji': '👶', 'name': 'Bebé', 'correct': false},
        {'emoji': '🤗', 'name': 'Yudo', 'correct': true},
        {'emoji': '🍃', 'name': 'Yuyos', 'correct': true},
        {'emoji': '🔥', 'name': 'Yesca', 'correct': true},
      ],
      'Z': [
        {'emoji': '👟', 'name': 'Zapato', 'correct': true},
        {'emoji': '🥕', 'name': 'Zanahoria', 'correct': true},
        {'emoji': '🦊', 'name': 'Zorro', 'correct': true},
        {'emoji': '🦆', 'name': 'Zambullida', 'correct': true},
        {'emoji': '🌈', 'name': 'Zona', 'correct': true},
        {'emoji': '🧿', 'name': 'Zombi', 'correct': true},
        {'emoji': '🦓', 'name': 'Cebra', 'correct': false},
        {'emoji': '🏰', 'name': 'Castillo', 'correct': false},
        {'emoji': '📏', 'name': 'Regla', 'correct': false},
        {'emoji': '⚡', 'name': 'Rayo', 'correct': false},
        {'emoji': '🧭', 'name': 'Brújula', 'correct': false},
        {'emoji': '🐸', 'name': 'Rana', 'correct': false},
      ],
      'N_TILDE': [
        {'emoji': '🥘', 'name': 'Ñoquis', 'correct': true},
        {'emoji': '😴', 'name': 'Sueño', 'correct': true},
        {'emoji': '👦', 'name': 'Niño', 'correct': true},
        {'emoji': '🤏', 'name': 'Pequeño', 'correct': true},
        {'emoji': '🍂', 'name': 'Otoño', 'correct': true},
        {'emoji': '🐸', 'name': 'Rana', 'correct': false},
        {'emoji': '🚗', 'name': 'Auto', 'correct': false},
      ],
    };
    
    // Mapear Ñ a la clave correcta
    final key = letter.toUpperCase() == 'Ñ' ? 'N_TILDE' : letter.toUpperCase();
    return objectsMap[key] ?? [
      {'emoji': '❓', 'name': 'Objeto', 'correct': true},
    ];
  }

  List<Map<String, dynamic>> _getUnusedObjectsForLetter(String letter) {
    final allObjects = _getObjectsForLetter(letter);
    final unused = allObjects.where((obj) => !_usedWords.contains(obj['name'])).toList();
    
    // Si hemos usado todas las palabras, mostrar mensaje y generar nuevos objetos
    if (unused.isEmpty) {
      // NO RESETEAR - mantener objetos eliminados para siempre en esta sesión
      // En su lugar, usar palabras alternativas o mostrar mensaje de completado
      _audioService.speakText('¡Increíble! Has encontrado todas las palabras que empiezan con ${letter.toUpperCase()}');
      return []; // Retornar lista vacía para indicar que se completó todo
    }
    
    return unused.take(4).toList(); // Hasta 4 objetos no usados
  }

  List<Map<String, dynamic>> _getUnusedDistractorObjects() {
    final allDistractors = [
      {'emoji': '🌟', 'name': 'Estrella', 'correct': false},
      {'emoji': '🌸', 'name': 'Flor', 'correct': false},
      {'emoji': '🎈', 'name': 'Globo', 'correct': false},
      {'emoji': '🚗', 'name': 'Carro', 'correct': false},
      {'emoji': '🏠', 'name': 'Casa', 'correct': false},
      {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      {'emoji': '☀️', 'name': 'Sol', 'correct': false},
      {'emoji': '🎯', 'name': 'Diana', 'correct': false},
      {'emoji': '🎁', 'name': 'Regalo', 'correct': false},
      {'emoji': '⚽', 'name': 'Pelota', 'correct': false},
      {'emoji': '🍌', 'name': 'Banana', 'correct': false},
      {'emoji': '🐱', 'name': 'Gato', 'correct': false},
      {'emoji': '🐘', 'name': 'Elefante', 'correct': false},
      {'emoji': '🦒', 'name': 'Jirafa', 'correct': false},
      {'emoji': '🐻', 'name': 'Oso', 'correct': false},
      {'emoji': '🎂', 'name': 'Pastel', 'correct': false},
      {'emoji': '🐕', 'name': 'Perro', 'correct': false},
      {'emoji': '🌮', 'name': 'Taco', 'correct': false},
      {'emoji': '🎾', 'name': 'Tenis', 'correct': false},
      {'emoji': '🦄', 'name': 'Unicornio', 'correct': false},
    ];
    
    // Filter out words that start with the current letter and used distractors
    final currentLetter = widget.letter.character.toUpperCase();
    final validDistractors = allDistractors.where((obj) {
      final name = obj['name'] as String;
      final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '';
      return firstLetter != currentLetter && !_usedDistractors.contains(name);
    }).toList();
    
    // Si hemos usado todos los distractors válidos, NO resetear (mantener eliminados)
    if (validDistractors.isEmpty) {
      // NO RESETEAR - los objetos eliminados se mantienen eliminados
      return []; // Sin distractors disponibles
    }
    
    validDistractors.shuffle();
    return validDistractors.take(2).toList(); // Hasta 2 distractors no usados
  }


  List<Map<String, dynamic>> _generateLetterGrid() {
    final random = math.Random();
    final letters = <Map<String, dynamic>>[];
    final targetLetter = widget.letter.character.toUpperCase();
    
    // Agregar letras target (5-8 instancias)
    for (int i = 0; i < 6; i++) {
      letters.add({
        'letter': targetLetter,
        'isTarget': true,
        'found': false,
      });
    }
    
    // Agregar letras distractoras
    final distractorLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((l) => l != targetLetter)
        .toList();
    
    for (int i = 0; i < 30; i++) {
      letters.add({
        'letter': distractorLetters[random.nextInt(distractorLetters.length)],
        'isTarget': false,
        'found': false,
      });
    }
    
    letters.shuffle();
    return letters;
  }

  // MÉTODO PARA CELEBRACIÓN CON ESTRELLAS
  void _showCelebrationStars() {
    // Crear overlay para las estrellas
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationStarsWidget(
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  void _showSuccessMessage(String wordName) {
    // Crear overlay para el mensaje de éxito
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _SuccessMessageWidget(
        wordName: wordName,
        letterName: widget.letter.character.toUpperCase(),
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  // MÉTODO PARA FEEDBACK CUANDO FALLA (ROJO)
  void _showFailureFeedback() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _FailureFeedbackWidget(
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

// Widget personalizado para trazar letras con mouse y dedo
class _TracingCanvas extends StatefulWidget {
  final String letter;
  final VoidCallback onTracingComplete;
  final VoidCallback onCelebrationStars;
  final AudioService audioService;

  const _TracingCanvas({
    required this.letter,
    required this.onTracingComplete,
    required this.onCelebrationStars,
    required this.audioService,
  });

  @override
  State<_TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<_TracingCanvas> with TickerProviderStateMixin {
  final List<List<Offset>> _strokes = [];
  final List<List<Offset>> _invalidStrokes = []; // Track invalid strokes
  List<Offset> _currentStroke = [];
  bool _hasTraced = false;
  
  // Letter validation properties
  int _validStrokes = 0;
  final int _requiredStrokes = 1; // Most letters need at least 1 good stroke
  
  // Animation properties
  late AnimationController _demoController;
  late Animation<double> _demoAnimation;
  bool _showingDemo = false;
  
  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      duration: const Duration(seconds: 5), // Aumentado de 3 a 5 segundos para mejor visibilidad
      vsync: this,
    );
    _demoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _demoController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isPhone = MediaQuery.of(context).size.shortestSide < 600;
              final fontSize = isPhone 
                  ? math.min(constraints.maxWidth * 0.7, constraints.maxHeight * 0.7)
                  : 280.0;
              
              // Calculate unified drawing area using constraints (safe during build)
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;
              // Área más pequeña en móvil para evitar que las letras se salgan
              // Área de dibujo responsiva que asegura que la letra sea completamente visible
              final drawingSize = isPhone 
                  ? math.min(screenWidth * 0.9, screenHeight * 0.7).clamp(280.0, 400.0) // Móvil: más grande con límites
                  : math.min(screenWidth * 0.8, screenHeight * 0.7);  // Web/tablet: tamaño original
              final drawingRect = Rect.fromCenter(
                center: Offset(screenWidth / 2, screenHeight / 2),
                width: drawingSize,
                height: drawingSize,
              );
              
              return Stack(
                children: [
                  // Unified drawing area with letter guide and canvas
                  Positioned(
                    left: drawingRect.left,
                    top: drawingRect.top,
                    width: drawingRect.width,
                    height: drawingRect.height,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                      ),
                      child: Stack(
                        children: [
                          // Letter background guide - TAMANO RESPONSIVE
                          Center(
                            child: Text(
                              widget.letter,
                              style: TextStyle(
                                fontSize: isPhone ? drawingSize * 0.65 : drawingSize * 0.7, // Tamaño proporcional optimizado
                                fontWeight: FontWeight.w200,
                                color: Colors.grey[200],
                                fontFamily: 'Arial',
                              ),
                            ),
                          ),
                          // Animated letter demonstration
                          AnimatedBuilder(
                            animation: _demoAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(drawingRect.width, drawingRect.height),
                                painter: _LetterDemoPainter(
                                  letter: widget.letter,
                                  progress: _demoAnimation.value,
                                  showDemo: _showingDemo,
                                ),
                              );
                            },
                          ),
                          // Tracing canvas
                          GestureDetector(
                            onPanStart: (details) {
                              setState(() {
                                _currentStroke = [details.localPosition];
                                _hasTraced = true;
                              });
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                _currentStroke.add(details.localPosition);
                              });
                            },
                            onPanEnd: (details) {
                              setState(() {
                                if (_currentStroke.isNotEmpty) {
                                  _strokes.add(List.from(_currentStroke));
                                  
                                  // Validar el trazo con criterios permisivos pero educativos
                                  if (_validateStroke(_currentStroke, drawingRect.width, drawingRect.height)) {
                                    _validStrokes++;
                                    
                                    // Feedback positivo variado y motivador
                                    final encouragements = [
                                      '¡Muy bien!', '¡Excelente!', '¡Fantástico!', 
                                      '¡Genial!', '¡Perfecto!', '¡Increíble!',
                                      '¡Lo estás haciendo súper bien!', '¡Qué buen trazo!',
                                      '¡Eres un campeón!', '¡Sigue así!'
                                    ];
                                    final randomIndex = DateTime.now().millisecondsSinceEpoch % encouragements.length;
                                    widget.audioService.speakText(encouragements[randomIndex]);
                                    
                                    // Celebrar cuando complete suficientes trazos válidos
                                    if (_validStrokes >= _requiredStrokes) {
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        widget.onCelebrationStars();
                                        widget.onTracingComplete(); // IMPORTANTE: Marcar como completado
                                        widget.audioService.speakText('¡Has trazado muy bien la letra ${widget.letter}!');
                                      });
                                    }
                                    
                                  } else {
                                    // Mover trazo inválido para mostrarlo temporalmente en rojo
                                    _invalidStrokes.add(_strokes.removeLast());
                                    
                                    // Contar intentos fallidos para dar mejor ayuda
                                    final failedAttempts = _invalidStrokes.length;
                                    
                                    // Feedback progresivo y específico para la letra
                                    String feedbackMessage = _getSpecificFeedbackForLetter(widget.letter.toUpperCase(), failedAttempts);
                                    
                                    // Mostrar demostración automática después de 4 fallos
                                    if (failedAttempts >= 4) {
                                      Future.delayed(const Duration(seconds: 2), () {
                                        if (mounted) {
                                          _startDemo();
                                        }
                                      });
                                    }
                                    
                                    widget.audioService.speakText(feedbackMessage);
                                    
                                    // Limpiar trazos inválidos después de 3 segundos (más tiempo para ver el error)
                                    Future.delayed(const Duration(seconds: 3), () {
                                      if (mounted) {
                                        setState(() {
                                          _invalidStrokes.clear();
                                        });
                                      }
                                    });
                                  }
                                  
                                  _currentStroke = [];
                                }
                              });
                            },
                            child: CustomPaint(
                              painter: _TracingPainter(_strokes, _currentStroke, _invalidStrokes, widget.letter),
                              size: Size.infinite,
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
        const SizedBox(height: 20),
        // Botones de control
        // BOTONES RESPONSIVOS PARA MÓVIL Y WEB
        LayoutBuilder(
          builder: (context, constraints) {
            final isPhone = constraints.maxWidth < 600;
            final isSmallPhone = constraints.maxWidth < 400;
            
            // CONFIGURACIÓN RESPONSIVA
            final buttonPadding = isSmallPhone 
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                : (isPhone 
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                    : const EdgeInsets.symmetric(horizontal: 20, vertical: 16));
            
            final fontSize = isSmallPhone ? 12.0 : (isPhone ? 14.0 : 16.0);
            final iconSize = isSmallPhone ? 18.0 : (isPhone ? 20.0 : 24.0);
            
            // LAYOUT ADAPTATIVO
            if (isSmallPhone) {
              // COLUMNA PARA PANTALLAS MUY PEQUENAS
              return Column(
                children: [
                  _buildTracingButton('demo', buttonPadding, fontSize, iconSize),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTracingButton('clear', buttonPadding, fontSize, iconSize),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTracingButton('complete', buttonPadding, fontSize, iconSize),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // FILA PARA PANTALLAS NORMALES Y GRANDES
              return Row(
                children: [
                  Expanded(
                    child: _buildTracingButton('demo', buttonPadding, fontSize, iconSize),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTracingButton('clear', buttonPadding, fontSize, iconSize),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTracingButton('complete', buttonPadding, fontSize, iconSize),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // MÉTODO HELPER PARA CREAR BOTONES RESPONSIVOS
  Widget _buildTracingButton(String type, EdgeInsets padding, double fontSize, double iconSize) {
    switch (type) {
      case 'demo':
        return ElevatedButton.icon(
          onPressed: _startDemo,
          icon: Icon(Icons.play_arrow, size: iconSize),
          label: Text('Ver cómo', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: padding,
            elevation: 8,
          ),
        );
      case 'clear':
        return ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _strokes.clear();
              _invalidStrokes.clear();
              _currentStroke.clear();
              _hasTraced = false;
              _validStrokes = 0;
            });
          },
          icon: Icon(Icons.clear, size: iconSize),
          label: Text('Limpiar', style: TextStyle(fontSize: fontSize)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
            padding: padding,
          ),
        );
      case 'complete':
        return ElevatedButton.icon(
          onPressed: _isTracingValid() ? () {
            widget.onCelebrationStars();
            widget.audioService.speakText('¡Perfecto! Has completado el trazado de la letra ${widget.letter}');
            widget.onTracingComplete();
            setState(() {
              _strokes.clear();
              _currentStroke.clear();
              _invalidStrokes.clear();
              _hasTraced = false;
              _validStrokes = 0;
            });
          } : null,
          icon: Icon(Icons.check_circle, size: iconSize),
          label: Text(
            _isTracingValid() ? '¡Terminé!' : _getHintText(),
            style: TextStyle(fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTracingValid() ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            padding: padding,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _validateStroke(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // VALIDACIÓN ESPECÍFICA POR LETRA
    if (stroke.length < 5) return false; // Mínimo 5 puntos para evitar clicks accidentales
    
    // Primero verificar que no sea un garabato excesivo
    if (_isExcessiveScribbling(stroke)) {
      return false;
    }
    
    // Calcular longitud total del trazo
    double totalLength = 0;
    for (int i = 1; i < stroke.length; i++) {
      totalLength += (stroke[i] - stroke[i-1]).distance;
    }
    
    // Longitud mínima básica
    final minLength = math.min(canvasWidth, canvasHeight) * 0.08;
    if (totalLength < minLength) return false;
    
    // Verificar cobertura mínima
    if (!_hasReasonableCoverage(stroke, canvasWidth, canvasHeight)) return false;
    
    // VALIDACIÓN ESPECÍFICA POR LETRA - ESTO ES LO IMPORTANTE
    return _validateSpecificLetterShape(stroke, widget.letter.toUpperCase(), canvasWidth, canvasHeight);
  }
  
  // Nueva función para validar cobertura mínima del área
  bool _hasReasonableCoverage(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    if (stroke.isEmpty) return false;
    
    // Calcular bounding box del trazo
    double minX = stroke.first.dx, maxX = stroke.first.dx;
    double minY = stroke.first.dy, maxY = stroke.first.dy;
    
    for (final point in stroke) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }
    
    // El trazo debe cubrir al menos 5% del ancho O alto del canvas
    final widthCoverage = (maxX - minX) / canvasWidth;
    final heightCoverage = (maxY - minY) / canvasHeight;
    
    return widthCoverage > 0.05 || heightCoverage > 0.05;
  }
  
  // Función mejorada para detectar garabatos excesivos
  bool _isExcessiveScribbling(List<Offset> stroke) {
    if (stroke.length < 8) return false; // Reducido de 10 a 8
    
    int sharpTurns = 0;
    int backAndForth = 0;
    
    for (int i = 2; i < stroke.length; i++) {
      final vec1 = stroke[i-1] - stroke[i-2];
      final vec2 = stroke[i] - stroke[i-1];
      
      if (vec1.distance > 0 && vec2.distance > 0) {
        final dot = vec1.dx * vec2.dx + vec1.dy * vec2.dy;
        final cosAngle = dot / (vec1.distance * vec2.distance);
        
        // Detectar cambios de dirección bruscos (más de 120 grados)
        if (cosAngle < -0.5) {
          sharpTurns++;
        }
        
        // Detectar movimientos de ida y vuelta (más de 160 grados)
        if (cosAngle < -0.9) {
          backAndForth++;
        }
      }
    }
    
    // Es garabato si:
    // 1. Más del 12% son cambios muy bruscos (reducido del 20%)
    // 2. O hay muchos movimientos de ida y vuelta (más del 8%)
    // 3. O la relación longitud/cobertura es muy alta (líneas muy zigzag)
    final sharpRatio = sharpTurns / stroke.length;
    final backForthRatio = backAndForth / stroke.length;
    
    return sharpRatio > 0.12 || backForthRatio > 0.08 || _hasExcessiveZigzag(stroke);
  }
  
  // Nueva función para detectar zigzag excesivo
  bool _hasExcessiveZigzag(List<Offset> stroke) {
    if (stroke.length < 6) return false;
    
    // Calcular la longitud total del trazo
    double totalLength = 0;
    for (int i = 1; i < stroke.length; i++) {
      totalLength += (stroke[i] - stroke[i-1]).distance;
    }
    
    // Calcular la distancia directa entre inicio y fin
    final directDistance = (stroke.last - stroke.first).distance;
    
    // Si la longitud del trazo es más de 4 veces la distancia directa, es zigzag
    return directDistance > 0 && totalLength / directDistance > 4.0;
  }

  // FUNCIÓN PRINCIPAL DE VALIDACIÓN POR LETRA
  bool _validateSpecificLetterShape(List<Offset> stroke, String letter, double canvasWidth, double canvasHeight) {
    // SISTEMA SIMPLE: Si el trazo tiene buen tamaño y no es garabato, es válido
    if (stroke.length < 5) return false;
    
    // Verificar que cubra área mínima
    if (!_hasReasonableCoverage(stroke, canvasWidth, canvasHeight)) return false;
    
    // Verificar que no sea garabato excesivo
    if (_isExcessiveScribbling(stroke)) return false;
    
    // VALIDACIÓN ESPECÍFICA SIMPLE POR LETRA
    switch (letter.toUpperCase()) {
      case 'A':
        return _validateSimpleA(stroke, canvasWidth, canvasHeight);
      case 'B':
        return _validateSimpleB(stroke, canvasWidth, canvasHeight);
      case 'C':
        return _validateSimpleC(stroke, canvasWidth, canvasHeight);
      case 'D':
        return _validateSimpleD(stroke, canvasWidth, canvasHeight);
      case 'E':
        return _validateSimpleE(stroke, canvasWidth, canvasHeight);
      case 'F':
        return _validateSimpleF(stroke, canvasWidth, canvasHeight);
      case 'G':
        return _validateSimpleG(stroke, canvasWidth, canvasHeight);
      case 'H':
        return _validateSimpleH(stroke, canvasWidth, canvasHeight);
      case 'I':
        return _validateSimpleI(stroke, canvasWidth, canvasHeight);
      case 'J':
        return _validateSimpleJ(stroke, canvasWidth, canvasHeight);
      case 'K':
        return _validateSimpleK(stroke, canvasWidth, canvasHeight);
      case 'L':
        return _validateSimpleL(stroke, canvasWidth, canvasHeight);
      case 'M':
        return _validateSimpleM(stroke, canvasWidth, canvasHeight);
      case 'N':
        return _validateSimpleN(stroke, canvasWidth, canvasHeight);
      case '\u00D1':
        return _validateSimpleN(stroke, canvasWidth, canvasHeight); // Igual que N
      case 'O':
        return _validateSimpleO(stroke, canvasWidth, canvasHeight);
      case 'P':
        return _validateSimpleP(stroke, canvasWidth, canvasHeight);
      case 'Q':
        return _validateSimpleQ(stroke, canvasWidth, canvasHeight);
      case 'R':
        return _validateSimpleR(stroke, canvasWidth, canvasHeight);
      case 'S':
        return _validateSimpleS(stroke, canvasWidth, canvasHeight);
      case 'T':
        return _validateSimpleT(stroke, canvasWidth, canvasHeight);
      case 'U':
        return _validateSimpleU(stroke, canvasWidth, canvasHeight);
      case 'V':
        return _validateSimpleV(stroke, canvasWidth, canvasHeight);
      case 'W':
        return _validateSimpleW(stroke, canvasWidth, canvasHeight);
      case 'X':
        return _validateSimpleX(stroke, canvasWidth, canvasHeight);
      case 'Y':
        return _validateSimpleY(stroke, canvasWidth, canvasHeight);
      case 'Z':
        return _validateSimpleZ(stroke, canvasWidth, canvasHeight);
      default:
        return true; // Aceptar cualquier trazo decente por defecto
    }
  }
  
  // FUNCIONES SIMPLES DE VALIDACIÓN PARA LAS 27 LETRAS
  
  bool _validateSimpleA(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // A: Debe coincidir con la demostración - línea diagonal izquierda, derecha, o barra horizontal
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Normalizar posiciones
    final startX = start.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endX = end.dx / canvasWidth;
    final endY = end.dy / canvasHeight;
    
    // TRAZO 1: Línea diagonal izquierda (centro-arriba hacia izquierda-abajo)
    final isLeftDiagonal = (startY < 0.4 && endY > 0.6) && (startX > 0.4 && endX < 0.4);
    
    // TRAZO 2: Línea diagonal derecha (centro-arriba hacia derecha-abajo)  
    final isRightDiagonal = (startY < 0.4 && endY > 0.6) && (startX < 0.6 && endX > 0.6);
    
    // TRAZO 3: Barra horizontal del medio
    final isHorizontalBar = (startY > 0.4 && startY < 0.7) && (endY > 0.4 && endY < 0.7) && 
                            (endX - startX).abs() > 0.2;
    
    return isLeftDiagonal || isRightDiagonal || isHorizontalBar;
  }
  
  bool _validateSimpleB(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // B: Línea vertical izquierda o curvas semicirculares derecha
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLine = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Curva superior o inferior
    final isCurve = (startX < 0.5 && endX > 0.5) || _hasSignificantCurvature(stroke);
    
    return isVerticalLine || isCurve;
  }
  
  bool _validateSimpleC(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // C: Debe ser una curva abierta (como un círculo incompleto)
    if (stroke.length < 5) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Verificar que NO sea un círculo cerrado (start y end diferentes)
    final distance = math.sqrt(math.pow(end.dx - start.dx, 2) + math.pow(end.dy - start.dy, 2));
    final isOpen = distance > canvasWidth * 0.1; // 10% del ancho
    
    // Debe tener algo de curvatura
    double totalCurvature = 0;
    for (int i = 1; i < stroke.length - 1; i++) {
      final prev = stroke[i-1];
      final curr = stroke[i];
      final next = stroke[i+1];
      
      final angle1 = math.atan2(curr.dy - prev.dy, curr.dx - prev.dx);
      final angle2 = math.atan2(next.dy - curr.dy, next.dx - curr.dx);
      totalCurvature += (angle2 - angle1).abs();
    }
    
    return isOpen && totalCurvature > 1.5; // Curva abierta
  }
  
  bool _validateSimpleD(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // D: Línea vertical o curva semicircular
    return _hasReasonableCoverage(stroke, canvasWidth, canvasHeight);
  }
  
  bool _validateSimpleE(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // E: Línea vertical izquierda o líneas horizontales
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLine = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Líneas horizontales (arriba, medio, abajo)
    final isHorizontalLine = (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.2;
    
    return isVerticalLine || isHorizontalLine;
  }
  
  bool _validateSimpleF(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // F: Línea vertical izquierda o líneas horizontales (similar a E pero sin línea de abajo)
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLine = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Líneas horizontales (arriba, medio - NO abajo para F)
    final isHorizontalLine = (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.2;
    
    return isVerticalLine || isHorizontalLine;
  }
  
  bool _validateSimpleG(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // G: Curva como C pero con línea horizontal en el medio derecho
    if (stroke.length < 5) return false;
    
    // Similar a C (curva abierta) o línea horizontal en la derecha
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea horizontal en la derecha (parte distintiva de G)
    final isRightHorizontal = (startX > 0.5 && endX > 0.5) && (startY - endY).abs() < 0.2;
    
    // O curva general
    final isCurve = _hasSignificantCurvature(stroke);
    
    return isRightHorizontal || isCurve;
  }
  
  bool _validateSimpleH(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // H: Dos líneas verticales o línea horizontal del medio
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda o derecha
    final isLeftVertical = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    final isRightVertical = (startX > 0.6 && endX > 0.6) && (endY - startY).abs() > 0.3;
    
    // Línea horizontal del medio
    final isHorizontalMiddle = (startY > 0.4 && startY < 0.6) && (endY > 0.4 && endY < 0.6) && (endX - startX).abs() > 0.2;
    
    return isLeftVertical || isRightVertical || isHorizontalMiddle;
  }
  
  bool _validateSimpleI(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // I: Debe ser una línea vertical o un punto
    if (stroke.length < 2) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Línea vertical: X no cambia mucho, Y sí
    final horizontalChange = (end.dx - start.dx).abs();
    final verticalChange = (end.dy - start.dy).abs();
    
    // Es vertical si el cambio vertical es mayor al horizontal
    return verticalChange > horizontalChange || stroke.length < 5; // Permitir puntos pequeños
  }
  
  bool _validateSimpleJ(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // J: Línea vertical hacia abajo con curva hacia la izquierda al final
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical hacia abajo
    final isVerticalDown = (endY > startY + 0.3) && (startX - endX).abs() < 0.3;
    
    // Curva hacia la izquierda (final de J)
    final isCurveLeft = (endX < startX - 0.1) && _hasSignificantCurvature(stroke);
    
    return isVerticalDown || isCurveLeft;
  }
  
  bool _validateSimpleK(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // K: Línea vertical izquierda o líneas diagonales desde el centro
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLeft = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Línea diagonal superior (centro hacia arriba-derecha)
    final isUpperDiagonal = (startY > endY) && (endX > startX + 0.2);
    
    // Línea diagonal inferior (centro hacia abajo-derecha)
    final isLowerDiagonal = (startY < endY) && (endX > startX + 0.2);
    
    return isVerticalLeft || isUpperDiagonal || isLowerDiagonal;
  }
  
  bool _validateSimpleL(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // L: Debe ser Línea vertical hacia abajo O horizontal hacia derecha
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    final horizontalChange = (end.dx - start.dx).abs();
    final verticalChange = (end.dy - start.dy).abs();
    
    // Es vertical (parte principal de L) o horizontal (parte de abajo)
    return verticalChange > horizontalChange * 0.5 || horizontalChange > verticalChange * 0.5;
  }
  
  bool _validateSimpleM(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // M: Líneas verticales (izq/der) o líneas en pico (centro)
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Líneas verticales izquierda o derecha
    final isLeftVertical = (startX < 0.3 && endX < 0.3) && (endY - startY).abs() > 0.3;
    final isRightVertical = (startX > 0.7 && endX > 0.7) && (endY - startY).abs() > 0.3;
    
    // Líneas del pico (van hacia el centro)
    final isLeftPeak = (startY > 0.6) && (endY < 0.4) && (endX > startX + 0.1);
    final isRightPeak = (startY > 0.6) && (endY < 0.4) && (endX < startX - 0.1);
    
    return isLeftVertical || isRightVertical || isLeftPeak || isRightPeak;
  }
  
  bool _validateSimpleN(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // N: Líneas verticales (izq/der) o diagonal del medio
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Líneas verticales izquierda o derecha
    final isLeftVertical = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    final isRightVertical = (startX > 0.6 && endX > 0.6) && (endY - startY).abs() > 0.3;
    
    // Diagonal del medio (de izquierda-abajo a derecha-arriba)
    final isMiddleDiagonal = (startX < endX - 0.2) && (startY > endY + 0.2);
    
    return isLeftVertical || isRightVertical || isMiddleDiagonal;
  }
  
  bool _validateSimpleO(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // O: Debe ser una curva que forme un círculo o óvalo
    if (stroke.length < 8) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Verificar que sea curvo (no una línea recta)
    double totalCurvature = 0;
    for (int i = 1; i < stroke.length - 1; i++) {
      final prev = stroke[i-1];
      final curr = stroke[i];
      final next = stroke[i+1];
      
      // Calcular ángulo de curvatura
      final angle1 = math.atan2(curr.dy - prev.dy, curr.dx - prev.dx);
      final angle2 = math.atan2(next.dy - curr.dy, next.dx - curr.dx);
      totalCurvature += (angle2 - angle1).abs();
    }
    
    // Debe tener curvatura significativa para ser O
    return totalCurvature > 3.0; // Aproximadamente un círculo
  }
  
  bool _validateSimpleP(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // P: Línea vertical izquierda o curva superior derecha
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLeft = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Curva superior derecha (parte distintiva de P)
    final isUpperCurve = (startY < 0.6) && (endX > startX + 0.1) && _hasSignificantCurvature(stroke);
    
    // Línea horizontal superior
    final isTopHorizontal = (startY < 0.4) && (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.2;
    
    // Línea horizontal media
    final isMiddleHorizontal = (startY > 0.4 && startY < 0.6) && (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.2;
    
    return isVerticalLeft || isUpperCurve || isTopHorizontal || isMiddleHorizontal;
  }
  
  bool _validateSimpleQ(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // Q: Círculo como O + línea diagonal en la parte inferior derecha
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Círculo (curvatura significativa)
    final isCircle = _hasSignificantCurvature(stroke) && stroke.length > 8;
    
    // Línea diagonal en la parte inferior derecha (cola de Q)
    final isTail = (startX > 0.4 && startY > 0.4) && (endX > startX + 0.1) && (endY > startY + 0.1);
    
    return isCircle || isTail;
  }
  
  bool _validateSimpleR(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // R: Similar a P pero con línea diagonal inferior derecha
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea vertical izquierda
    final isVerticalLeft = (startX < 0.4 && endX < 0.4) && (endY - startY).abs() > 0.3;
    
    // Curva superior derecha (como P)
    final isUpperCurve = (startY < 0.6) && (endX > startX + 0.1) && _hasSignificantCurvature(stroke);
    
    // Línea diagonal inferior (distintiva de R)
    final isLowerDiagonal = (startY > 0.4) && (endY > startY + 0.1) && (endX > startX + 0.2);
    
    return isVerticalLeft || isUpperCurve || isLowerDiagonal;
  }
  
  bool _validateSimpleS(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // S: Curva en forma de S (cambio de dirección)
    if (stroke.length < 8) return false;
    
    // Verificar que tenga curvatura significativa y cambios de dirección
    bool hasDirectionChange = false;
    
    for (int i = 2; i < stroke.length - 2; i++) {
      final prev = stroke[i-2];
      final curr = stroke[i];
      final next = stroke[i+2];
      
      final slope1 = (curr.dy - prev.dy) / (curr.dx - prev.dx + 0.001);
      final slope2 = (next.dy - curr.dy) / (next.dx - curr.dx + 0.001);
      
      // Detectar cambio significativo en la pendiente (forma de S)
      if ((slope1 > 0 && slope2 < 0) || (slope1 < 0 && slope2 > 0)) {
        hasDirectionChange = true;
        break;
      }
    }
    
    return hasDirectionChange && _hasSignificantCurvature(stroke);
  }
  
  bool _validateSimpleT(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // T: Línea horizontal superior o línea vertical del centro
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea horizontal superior
    final isTopHorizontal = (startY < 0.4) && (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.3;
    
    // Línea vertical del centro
    final isCenterVertical = (startX > 0.4 && startX < 0.6) && (endX > 0.4 && endX < 0.6) && (endY - startY).abs() > 0.3;
    
    return isTopHorizontal || isCenterVertical;
  }
  
  bool _validateSimpleU(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // U: Curva en forma de U (abajo curvado, arriba abierto)
    if (stroke.length < 5) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Verificar que empiece y termine arriba (parte abierta de U)
    final startsHigh = startY < 0.6;
    final endsHigh = endY < 0.6;
    
    // Debe tener curvatura (la parte de abajo)
    final hasCurve = _hasSignificantCurvature(stroke);
    
    return (startsHigh || endsHigh) && hasCurve;
  }
  
  bool _validateSimpleV(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // V: Líneas diagonales que se juntan abajo
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea diagonal izquierda (arriba-izq a abajo-centro)
    final isLeftDiagonal = (startY < endY + 0.2) && (startX < 0.4) && (endX > 0.4);
    
    // Línea diagonal derecha (arriba-der a abajo-centro)
    final isRightDiagonal = (startY < endY + 0.2) && (startX > 0.6) && (endX < 0.6);
    
    return isLeftDiagonal || isRightDiagonal;
  }
  
  bool _validateSimpleW(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // W: Líneas en forma de W (como doble V)
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Cualquier línea diagonal (W tiene muchas diagonales)
    final isDiagonal = (endX - startX).abs() > 0.1 && (endY - startY).abs() > 0.1;
    
    return isDiagonal;
  }
  
  bool _validateSimpleX(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // X: Líneas diagonales cruzadas
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Diagonal de izquierda-arriba a derecha-abajo
    final isMainDiagonal = (startX < 0.4 && startY < 0.4) && (endX > 0.6 && endY > 0.6);
    
    // Diagonal de derecha-arriba a izquierda-abajo
    final isCounterDiagonal = (startX > 0.6 && startY < 0.4) && (endX < 0.4 && endY > 0.6);
    
    // Cualquier diagonal significativa
    final isDiagonal = (endX - startX).abs() > 0.3 && (endY - startY).abs() > 0.3;
    
    return isMainDiagonal || isCounterDiagonal || isDiagonal;
  }
  
  bool _validateSimpleY(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // Y: Líneas diagonales que se juntan en el centro, luego vertical
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea diagonal izquierda (arriba-izq hacia centro)
    final isLeftDiagonal = (startX < 0.4 && startY < 0.4) && (endX > 0.4 && endY > 0.4);
    
    // Línea diagonal derecha (arriba-der hacia centro)
    final isRightDiagonal = (startX > 0.6 && startY < 0.4) && (endX < 0.6 && endY > 0.4);
    
    // Línea vertical del centro hacia abajo
    final isCenterVertical = (startX > 0.4 && startX < 0.6) && (endY > startY + 0.2);
    
    return isLeftDiagonal || isRightDiagonal || isCenterVertical;
  }
  
  bool _validateSimpleZ(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    // Z: Línea horizontal arriba, diagonal, horizontal abajo
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    final startX = start.dx / canvasWidth;
    final endX = end.dx / canvasWidth;
    final startY = start.dy / canvasHeight;
    final endY = end.dy / canvasHeight;
    
    // Línea horizontal superior
    final isTopHorizontal = (startY < 0.4) && (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.3;
    
    // Línea diagonal principal (izquierda-arriba a derecha-abajo)
    final isMainDiagonal = (startX < endX - 0.2) && (startY < endY - 0.2);
    
    // Línea horizontal inferior
    final isBottomHorizontal = (startY > 0.6) && (startY - endY).abs() < 0.2 && (endX - startX).abs() > 0.3;
    
    return isTopHorizontal || isMainDiagonal || isBottomHorizontal;
  }

  // Función auxiliar para detectar curvatura significativa
  bool _hasSignificantCurvature(List<Offset> stroke) {
    if (stroke.length < 5) return false;
    
    double totalCurvature = 0;
    for (int i = 1; i < stroke.length - 1; i++) {
      final prev = stroke[i-1];
      final curr = stroke[i];
      final next = stroke[i+1];
      
      final angle1 = math.atan2(curr.dy - prev.dy, curr.dx - prev.dx);
      final angle2 = math.atan2(next.dy - curr.dy, next.dx - curr.dx);
      totalCurvature += (angle2 - angle1).abs();
    }
    
    return totalCurvature > 1.0; // Curvatura mínima requerida
  }

  // Normalizar trazo a coordenadas 0-1
  List<Offset> _normalizeStroke(List<Offset> stroke, double canvasWidth, double canvasHeight) {
    if (stroke.isEmpty) return [];
    
    final bounds = _getStrokeBounds(stroke);
    if (bounds.width == 0 || bounds.height == 0) return stroke;
    
    return stroke.map((point) => Offset(
      (point.dx - bounds.left) / bounds.width,
      (point.dy - bounds.top) / bounds.height,
    )).toList();
  }
  
  // VALIDACIÓN ESTRICTA Y ESPECÍFICA PARA LA LETRA A
  bool _validateLetterA(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 8) return false;
    
    // La letra A tiene características muy específicas que debemos validar:
    // 1. Dos líneas diagonales que se encuentran en la parte superior
    // 2. O una línea horizontal que conecta las diagonales en el medio
    // 3. La forma general debe parecer una "A" o parte de una "A"
    
    final start = normalizedStroke.first;
    final end = normalizedStroke.last;
    
    // VALIDACIÓN 1: ¿Es la línea diagonal izquierda de la A?
    if (_isLeftDiagonalOfA(normalizedStroke)) {
      return true;
    }
    
    // VALIDACIÓN 2: ¿Es la línea diagonal derecha de la A?
    if (_isRightDiagonalOfA(normalizedStroke)) {
      return true;
    }
    
    // VALIDACIÓN 3: ¿Es la barra horizontal de la A?
    if (_isHorizontalBarOfA(normalizedStroke)) {
      return true;
    }
    
    // VALIDACIÓN 4: ¿Es una A completa en un solo trazo (forma de V invertida)?
    if (_isCompleteAStroke(normalizedStroke)) {
      return true;
    }
    
    // Si no cumple con ninguna característica específica de la A, es inválido
    return false;
  }
  
  // FUNCIONES ESPECÍFICAS PARA VALIDAR PARTES DE LA LETRA A
  
  // Validar si es la diagonal izquierda de la A (de abajo-izquierda hacia arriba-centro)
  bool _isLeftDiagonalOfA(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de abajo-izquierda hacia arriba-centro
    bool startsBottomLeft = start.dy > 0.6 && start.dx < 0.4;  // Empieza abajo e izquierda
    bool endsTopCenter = end.dy < 0.3 && end.dx > 0.3 && end.dx < 0.7;  // Termina arriba y centro
    
    // Verificar que la pendiente sea correcta (diagonal ascendente hacia la derecha)
    bool correctSlope = (end.dx - start.dx) > 0.2 && (start.dy - end.dy) > 0.3;
    
    // Verificar que sea razonablemente recto (no muy zigzag)
    bool isStraightish = _isReasonablyStraight(stroke);
    
    return startsBottomLeft && endsTopCenter && correctSlope && isStraightish;
  }
  
  // Validar si es la diagonal derecha de la A (de arriba-centro hacia abajo-derecha)
  bool _isRightDiagonalOfA(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-centro hacia abajo-derecha
    bool startsTopCenter = start.dy < 0.3 && start.dx > 0.3 && start.dx < 0.7;  // Empieza arriba y centro
    bool endsBottomRight = end.dy > 0.6 && end.dx > 0.6;  // Termina abajo y derecha
    
    // Verificar que la pendiente sea correcta (diagonal descendente hacia la derecha)
    bool correctSlope = (end.dx - start.dx) > 0.2 && (end.dy - start.dy) > 0.3;
    
    // Verificar que sea razonablemente recto
    bool isStraightish = _isReasonablyStraight(stroke);
    
    return startsTopCenter && endsBottomRight && correctSlope && isStraightish;
  }
  
  // Validar si es la barra horizontal de la A (MÁS PERMISIVA)
  bool _isHorizontalBarOfA(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en la zona media (donde va la barra de la A) - más permisiva
    bool isInMiddleHeight = start.dy > 0.35 && start.dy < 0.85 && end.dy > 0.35 && end.dy < 0.85;
    
    // Debe ser principalmente horizontal - más permisivo
    bool isHorizontal = (end.dy - start.dy).abs() < 0.25;  // Mayor variación vertical permitida
    bool spansHorizontally = (end.dx - start.dx).abs() > 0.15;  // Menor extensión horizontal requerida
    
    // Debe estar en la zona central - más permisivo
    bool isInCenterArea = start.dx > 0.1 && start.dx < 0.9 && end.dx > 0.1 && end.dx < 0.9;
    
    // Verificar que sea razonablemente recto
    bool isStraightish = _isReasonablyStraight(stroke);
    
    return isInMiddleHeight && isHorizontal && spansHorizontally && isInCenterArea && isStraightish;
  }
  
  // Validar si es una A completa en un solo trazo (forma de V invertida o triangulo)
  bool _isCompleteAStroke(List<Offset> stroke) {
    if (stroke.length < 15) return false;  // Necesita más puntos para ser A completa
    
    // Encontrar el punto más alto (que sería la punta de la A)
    double minY = stroke.first.dy;
    int peakIndex = 0;
    
    for (int i = 1; i < stroke.length; i++) {
      if (stroke[i].dy < minY) {
        minY = stroke[i].dy;
        peakIndex = i;
      }
    }
    
    // El pico debe estar en el tercio superior
    bool peakIsHigh = minY < 0.3;
    
    // El pico debe estar en el centro horizontalmente
    bool peakIsCentered = stroke[peakIndex].dx > 0.3 && stroke[peakIndex].dx < 0.7;
    
    // Los extremos deben estar más abajo que el pico
    bool extremesAreLow = stroke.first.dy > minY + 0.3 && stroke.last.dy > minY + 0.3;
    
    // Debe parecer una V invertida o triangulo
    bool looksLikeInvertedV = _looksLikeInvertedV(stroke, peakIndex);
    
    return peakIsHigh && peakIsCentered && extremesAreLow && looksLikeInvertedV;
  }
  
  // Validar línea vertical izquierda de la H
  bool _isLeftVerticalOfH(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en la parte izquierda y ser vertical
    return start.dx < 0.4 && end.dx < 0.4 && _isVerticalStroke(stroke);
  }
  
  // Validar línea vertical derecha de la H
  bool _isRightVerticalOfH(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en la parte derecha y ser vertical
    return start.dx > 0.6 && end.dx > 0.6 && _isVerticalStroke(stroke);
  }
  
  // Validar línea horizontal del medio de la H
  bool _isHorizontalBarOfH(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en el medio verticalmente y ser horizontal
    final isInMiddleHeight = start.dy > 0.3 && start.dy < 0.7 && end.dy > 0.3 && end.dy < 0.7;
    final isHorizontal = _isHorizontalStroke(stroke);
    
    return isInMiddleHeight && isHorizontal;
  }
  
  // Validar trazo completo de H
  bool _isCompleteHStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Buscar patrón: vertical hacia abajo, horizontal hacia la derecha, vertical hacia arriba o abajo
    var hasVerticalStart = false;
    var hasHorizontalMiddle = false;
    var hasVerticalEnd = false;
    
    // Dividir el trazo en segmentos
    final third = stroke.length ~/ 3;
    
    if (third > 0) {
      final firstSegment = stroke.sublist(0, third);
      final middleSegment = stroke.sublist(third, third * 2);
      final lastSegment = stroke.sublist(third * 2);
      
      hasVerticalStart = _isVerticalStroke(firstSegment);
      hasHorizontalMiddle = _isHorizontalStroke(middleSegment);
      hasVerticalEnd = _isVerticalStroke(lastSegment);
    }
    
    return hasVerticalStart && hasHorizontalMiddle && hasVerticalEnd;
  }

  // Verificar si un trazo es razonablemente recto (no muy zigzag)
  bool _isReasonablyStraight(List<Offset> stroke) {
    if (stroke.length < 5) return true;
    
    // Calcular la distancia total del trazo vs la distancia directa
    double totalLength = 0;
    for (int i = 1; i < stroke.length; i++) {
      totalLength += (stroke[i] - stroke[i-1]).distance;
    }
    
    final directDistance = (stroke.last - stroke.first).distance;
    
    if (directDistance == 0) return false;
    
    // El ratio debe ser razonable para considerar que es "recto"
    final straightnessRatio = directDistance / totalLength;
    
    return straightnessRatio > 0.7;  // Al menos 70% de eficiencia en la línea
  }
  
  // Verificar si un trazo se ve como una V invertida
  bool _looksLikeInvertedV(List<Offset> stroke, int peakIndex) {
    if (peakIndex < 3 || peakIndex > stroke.length - 4) return false;
    
    // La parte izquierda debe ser aproximadamente recta hacia arriba
    final leftPart = stroke.sublist(0, peakIndex + 1);
    bool leftIsReasonable = _isReasonablyStraight(leftPart);
    
    // La parte derecha debe ser aproximadamente recta hacia abajo
    final rightPart = stroke.sublist(peakIndex);
    bool rightIsReasonable = _isReasonablyStraight(rightPart);
    
    return leftIsReasonable && rightIsReasonable;
  }
  
  // VALIDACIONES ESPECÍFICAS PARA TODAS LAS LETRAS DEL ABECEDARIO ARGENTINO
  
  // LETRA D - Semicírculo con línea vertical izquierda
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA D - Alfabeto Argentino
  bool _validateLetterD(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La D tiene: línea vertical izquierda + semicírculo derecho
    return _isLeftVerticalOfD(normalizedStroke) || 
           _isRightCurveOfD(normalizedStroke) ||
           _isCompleteDStroke(normalizedStroke);
  }
  
  // Validar línea vertical izquierda de la D
  bool _isLeftVerticalOfD(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en el lado izquierdo y ser vertical
    return start.dx < 0.3 && end.dx < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar semicírculo derecho de la D
  bool _isRightCurveOfD(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en la parte derecha y ser curvo
    return avgX > 0.4 && _isCurvedStroke(stroke) && _isLeftToRightCurve(stroke);
  }
  
  // Validar trazo completo de D
  bool _isCompleteDStroke(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // La D completa empieza y termina en el lado izquierdo
    return start.dx < 0.4 && end.dx < 0.4 && _isCurvedStroke(stroke);
  }
  
  // Verificar si es una curva que va de izquierda a derecha
  bool _isLeftToRightCurve(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    return start.dx < end.dx; // Termina más a la derecha que donde empieza
  }
  
  // LETRA E - Línea vertical izquierda y líneas horizontales (arriba, medio, abajo)
  bool _validateLetterE(List<Offset> stroke) {
    // Validar línea vertical izquierda
    if (_isLeftVerticalOfE(stroke)) return true;
    
    // Validar línea horizontal superior
    if (_isTopHorizontalOfE(stroke)) return true;
    
    // Validar línea horizontal del medio
    if (_isMiddleHorizontalOfE(stroke)) return true;
    
    // Validar línea horizontal inferior
    if (_isBottomHorizontalOfE(stroke)) return true;
    
    return false;
  }
  
  // Validar línea vertical izquierda de la E
  bool _isLeftVerticalOfE(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.4 && _isVerticalStroke(stroke);
  }
  
  // Validar línea horizontal superior de la E
  bool _isTopHorizontalOfE(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY < 0.3 && _isHorizontalStroke(stroke);
  }
  
  // Validar línea horizontal del medio de la E
  bool _isMiddleHorizontalOfE(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY > 0.4 && avgY < 0.6 && _isHorizontalStroke(stroke);
  }
  
  // Validar línea horizontal inferior de la E
  bool _isBottomHorizontalOfE(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY > 0.7 && _isHorizontalStroke(stroke);
  }
  
  // LETRA F - Línea vertical izquierda y líneas horizontales (arriba y medio solamente)
  bool _validateLetterF(List<Offset> stroke) {
    // Validar línea vertical izquierda
    if (_isLeftVerticalOfF(stroke)) return true;
    
    // Validar línea horizontal superior
    if (_isTopHorizontalOfF(stroke)) return true;
    
    // Validar línea horizontal del medio
    if (_isMiddleHorizontalOfF(stroke)) return true;
    
    return false;
  }
  
  // Validar línea vertical izquierda de la F
  bool _isLeftVerticalOfF(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.4 && _isVerticalStroke(stroke);
  }
  
  // Validar línea horizontal superior de la F
  bool _isTopHorizontalOfF(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY < 0.3 && _isHorizontalStroke(stroke);
  }
  
  // Validar línea horizontal del medio de la F
  bool _isMiddleHorizontalOfF(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY > 0.4 && avgY < 0.6 && _isHorizontalStroke(stroke);
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA G - Alfabeto Argentino
  bool _validateLetterG(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La G es como una C pero con barra horizontal interior
    return _isOpenCircularStroke(normalizedStroke) ||
           _isHorizontalBarOfG(normalizedStroke) ||
           _isCompleteGStroke(normalizedStroke);
  }
  
  // Validar barra horizontal interior de la G
  bool _isHorizontalBarOfG(List<Offset> stroke) {
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en el lado derecho, en el medio verticalmente, y ser horizontal
    return avgX > 0.5 && avgY > 0.4 && avgY < 0.6 && _isHorizontalStroke(stroke);
  }
  
  // Validar trazo completo de G
  bool _isCompleteGStroke(List<Offset> stroke) {
    // Una G completa es como una C que termina con una línea horizontal hacia adentro
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ser principalmente circular pero terminar hacia la izquierda
    return _isCurvedStroke(stroke) && start.dx > end.dx && _isOpenCircularStroke(stroke);
  }
  
  // LETRA H - Dos líneas verticales y una horizontal en el medio
  bool _validateLetterH(List<Offset> stroke) {
    // Validar línea vertical izquierda
    if (_isLeftVerticalOfH(stroke)) return true;
    
    // Validar línea vertical derecha
    if (_isRightVerticalOfH(stroke)) return true;
    
    // Validar línea horizontal del medio
    if (_isHorizontalBarOfH(stroke)) return true;
    
    // Validar trazo completo de H
    if (_isCompleteHStroke(stroke)) return true;
    
    // Validaciones generales como respaldo
    return _isVerticalStroke(stroke) || _isHorizontalStroke(stroke);
  }
  
  // LETRA I - Simplificada: línea vertical y punto (como alfabeto argentino)
  bool _validateLetterI(List<Offset> stroke) {
    // En el alfabeto argentino, la I es solo una línea vertical y un punto
    // Validar línea vertical (la parte principal)
    if (_isVerticalStroke(stroke)) return true;
    
    // Validar punto (trazo muy pequeño)
    if (_isSmallDot(stroke)) return true;
    
    return false;
  }
  
  // Validar línea horizontal superior de la I
  bool _isTopHorizontalOfI(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY < 0.3 && _isHorizontalStroke(stroke);
  }
  
  // Validar línea horizontal inferior de la I
  bool _isBottomHorizontalOfI(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY > 0.7 && _isHorizontalStroke(stroke);
  }
  
  // LETRA J - Línea vertical curvada hacia la izquierda abajo
  bool _validateLetterJ(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe empezar arriba y curvarse hacia la izquierda
    bool startsHigh = start.dy < 0.4;
    bool endsLow = end.dy > 0.6;
    bool curvesLeft = end.dx < start.dx - 0.1;
    
    return (startsHigh && endsLow) || curvesLeft || _isCurvedStroke(stroke);
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA K - Alfabeto Argentino
  bool _validateLetterK(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La K tiene: línea vertical izquierda + diagonal superior + diagonal inferior
    return _isLeftVerticalOfK(normalizedStroke) ||
           _isUpperDiagonalOfK(normalizedStroke) ||
           _isLowerDiagonalOfK(normalizedStroke) ||
           _isCompleteKStroke(normalizedStroke);
  }
  
  // Validar línea vertical izquierda de la K
  bool _isLeftVerticalOfK(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en el lado izquierdo y ser vertical
    return start.dx < 0.4 && end.dx < 0.4 && _isVerticalStroke(stroke);
  }
  
  // Validar diagonal superior de la K (desde centro-izquierda hacia arriba-derecha)
  bool _isUpperDiagonalOfK(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Va desde el centro-izquierdo hacia arriba-derecha
    return start.dx < 0.6 && start.dy > 0.4 &&
           end.dx > start.dx && end.dy < start.dy &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar diagonal inferior de la K (desde centro-izquierda hacia abajo-derecha)
  bool _isLowerDiagonalOfK(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Va desde el centro-izquierdo hacia abajo-derecha
    return start.dx < 0.6 && start.dy < 0.6 &&
           end.dx > start.dx && end.dy > start.dy &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar trazo completo de K
  bool _isCompleteKStroke(List<Offset> stroke) {
    // Una K completa tiene un punto de intersección en el medio-izquierda
    bool hasMiddlePoint = false;
    for (int i = 0; i < stroke.length; i++) {
      final point = stroke[i];
      if (point.dx < 0.6 && point.dy > 0.3 && point.dy < 0.7) {
        hasMiddlePoint = true;
        break;
      }
    }
    
    return hasMiddlePoint && _isDiagonalStroke(stroke);
  }
  
  // LETRA L - Línea vertical o línea horizontal inferior
  bool _validateLetterL(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Línea vertical (de arriba hacia abajo)
    if (_isVerticalStroke(stroke)) return true;
    
    // Línea horizontal en la parte inferior
    bool isBottomHorizontal = start.dy > 0.6 && end.dy > 0.6 && _isHorizontalStroke(stroke);
    
    return isBottomHorizontal;
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA M - Alfabeto Argentino
  bool _validateLetterM(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La M tiene: vertical izquierda + diagonal hacia centro + diagonal hacia derecha + vertical derecha
    return _isLeftVerticalOfM(normalizedStroke) ||
           _isRightVerticalOfM(normalizedStroke) ||
           _isLeftDiagonalOfM(normalizedStroke) ||
           _isRightDiagonalOfM(normalizedStroke) ||
           _isCompleteMStroke(normalizedStroke);
  }
  
  // Validar vertical izquierda de la M
  bool _isLeftVerticalOfM(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar vertical derecha de la M
  bool _isRightVerticalOfM(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX > 0.7 && _isVerticalStroke(stroke);
  }
  
  // Validar diagonal izquierda de la M (de arriba-izquierda hacia centro-abajo)
  bool _isLeftDiagonalOfM(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    return start.dx < 0.4 && start.dy < 0.4 &&
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.6 &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar diagonal derecha de la M (de centro-abajo hacia arriba-derecha)
  bool _isRightDiagonalOfM(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    return start.dx > 0.4 && start.dx < 0.6 && start.dy > 0.6 &&
           end.dx > 0.6 && end.dy < 0.4 &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar trazo completo de M
  bool _isCompleteMStroke(List<Offset> stroke) {
    // La M tiene dos picos - buscar el punto más bajo en el centro
    double minY = 1.0;
    int peakIndex = 0;
    
    for (int i = 0; i < stroke.length; i++) {
      if (stroke[i].dy > minY && stroke[i].dx > 0.3 && stroke[i].dx < 0.7) {
        minY = stroke[i].dy;
        peakIndex = i;
      }
    }
    
    return minY > 0.5 && _isDiagonalStroke(stroke); // Tiene valle en el centro
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA N - Alfabeto Argentino  
  bool _validateLetterN(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La N tiene: vertical izquierda + diagonal + vertical derecha
    return _isLeftVerticalOfN(normalizedStroke) ||
           _isRightVerticalOfN(normalizedStroke) ||
           _isDiagonalOfN(normalizedStroke) ||
           _isCompleteNStroke(normalizedStroke);
  }
  
  // Validar vertical izquierda de la N
  bool _isLeftVerticalOfN(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar vertical derecha de la N
  bool _isRightVerticalOfN(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX > 0.7 && _isVerticalStroke(stroke);
  }
  
  // Validar diagonal de la N (de abajo-izquierda a arriba-derecha)
  bool _isDiagonalOfN(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    return start.dx < 0.4 && start.dy > 0.6 &&
           end.dx > 0.6 && end.dy < 0.4 &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar trazo completo de N
  bool _isCompleteNStroke(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // La N va de abajo-izquierda a arriba-derecha principalmente
    return start.dx < end.dx && start.dy > end.dy && _isDiagonalStroke(stroke);
  }
  
  // LETRA N_TILDE - Como N pero con tilde encima
  bool _validateLetterEnye(List<Offset> stroke) {
    // Validar cualquier componente de la N
    if (_validateLetterN(stroke)) return true;
    
    // Validar la tilde (línea curva pequeña arriba)
    if (_isTildeOfEnye(stroke)) return true;
    
    return false;
  }
  
  // Validar la tilde de la N_TILDE
  bool _isTildeOfEnye(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    // La tilde debe estar en la parte superior
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar arriba y ser un trazo pequeño y curvo
    return avgY < 0.2 && stroke.length < 15 && _isCurvedStroke(stroke);
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA P - Alfabeto Argentino
  bool _validateLetterP(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La P tiene: línea vertical izquierda + semicírculo superior
    return _isLeftVerticalOfP(normalizedStroke) ||
           _isUpperCurveOfP(normalizedStroke) ||
           _isCompletePStroke(normalizedStroke);
  }
  
  // Validar línea vertical izquierda de la P
  bool _isLeftVerticalOfP(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar semicírculo superior de la P
  bool _isUpperCurveOfP(List<Offset> stroke) {
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en la parte superior derecha y ser curvo
    return avgY < 0.5 && avgX > 0.3 && _isCurvedStroke(stroke);
  }
  
  // Validar trazo completo de P
  bool _isCompletePStroke(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // La P empieza vertical y se curva en la parte superior
    return start.dx < 0.4 && _isCurvedStroke(stroke) && _hasUpperCurve(stroke);
  }
  
  // Verificar si tiene curva en la parte superior
  bool _hasUpperCurve(List<Offset> stroke) {
    int upperPoints = 0;
    for (final point in stroke) {
      if (point.dy < 0.5) upperPoints++;
    }
    return upperPoints > stroke.length * 0.3; // Al menos 30% en la parte superior
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA Q - Alfabeto Argentino
  bool _validateLetterQ(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La Q es un círculo + cola diagonal
    return _isCircularStroke(normalizedStroke) ||
           _isDiagonalTailOfQ(normalizedStroke) ||
           _isCompleteQStroke(normalizedStroke);
  }
  
  // Validar cola diagonal de la Q
  bool _isDiagonalTailOfQ(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // La cola va desde dentro del círculo hacia abajo-derecha
    return start.dx > 0.4 && start.dx < 0.6 && start.dy > 0.4 && start.dy < 0.6 &&
           end.dx > 0.6 && end.dy > 0.6 &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar trazo completo de Q
  bool _isCompleteQStroke(List<Offset> stroke) {
    // Una Q completa es principalmente circular con extensión diagonal
    return _isCircularStroke(stroke) && _hasBottomRightExtension(stroke);
  }
  
  // Verificar si tiene extensión hacia abajo-derecha
  bool _hasBottomRightExtension(List<Offset> stroke) {
    final maxX = stroke.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final maxY = stroke.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    
    return maxX > 0.7 && maxY > 0.7; // Se extiende hacia abajo-derecha
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA R - Alfabeto Argentino
  bool _validateLetterR(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La R es como P + diagonal inferior adicional
    return _isLeftVerticalOfR(normalizedStroke) ||
           _isUpperCurveOfR(normalizedStroke) ||
           _isLowerDiagonalOfR(normalizedStroke) ||
           _isCompleteRStroke(normalizedStroke);
  }
  
  // Validar línea vertical izquierda de la R (igual que P)
  bool _isLeftVerticalOfR(List<Offset> stroke) {
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar semicírculo superior de la R (igual que P)
  bool _isUpperCurveOfR(List<Offset> stroke) {
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    return avgY < 0.5 && avgX > 0.3 && _isCurvedStroke(stroke);
  }
  
  // Validar diagonal inferior de la R
  bool _isLowerDiagonalOfR(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Va desde el centro hacia abajo-derecha
    return start.dx < 0.6 && start.dy < 0.6 &&
           end.dx > 0.6 && end.dy > 0.6 &&
           _isDiagonalStroke(stroke);
  }
  
  // Validar trazo completo de R
  bool _isCompleteRStroke(List<Offset> stroke) {
    // La R tiene curva superior y extensión diagonal inferior
    return _isCurvedStroke(stroke) && _hasUpperCurve(stroke) && _hasBottomRightExtension(stroke);
  }
  
  // LETRA S - Curva en forma de S
  bool _validateLetterS(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // La S debe tener cambios de dirección graduales
    return _isCurvedStroke(stroke) && !_isCircularStroke(stroke);
  }
  
  // LETRA T - Línea vertical central y línea horizontal superior
  bool _validateLetterT(List<Offset> stroke) {
    // Validar línea vertical central
    if (_isCentralVerticalOfT(stroke)) return true;
    
    // Validar línea horizontal superior
    if (_isTopHorizontalOfT(stroke)) return true;
    
    // Validar trazo completo de T
    if (_isCompleteTStroke(stroke)) return true;
    
    return false;
  }
  
  // Validar línea vertical central de la T
  bool _isCentralVerticalOfT(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    return avgX > 0.4 && avgX < 0.6 && _isVerticalStroke(stroke);
  }
  
  // Validar línea horizontal superior de la T
  bool _isTopHorizontalOfT(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY < 0.3 && _isHorizontalStroke(stroke);
  }
  
  // Validar trazo completo de T
  bool _isCompleteTStroke(List<Offset> stroke) {
    if (stroke.length < 8) return false;
    
    // Buscar patrón: horizontal arriba, vertical hacia abajo
    final half = stroke.length ~/ 2;
    if (half > 0) {
      final firstHalf = stroke.sublist(0, half);
      final secondHalf = stroke.sublist(half);
      
      final firstIsHorizontal = _isHorizontalStroke(firstHalf);
      final secondIsVertical = _isVerticalStroke(secondHalf);
      
      return firstIsHorizontal && secondIsVertical;
    }
    
    return false;
  }
  
  // LETRA U - Curva tipo U
  bool _validateLetterU(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe empezar y terminar arriba, con curva abajo
    bool startsHigh = start.dy < 0.5;
    bool endsHigh = end.dy < 0.5;
    
    // Debe tener puntos en la parte inferior
    bool hasBottomPoints = stroke.any((p) => p.dy > 0.6);
    
    return (startsHigh && endsHigh && hasBottomPoints) || _isCurvedStroke(stroke);
  }
  
  // LETRA V - Dos líneas diagonales que se juntan abajo
  bool _validateLetterV(List<Offset> stroke) {
    // Validar diagonal izquierda de la V
    if (_isLeftDiagonalOfV(stroke)) return true;
    
    // Validar diagonal derecha de la V
    if (_isRightDiagonalOfV(stroke)) return true;
    
    // Validar trazo completo de V
    if (_isCompleteVStroke(stroke)) return true;
    
    // Validaciones generales como respaldo
    return _isVShapeStroke(stroke) || _isDiagonalStroke(stroke);
  }
  
  // Validar diagonal izquierda de la V
  bool _isLeftDiagonalOfV(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-izquierda hacia abajo-centro
    return start.dx < 0.4 && start.dy < 0.4 && 
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.7;
  }
  
  // Validar diagonal derecha de la V
  bool _isRightDiagonalOfV(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-derecha hacia abajo-centro
    return start.dx > 0.6 && start.dy < 0.4 && 
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.7;
  }
  
  // Validar trazo completo de V
  bool _isCompleteVStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Buscar punto más bajo (vértice de la V)
    double maxY = stroke.first.dy;
    int vertexIndex = 0;
    
    for (int i = 1; i < stroke.length; i++) {
      if (stroke[i].dy > maxY) {
        maxY = stroke[i].dy;
        vertexIndex = i;
      }
    }
    
    // El vértice debe estar en la parte inferior y centro
    return maxY > 0.7 && stroke[vertexIndex].dx > 0.4 && stroke[vertexIndex].dx < 0.6;
  }
  
  // LETRA W - Cuatro líneas diagonales que forman dos picos
  bool _validateLetterW(List<Offset> stroke) {
    // Validar cualquier diagonal de la W
    if (_isDiagonalOfW(stroke)) return true;
    
    // Validar trazo completo de W
    if (_isCompleteWStroke(stroke)) return true;
    
    // Validaciones generales como respaldo
    return _isDiagonalStroke(stroke) || _isVShapeStroke(stroke);
  }
  
  // Validar cualquier diagonal de la W
  bool _isDiagonalOfW(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    // La W acepta cualquier trazo diagonal bien formado
    return _isDiagonalStroke(stroke) && _isReasonablyStraight(stroke);
  }
  
  // Validar trazo completo de W
  bool _isCompleteWStroke(List<Offset> stroke) {
    if (stroke.length < 15) return false;
    
    // Buscar múltiples cambios de dirección característicos de la W
    var directionChanges = 0;
    var previousDirection = 0.0; // 1 = sube, -1 = baja
    
    for (int i = 1; i < stroke.length - 1; i++) {
      final currentDirection = stroke[i + 1].dy - stroke[i].dy;
      
      if ((previousDirection > 0 && currentDirection < 0) ||
          (previousDirection < 0 && currentDirection > 0)) {
        directionChanges++;
      }
      
      if (currentDirection != 0) previousDirection = currentDirection;
    }
    
    // La W debe tener al menos 2 cambios de dirección (para formar los picos)
    return directionChanges >= 2;
  }
  
  // LETRA X - Dos diagonales que se cruzan en el centro
  bool _validateLetterX(List<Offset> stroke) {
    // Validar diagonal principal (arriba-izquierda a abajo-derecha)
    if (_isMainDiagonalOfX(stroke)) return true;
    
    // Validar diagonal secundaria (arriba-derecha a abajo-izquierda)
    if (_isSecondaryDiagonalOfX(stroke)) return true;
    
    // Validar trazo completo de X
    if (_isCompleteXStroke(stroke)) return true;
    
    // Validación general como respaldo
    return _isDiagonalStroke(stroke);
  }
  
  // Validar diagonal principal de la X (/ invertida)
  bool _isMainDiagonalOfX(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-izquierda a abajo-derecha
    return start.dx < 0.4 && start.dy < 0.4 && 
           end.dx > 0.6 && end.dy > 0.6;
  }
  
  // Validar diagonal secundaria de la X (\)
  bool _isSecondaryDiagonalOfX(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-derecha a abajo-izquierda
    return start.dx > 0.6 && start.dy < 0.4 && 
           end.dx < 0.4 && end.dy > 0.6;
  }
  
  // Validar trazo completo de X
  bool _isCompleteXStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Buscar punto central donde se cruzan las diagonales
    final centerX = 0.5;
    final centerY = 0.5;
    
    var hasPointNearCenter = false;
    for (final point in stroke) {
      final distanceToCenter = ((point.dx - centerX) * (point.dx - centerX) + 
                               (point.dy - centerY) * (point.dy - centerY));
      if (distanceToCenter < 0.1) { // Cerca del centro
        hasPointNearCenter = true;
        break;
      }
    }
    
    return hasPointNearCenter && _isDiagonalStroke(stroke);
  }
  
  // LETRA Y - Dos diagonales que se juntan en el centro y línea vertical hacia abajo
  bool _validateLetterY(List<Offset> stroke) {
    // Validar diagonal izquierda de la Y
    if (_isLeftDiagonalOfY(stroke)) return true;
    
    // Validar diagonal derecha de la Y
    if (_isRightDiagonalOfY(stroke)) return true;
    
    // Validar línea vertical inferior de la Y
    if (_isVerticalBottomOfY(stroke)) return true;
    
    // Validar trazo completo de Y
    if (_isCompleteYStroke(stroke)) return true;
    
    // Validaciones generales como respaldo
    return _isDiagonalStroke(stroke) || _isVerticalStroke(stroke);
  }
  
  // Validar diagonal izquierda de la Y
  bool _isLeftDiagonalOfY(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-izquierda hacia centro
    return start.dx < 0.4 && start.dy < 0.4 && 
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.4 && end.dy < 0.6;
  }
  
  // Validar diagonal derecha de la Y
  bool _isRightDiagonalOfY(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-derecha hacia centro
    return start.dx > 0.6 && start.dy < 0.4 && 
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.4 && end.dy < 0.6;
  }
  
  // Validar línea vertical inferior de la Y
  bool _isVerticalBottomOfY(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir del centro hacia abajo
    return start.dx > 0.4 && start.dx < 0.6 && start.dy > 0.4 && start.dy < 0.6 &&
           end.dx > 0.4 && end.dx < 0.6 && end.dy > 0.7 && _isVerticalStroke(stroke);
  }
  
  // Validar trazo completo de Y
  bool _isCompleteYStroke(List<Offset> stroke) {
    if (stroke.length < 12) return false;
    
    // Buscar punto central donde se juntan las diagonales
    var hasCentralPoint = false;
    for (final point in stroke) {
      if (point.dx > 0.4 && point.dx < 0.6 && point.dy > 0.4 && point.dy < 0.6) {
        hasCentralPoint = true;
        break;
      }
    }
    
    return hasCentralPoint;
  }
  
  // LETRA Z - Línea horizontal arriba, diagonal medio, línea horizontal abajo
  bool _validateLetterZ(List<Offset> stroke) {
    // Validar línea horizontal superior
    if (_isTopHorizontalOfZ(stroke)) return true;
    
    // Validar línea diagonal del medio
    if (_isDiagonalMiddleOfZ(stroke)) return true;
    
    // Validar línea horizontal inferior
    if (_isBottomHorizontalOfZ(stroke)) return true;
    
    // Validar trazo completo de Z
    if (_isCompleteZStroke(stroke)) return true;
    
    return false;
  }
  
  // Validar línea horizontal superior de la Z
  bool _isTopHorizontalOfZ(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY < 0.3 && _isHorizontalStroke(stroke);
  }
  
  // Validar diagonal del medio de la Z
  bool _isDiagonalMiddleOfZ(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe ir de arriba-derecha a abajo-izquierda (diagonal \ )
    return start.dx > end.dx && start.dy < end.dy && _isDiagonalStroke(stroke);
  }
  
  // Validar línea horizontal inferior de la Z
  bool _isBottomHorizontalOfZ(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    return avgY > 0.7 && _isHorizontalStroke(stroke);
  }
  
  // Validar trazo completo de Z
  bool _isCompleteZStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Dividir trazo en tres segmentos
    final third = stroke.length ~/ 3;
    if (third > 0) {
      final firstSegment = stroke.sublist(0, third);
      final middleSegment = stroke.sublist(third, third * 2);
      final lastSegment = stroke.sublist(third * 2);
      
      final firstIsHorizontal = _isHorizontalStroke(firstSegment);
      final middleIsDiagonal = _isDiagonalStroke(middleSegment);
      final lastIsHorizontal = _isHorizontalStroke(lastSegment);
      
      return firstIsHorizontal && middleIsDiagonal && lastIsHorizontal;
    }
    
    return false;
  }
  
  // FUNCIÓN PARA DAR FEEDBACK ESPECÍFICO SEGÚN LA LETRA Y EL NÚMERO DE INTENTOS
  String _getSpecificFeedbackForLetter(String letter, int attempts) {
    switch (letter) {
      case 'A':
        return _getFeedbackForLetterA(attempts);
      case 'B':
        return _getFeedbackForLetterB(attempts);
      case 'C':
        return _getFeedbackForLetterC(attempts);
      case 'D':
        return _getFeedbackForLetterD(attempts);
      case 'E':
        return _getFeedbackForLetterE(attempts);
      case 'F':
        return _getFeedbackForLetterF(attempts);
      case 'G':
        return _getFeedbackForLetterG(attempts);
      case 'H':
        return _getFeedbackForLetterH(attempts);
      case 'I':
        return _getFeedbackForLetterI(attempts);
      case 'J':
        return _getFeedbackForLetterJ(attempts);
      case 'K':
        return _getFeedbackForLetterK(attempts);
      case 'L':
        return _getFeedbackForLetterL(attempts);
      case 'M':
        return _getFeedbackForLetterM(attempts);
      case 'N':
        return _getFeedbackForLetterN(attempts);
      case '\u00D1':
        return _getFeedbackForLetterN(attempts); // N_TILDE usa mismo feedback que N
      case 'O':
        return _getFeedbackForLetterO(attempts);
      case 'P':
        return _getFeedbackForLetterP(attempts);
      case 'Q':
        return _getFeedbackForLetterQ(attempts);
      case 'R':
        return _getFeedbackForLetterR(attempts);
      case 'S':
        return _getFeedbackForLetterS(attempts);
      case 'T':
        return _getFeedbackForLetterT(attempts);
      case 'U':
        return _getFeedbackForLetterU(attempts);
      case 'V':
        return _getFeedbackForLetterV(attempts);
      case 'W':
        return _getFeedbackForLetterW(attempts);
      case 'X':
        return _getFeedbackForLetterX(attempts);
      case 'Y':
        return _getFeedbackForLetterY(attempts);
      case 'Z':
        return _getFeedbackForLetterZ(attempts);
      default:
        return _getGenericFeedback(attempts);
    }
  }
  
  // Feedback específico para la letra A
  String _getFeedbackForLetterA(int attempts) {
    switch (attempts) {
      case 1:
        return 'Recuerda que la A tiene dos líneas diagonales que se juntan arriba, inténtalo de nuevo';
      case 2:
        return 'La letra A es como un triángulo sin la base. Prueba hacer una línea diagonal que vaya hacia arriba';
      case 3:
        return 'Para la A puedes hacer: una línea de abajo-izquierda hacia arriba-centro, o una línea de arriba-centro hacia abajo-derecha, o la barra horizontal del medio';
      case 4:
        return 'Voy a mostrarte cómo se hace la A. ¡Observa con atención!';
      default:
        return '¿Quieres ver la demostración de la A? Toca "Ver cómo"';
    }
  }
  
  // Feedback específico para la letra O
  String _getFeedbackForLetterO(int attempts) {
    switch (attempts) {
      case 1:
        return 'La O es un círculo. Intenta hacer un trazo redondo que empiece y termine en el mismo lugar';
      case 2:
        return 'Para la O, haz un círculo completo. Empieza por arriba y regresa al mismo punto';
      case 3:
        return 'La letra O debe ser redonda y cerrada. Intenta hacer un círculo más grande';
      default:
        return 'Te muestro cómo hacer la O. ¡Mira bien!';
    }
  }
  
  // Feedback específico para la letra B
  String _getFeedbackForLetterB(int attempts) {
    switch (attempts) {
      case 1:
        return 'La B tiene una línea vertical y curvas. Intenta hacer una línea recta hacia abajo';
      case 2:
        return 'Para la B, puedes hacer la línea vertical del lado izquierdo o una de las curvas de la derecha';
      case 3:
        return 'La letra B es como dos semicírculos unidos a una línea vertical';
      default:
        return 'Voy a enseñarte cómo se traza la B';
    }
  }
  
  // Feedback específico para la letra C
  String _getFeedbackForLetterC(int attempts) {
    switch (attempts) {
      case 1:
        return 'La C es como un círculo abierto. Haz una curva que no se cierre completamente';
      case 2:
        return 'Para la C, imagina una O pero déjala abierta del lado derecho';
      case 3:
        return 'La letra C es una curva que va de arriba-derecha, pasa por la izquierda, y baja a abajo-derecha';
      default:
        return 'Te enseño cómo hacer la C. ¡Observa!';
    }
  }

  // Feedback específico para la letra D
  String _getFeedbackForLetterD(int attempts) {
    switch (attempts) {
      case 1:
        return 'La D tiene una línea vertical y una curva. Intenta hacer una línea recta hacia abajo';
      case 2:
        return 'Para la D, puedes hacer la línea vertical del lado izquierdo o la curva de la derecha';
      case 3:
        return 'La letra D es como un semicírculo unido a una línea vertical';
      default:
        return 'Te muestro cómo hacer la D. ¡Mira!';
    }
  }

  // Feedback específico para la letra E
  String _getFeedbackForLetterE(int attempts) {
    switch (attempts) {
      case 1:
        return 'La E tiene líneas horizontales y una vertical. Intenta hacer una línea recta';
      case 2:
        return 'Para la E, puedes hacer la línea vertical o cualquiera de las tres líneas horizontales';
      case 3:
        return 'La letra E es como tres líneas horizontales conectadas a una línea vertical';
      default:
        return 'Voy a enseñarte cómo se hace la E';
    }
  }

  // Feedback específico para la letra F
  String _getFeedbackForLetterF(int attempts) {
    switch (attempts) {
      case 1:
        return 'La F es como una E pero sin la línea de abajo. Haz una línea vertical o horizontal';
      case 2:
        return 'Para la F, puedes hacer la línea vertical o las dos líneas horizontales de arriba';
      case 3:
        return 'La letra F tiene una línea vertical y dos horizontales arriba';
      default:
        return 'Te enseño cómo hacer la F. ¡Observa!';
    }
  }

  // Feedback específico para la letra G
  String _getFeedbackForLetterG(int attempts) {
    switch (attempts) {
      case 1:
        return 'La G es como una C pero con una línea horizontal adentro. Haz una curva';
      case 2:
        return 'Para la G, imagina una C y agrega una línea horizontal en el medio derecho';
      case 3:
        return 'La letra G es una curva que se abre hacia la derecha con una barra horizontal';
      default:
        return 'Voy a mostrarte cómo se hace la G';
    }
  }

  // Feedback específico para la letra H
  String _getFeedbackForLetterH(int attempts) {
    switch (attempts) {
      case 1:
        return 'La H tiene dos líneas verticales y una horizontal en el medio. Haz una línea recta';
      case 2:
        return 'Para la H, puedes hacer cualquiera de las dos líneas verticales o la línea horizontal del medio';
      case 3:
        return 'La letra H son dos líneas verticales conectadas por una horizontal en el centro';
      default:
        return 'Te muestro cómo hacer la H. ¡Mira bien!';
    }
  }

  // Feedback específico para la letra I
  String _getFeedbackForLetterI(int attempts) {
    switch (attempts) {
      case 1:
        return 'La I es una línea vertical con líneas horizontales arriba y abajo. Haz una línea recta';
      case 2:
        return 'Para la I, puedes hacer la línea vertical del centro o las líneas horizontales de arriba o abajo';
      case 3:
        return 'La letra I es como una columna con base y techo';
      default:
        return 'Voy a enseñarte cómo se traza la I';
    }
  }

  // Feedback específico para la letra J
  String _getFeedbackForLetterJ(int attempts) {
    switch (attempts) {
      case 1:
        return 'La J es como una línea que baja y se curva hacia la izquierda. Haz una curva';
      case 2:
        return 'Para la J, puedes hacer la parte vertical o la curva de abajo hacia la izquierda';
      case 3:
        return 'La letra J baja recta y luego se curva como un gancho hacia la izquierda';
      default:
        return 'Te enseño cómo hacer la J. ¡Observa!';
    }
  }

  // Feedback específico para la letra K
  String _getFeedbackForLetterK(int attempts) {
    switch (attempts) {
      case 1:
        return 'La K tiene una línea vertical y dos líneas diagonales. Haz una línea recta';
      case 2:
        return 'Para la K, puedes hacer la línea vertical o una de las líneas diagonales';
      case 3:
        return 'La letra K es una línea vertical con dos diagonales que se juntan en el medio';
      default:
        return 'Voy a mostrarte cómo se hace la K';
    }
  }

  // Feedback específico para la letra L
  String _getFeedbackForLetterL(int attempts) {
    switch (attempts) {
      case 1:
        return 'La L es simple: una línea vertical y una horizontal abajo. Haz una línea recta';
      case 2:
        return 'Para la L, puedes hacer la línea vertical o la línea horizontal de la base';
      case 3:
        return 'La letra L es como una esquina: línea vertical hacia abajo y horizontal hacia la derecha';
      default:
        return 'Te muestro cómo hacer la L. ¡Muy fácil!';
    }
  }

  // Feedback específico para la letra M
  String _getFeedbackForLetterM(int attempts) {
    switch (attempts) {
      case 1:
        return 'La M tiene dos líneas verticales y dos diagonales en el medio. Haz una línea recta';
      case 2:
        return 'Para la M, puedes hacer una línea vertical o una diagonal del medio';
      case 3:
        return 'La letra M son dos montañitas juntas: dos verticales con dos diagonales que se tocan arriba';
      default:
        return 'Voy a enseñarte cómo se traza la M';
    }
  }

  // Feedback específico para la letra N
  String _getFeedbackForLetterN(int attempts) {
    switch (attempts) {
      case 1:
        return 'La N tiene dos líneas verticales y una diagonal. Haz una línea recta';
      case 2:
        return 'Para la N, puedes hacer una línea vertical o la línea diagonal del medio';
      case 3:
        return 'La letra N son dos líneas verticales conectadas por una diagonal que sube';
      default:
        return 'Te enseño cómo hacer la N. ¡Observa!';
    }
  }

  // Feedback específico para la letra P
  String _getFeedbackForLetterP(int attempts) {
    switch (attempts) {
      case 1:
        return 'La P tiene una línea vertical y una curva arriba. Haz una línea recta hacia abajo';
      case 2:
        return 'Para la P, puedes hacer la línea vertical o la curva/línea horizontal de arriba';
      case 3:
        return 'La letra P es una línea vertical con un semicírculo o líneas horizontales arriba';
      default:
        return 'Voy a mostrarte cómo se hace la P';
    }
  }

  // Feedback específico para la letra Q
  String _getFeedbackForLetterQ(int attempts) {
    switch (attempts) {
      case 1:
        return 'La Q es como una O con una colita. Haz un círculo o una línea diagonal';
      case 2:
        return 'Para la Q, puedes hacer el círculo como la O o la línea diagonal que sale abajo';
      case 3:
        return 'La letra Q es un círculo con una línea diagonal que sale desde adentro hacia afuera';
      default:
        return 'Te muestro cómo hacer la Q. ¡Con su colita!';
    }
  }

  // Feedback específico para la letra R
  String _getFeedbackForLetterR(int attempts) {
    switch (attempts) {
      case 1:
        return 'La R es como una P con una línea diagonal abajo. Haz una línea recta';
      case 2:
        return 'Para la R, puedes hacer la línea vertical, la curva de arriba, o la diagonal de abajo';
      case 3:
        return 'La letra R es una línea vertical con una curva arriba y una diagonal hacia abajo-derecha';
      default:
        return 'Voy a enseñarte cómo se traza la R';
    }
  }

  // Feedback específico para la letra S
  String _getFeedbackForLetterS(int attempts) {
    switch (attempts) {
      case 1:
        return 'La S es como una serpiente curveada. Haz una curva suave';
      case 2:
        return 'Para la S, imagina una curva que va de arriba-derecha, al centro-izquierda, y a abajo-derecha';
      case 3:
        return 'La letra S es como dos C unidos: uno normal arriba y uno al revés abajo';
      default:
        return 'Te enseño cómo hacer la S. ¡Como una serpiente!';
    }
  }

  // Feedback específico para la letra T
  String _getFeedbackForLetterT(int attempts) {
    switch (attempts) {
      case 1:
        return 'La T es una línea horizontal arriba y una vertical abajo. Haz una línea recta';
      case 2:
        return 'Para la T, puedes hacer la línea horizontal de arriba o la línea vertical del centro';
      case 3:
        return 'La letra T es como un poste con un techo: línea horizontal arriba y vertical abajo';
      default:
        return 'Voy a mostrarte cómo se hace la T';
    }
  }

  // Feedback específico para la letra U
  String _getFeedbackForLetterU(int attempts) {
    switch (attempts) {
      case 1:
        return 'La U es como una curva que sube por los lados. Haz una curva suave';
      case 2:
        return 'Para la U, imagina un recipiente: curva abajo que sube por los dos lados';
      case 3:
        return 'La letra U es una curva que empieza arriba-izquierda, baja, y sube a arriba-derecha';
      default:
        return 'Te muestro cómo hacer la U. ¡Como un recipiente!';
    }
  }

  // Feedback específico para la letra V
  String _getFeedbackForLetterV(int attempts) {
    switch (attempts) {
      case 1:
        return 'La V son dos líneas diagonales que se juntan abajo. Haz una línea diagonal';
      case 2:
        return 'Para la V, puedes hacer la línea de arriba-izquierda hacia abajo-centro, o de arriba-derecha hacia abajo-centro';
      case 3:
        return 'La letra V es como un pico de montaña al revés: dos diagonales que se encuentran abajo';
      default:
        return 'Voy a enseñarte cómo se traza la V';
    }
  }

  // Feedback específico para la letra W
  String _getFeedbackForLetterW(int attempts) {
    switch (attempts) {
      case 1:
        return 'La W es como dos V juntas. Haz una línea diagonal';
      case 2:
        return 'Para la W, puedes hacer cualquiera de las cuatro líneas diagonales';
      case 3:
        return 'La letra W son cuatro líneas diagonales que hacen dos picos hacia arriba';
      default:
        return 'Te enseño cómo hacer la W. ¡Como dos montañitas!';
    }
  }

  // Feedback específico para la letra X
  String _getFeedbackForLetterX(int attempts) {
    switch (attempts) {
      case 1:
        return 'La X son dos líneas diagonales que se cruzan. Haz una línea diagonal';
      case 2:
        return 'Para la X, puedes hacer la diagonal de arriba-izquierda a abajo-derecha, o la de arriba-derecha a abajo-izquierda';
      case 3:
        return 'La letra X es como una cruz girada: dos diagonales que se cruzan en el centro';
      default:
        return 'Voy a mostrarte cómo se hace la X';
    }
  }

  // Feedback específico para la letra Y
  String _getFeedbackForLetterY(int attempts) {
    switch (attempts) {
      case 1:
        return 'La Y es como una V con una línea vertical abajo. Haz una línea diagonal o vertical';
      case 2:
        return 'Para la Y, puedes hacer las dos diagonales de arriba que se juntan, o la línea vertical de abajo';
      case 3:
        return 'La letra Y son dos diagonales que se juntan en el centro y una línea vertical hacia abajo';
      default:
        return 'Te muestro cómo hacer la Y. ¡Observa bien!';
    }
  }

  // Feedback específico para la letra Z
  String _getFeedbackForLetterZ(int attempts) {
    switch (attempts) {
      case 1:
        return 'La Z tiene líneas horizontales arriba y abajo, y una diagonal. Haz una línea recta';
      case 2:
        return 'Para la Z, puedes hacer la línea horizontal de arriba, la diagonal del medio, o la horizontal de abajo';
      case 3:
        return 'La letra Z es como un rayo: horizontal arriba, diagonal hacia abajo-izquierda, horizontal abajo';
      default:
        return 'Voy a enseñarte cómo se traza la Z';
    }
  }
  
  // Feedback genérico para otras letras
  String _getGenericFeedback(int attempts) {
    switch (attempts) {
      case 1:
        return 'Inténtalo de nuevo, tú puedes lograrlo';
      case 2:
        return 'Trata de seguir la forma de la letra. Hazlo más despacio';
      case 3:
        return 'Mira la forma gris de la letra y trata de seguirla con tu trazo';
      default:
        return 'Te voy a mostrar cómo se hace. ¡Observa bien!';
    }
  }
  
  // Detectar trazo diagonal
  bool _isDiagonalStroke(List<Offset> stroke) {
    if (stroke.length < 5) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Cambio significativo en X y Y
    final deltaX = (end.dx - start.dx).abs();
    final deltaY = (end.dy - start.dy).abs();
    
    // Es diagonal si ambos deltas son significativos
    return deltaX > 0.2 && deltaY > 0.3;
  }
  
  // Detectar trazo horizontal
  bool _isHorizontalStroke(List<Offset> stroke) {
    if (stroke.length < 5) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    // Cambio mínimo en Y, cambio significativo en X
    final deltaX = (end.dx - start.dx).abs();
    final deltaY = (end.dy - start.dy).abs();
    
    // Es horizontal si X cambia mucho pero Y poco
    return deltaX > 0.3 && deltaY < 0.2;
  }
  
  // Detectar trazo vertical del lado izquierdo (para la letra B)
  bool _isLeftVerticalStroke(List<Offset> stroke) {
    if (stroke.length < 3) return false;
    
    // Calcular el promedio de X para ver si está en el lado izquierdo
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en la mitad izquierda (X < 0.5) y ser vertical
    return avgX < 0.5 && _isVerticalStroke(stroke);
  }
  
  // Detectar trazo pequeño como un punto (para la letra I)
  bool _isSmallDot(List<Offset> stroke) {
    if (stroke.length < 2 || stroke.length > 8) return false;
    
    // Calcular el área cubierta por el trazo
    final bounds = _getStrokeBounds(stroke);
    final width = bounds.width;
    final height = bounds.height;
    
    // Es un punto si es muy pequeño
    return width < 0.1 && height < 0.1;
  }
  
  // Detectar trazo en forma de V o pico
  bool _isVShapeStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Encontrar el punto más alto (menor Y)
    double minY = stroke.first.dy;
    int minYIndex = 0;
    
    for (int i = 1; i < stroke.length; i++) {
      if (stroke[i].dy < minY) {
        minY = stroke[i].dy;
        minYIndex = i;
      }
    }
    
    // El pico debe estar en el tercio medio del trazo (no al inicio/final)
    final isMiddlePeak = minYIndex > stroke.length * 0.2 && minYIndex < stroke.length * 0.8;
    
    // Los extremos deben estar más abajo que el pico
    final start = stroke.first;
    final end = stroke.last;
    final peakIsBetween = start.dy > minY && end.dy > minY;
    
    return isMiddlePeak && peakIsBetween;
  }
  
  // VALIDACIÓN PARA LA LETRA O
  bool _validateLetterO(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 10) return false;
    
    // La O debe ser circular/ovalada
    return _isCircularStroke(normalizedStroke);
  }
  
  // VALIDACIÓN PARA LA LETRA C
  bool _validateLetterC(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 8) return false;
    
    // La C se traza de arriba hacia abajo como un círculo abierto en sentido horario
    return _isOpenCircularStroke(normalizedStroke) && _isClockwiseStroke(normalizedStroke);
  }
  
  // Verificar si el trazo va en sentido horario (de arriba hacia abajo)
  bool _isClockwiseStroke(List<Offset> stroke) {
    if (stroke.length < 3) return true; // Demasiado corto para determinar dirección
    
    double totalAngleChange = 0;
    for (int i = 1; i < stroke.length - 1; i++) {
      final prev = stroke[i - 1];
      final curr = stroke[i];
      final next = stroke[i + 1];
      
      // Calcular vectores
      final v1 = Offset(curr.dx - prev.dx, curr.dy - prev.dy);
      final v2 = Offset(next.dx - curr.dx, next.dy - curr.dy);
      
      // Producto cruzado para determinar dirección
      final crossProduct = v1.dx * v2.dy - v1.dy * v2.dx;
      totalAngleChange += crossProduct;
    }
    
    // Si es positivo, generalmente indica sentido horario
    return totalAngleChange > 0 || _startsFromTop(stroke);
  }
  
  // Verificar si el trazo empieza desde arriba
  bool _startsFromTop(List<Offset> stroke) {
    if (stroke.isEmpty) return false;
    return stroke.first.dy < 0.4; // Empieza en el tercio superior
  }
  
  // VALIDACIÓN ESPECÍFICA PARA LA LETRA B - Alfabeto Argentino
  bool _validateLetterB(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // La B tiene: línea vertical izquierda + dos semicírculos (superior e inferior)
    // Aceptamos cualquiera de estos componentes por separado
    return _isLeftVerticalOfB(normalizedStroke) || 
           _isUpperCurveOfB(normalizedStroke) ||
           _isLowerCurveOfB(normalizedStroke) ||
           _isCompleteBStroke(normalizedStroke);
  }
  
  // Validar línea vertical izquierda de la B
  bool _isLeftVerticalOfB(List<Offset> stroke) {
    final start = stroke.first;
    final end = stroke.last;
    
    // Debe estar en el lado izquierdo y ser vertical
    return start.dx < 0.3 && end.dx < 0.3 && _isVerticalStroke(stroke);
  }
  
  // Validar semicírculo superior de la B
  bool _isUpperCurveOfB(List<Offset> stroke) {
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en la parte superior derecha y ser curvo
    return avgY < 0.5 && avgX > 0.3 && _isCurvedStroke(stroke);
  }
  
  // Validar semicírculo inferior de la B
  bool _isLowerCurveOfB(List<Offset> stroke) {
    final avgY = stroke.map((p) => p.dy).reduce((a, b) => a + b) / stroke.length;
    final avgX = stroke.map((p) => p.dx).reduce((a, b) => a + b) / stroke.length;
    
    // Debe estar en la parte inferior derecha y ser curvo
    return avgY > 0.5 && avgX > 0.3 && _isCurvedStroke(stroke);
  }
  
  // Validar trazo completo de B
  bool _isCompleteBStroke(List<Offset> stroke) {
    // La B completa tiene una línea vertical seguida de curvas
    return (_isVerticalStroke(stroke.sublist(0, stroke.length ~/ 3)) &&
            _isCurvedStroke(stroke.sublist(stroke.length ~/ 3))) ||
           (_isLeftVerticalStroke(stroke) && _isCurvedStroke(stroke));
  }
  
  // VALIDACIÓN BÁSICA PARA LETRAS NO ESPECÍFICAS
  bool _validateBasicLetterShape(List<Offset> normalizedStroke) {
    if (normalizedStroke.length < 5) return false;
    
    // Validación permisiva: cualquier trazo intencional es válido
    final start = normalizedStroke.first;
    final end = normalizedStroke.last;
    
    // Debe tener algún movimiento significativo
    final deltaX = (end.dx - start.dx).abs();
    final deltaY = (end.dy - start.dy).abs();
    
    return deltaX > 0.1 || deltaY > 0.1;
  }
  
  // FUNCIONES AUXILIARES PARA DETECCIÓN DE FORMAS
  
  bool _isCircularStroke(List<Offset> stroke) {
    if (stroke.length < 12) return false;
    
    // Verificar que el trazo vuelva cerca del punto inicial
    final start = stroke.first;
    final end = stroke.last;
    final distance = (end - start).distance;
    
    // Debe terminar cerca del inicio (círculo cerrado)
    if (distance > 0.3) return false;
    
    // Verificar que cubra las 4 direcciones (arriba, abajo, izquierda, derecha)
    final bounds = Rect.fromPoints(start, end);
    double minX = stroke.first.dx, maxX = stroke.first.dx;
    double minY = stroke.first.dy, maxY = stroke.first.dy;
    
    for (final point in stroke) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }
    
    // Debe cubrir un área razonable en todas las direcciones
    final widthCoverage = maxX - minX;
    final heightCoverage = maxY - minY;
    
    return widthCoverage > 0.4 && heightCoverage > 0.4;
  }
  
  bool _isOpenCircularStroke(List<Offset> stroke) {
    if (stroke.length < 8) return false;
    
    // Similar a circular pero no necesita cerrarse
    final start = stroke.first;
    final end = stroke.last;
    
    // NO debe terminar cerca del inicio (C abierta)
    final distance = (end - start).distance;
    if (distance < 0.2) return false; // Muy cerrado para ser C
    
    // Debe ser curvo (cambios de dirección graduales)
    return _isCurvedStroke(stroke);
  }
  
  bool _isVerticalStroke(List<Offset> stroke) {
    if (stroke.length < 5) return false;
    
    final start = stroke.first;
    final end = stroke.last;
    
    final deltaX = (end.dx - start.dx).abs();
    final deltaY = (end.dy - start.dy).abs();
    
    // Es vertical si Y cambia mucho pero X poco
    return deltaY > 0.3 && deltaX < 0.2;
  }
  
  bool _isCurvedStroke(List<Offset> stroke) {
    if (stroke.length < 10) return false;
    
    // Contar cambios de dirección graduales (no bruscos)
    int gradualTurns = 0;
    int sharpTurns = 0;
    
    for (int i = 2; i < stroke.length; i++) {
      final vec1 = stroke[i-1] - stroke[i-2];
      final vec2 = stroke[i] - stroke[i-1];
      
      if (vec1.distance > 0 && vec2.distance > 0) {
        final dot = vec1.dx * vec2.dx + vec1.dy * vec2.dy;
        final cosAngle = dot / (vec1.distance * vec2.distance);
        
        if (cosAngle < 0.7) { // Cambio de más de 45 grados
          if (cosAngle > -0.5) { // Pero menos de 120 grados
            gradualTurns++;
          } else {
            sharpTurns++;
          }
        }
      }
    }
    
    // Es curvo si tiene cambios graduales pero pocos bruscos
    return gradualTurns > stroke.length * 0.1 && sharpTurns < stroke.length * 0.05;
  }

  Rect _getStrokeBounds(List<Offset> stroke) {
    if (stroke.isEmpty) return Rect.zero;
    
    double minX = stroke.first.dx, maxX = stroke.first.dx;
    double minY = stroke.first.dy, maxY = stroke.first.dy;
    
    for (final point in stroke) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }





  void _startDemo() {
    // Limpiar trazos existentes primero
    setState(() {
      _strokes.clear();
      _invalidStrokes.clear();
      _currentStroke.clear();
      _showingDemo = true;
    });
    
    // Audio inmediato + animación simultánea
    widget.audioService.speakText('Mira cómo se escribe la letra ${widget.letter.toUpperCase()}.');
    
    // Iniciar animación inmediatamente
    _demoController.reset();
    _demoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showingDemo = false;
          });
        }
      });
    });
  }

  bool _isTracingValid() {
    // Validación mejorada: necesita al menos un trazo válido
    return _validStrokes >= _requiredStrokes;
  }

  int _getRequiredStrokesForLetter(String letter) {
    // TODAS las letras solo necesitan 1 trazo para ser más fácil
    return 1;
  }

  String _getHintText() {
    if (_validStrokes >= _requiredStrokes) return '¡Terminé!';
    
    final failedAttempts = _invalidStrokes.length;
    if (failedAttempts >= 3) return 'Usa "Ver cómo" si necesitas ayuda';
    if (_hasTraced && _validStrokes == 0) return 'Inténtalo de nuevo';
    
    return 'Traza la letra ${widget.letter}';
  }
}

// Pintor personalizado para los trazos
class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final List<List<Offset>> invalidStrokes;
  final String letter;

  _TracingPainter(this.strokes, this.currentStroke, this.invalidStrokes, this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar contorno guía de la letra (estilo libro para colorear)
    _drawLetterOutline(canvas, size);
    
    final paint = Paint()
      ..color = Colors.blue[600]!
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Dibujar trazos completados
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Dibujar trazos inválidos en rojo para mostrar errores
    final invalidPaint = Paint()
      ..color = Colors.red[400]!
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
      
    for (final stroke in invalidStrokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, invalidPaint);
      }
    }

    // Dibujar trazo actual
    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  // Método para dibujar el contorno guía de la letra
  void _drawLetterOutline(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Dibujar contorno según la letra
    switch (letter.toUpperCase()) {
      case 'A':
        _drawOutlineA(canvas, size, outlinePaint);
        break;
      case 'B':
        _drawOutlineB(canvas, size, outlinePaint);
        break;
      case 'C':
        _drawOutlineC(canvas, size, outlinePaint);
        break;
      case 'D':
        _drawOutlineD(canvas, size, outlinePaint);
        break;
      case 'E':
        _drawOutlineE(canvas, size, outlinePaint);
        break;
      case 'F':
        _drawOutlineF(canvas, size, outlinePaint);
        break;
      case 'G':
        _drawOutlineG(canvas, size, outlinePaint);
        break;
      case 'H':
        _drawOutlineH(canvas, size, outlinePaint);
        break;
      case 'I':
        _drawOutlineI(canvas, size, outlinePaint);
        break;
      case 'J':
        _drawOutlineJ(canvas, size, outlinePaint);
        break;
      case 'K':
        _drawOutlineK(canvas, size, outlinePaint);
        break;
      case 'L':
        _drawOutlineL(canvas, size, outlinePaint);
        break;
      case 'M':
        _drawOutlineM(canvas, size, outlinePaint);
        break;
      case 'N':
        _drawOutlineN(canvas, size, outlinePaint);
        break;
      case '\u00D1':
        _drawOutlineN(canvas, size, outlinePaint);
        break;
      case 'O':
        _drawOutlineO(canvas, size, outlinePaint);
        break;
      case 'P':
        _drawOutlineP(canvas, size, outlinePaint);
        break;
      case 'Q':
        _drawOutlineQ(canvas, size, outlinePaint);
        break;
      case 'R':
        _drawOutlineR(canvas, size, outlinePaint);
        break;
      case 'S':
        _drawOutlineS(canvas, size, outlinePaint);
        break;
      case 'T':
        _drawOutlineT(canvas, size, outlinePaint);
        break;
      case 'U':
        _drawOutlineU(canvas, size, outlinePaint);
        break;
      case 'V':
        _drawOutlineV(canvas, size, outlinePaint);
        break;
      case 'W':
        _drawOutlineW(canvas, size, outlinePaint);
        break;
      case 'X':
        _drawOutlineX(canvas, size, outlinePaint);
        break;
      case 'Y':
        _drawOutlineY(canvas, size, outlinePaint);
        break;
      case 'Z':
        _drawOutlineZ(canvas, size, outlinePaint);
        break;
    }
  }

  // Contornos específicos para cada letra
  void _drawOutlineA(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final topPoint = Offset(centerX, size.height * 0.2);
    final leftPoint = Offset(centerX - size.width * 0.25, size.height * 0.8);
    final rightPoint = Offset(centerX + size.width * 0.25, size.height * 0.8);
    final midLeftPoint = Offset(centerX - size.width * 0.125, size.height * 0.55);
    final midRightPoint = Offset(centerX + size.width * 0.125, size.height * 0.55);
    
    canvas.drawLine(leftPoint, topPoint, paint);
    canvas.drawLine(topPoint, rightPoint, paint);
    canvas.drawLine(midLeftPoint, midRightPoint, paint);
  }

  void _drawOutlineB(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, midY), paint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, midY), paint);
    canvas.drawLine(Offset(rightX, midY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineC(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path();
    path.addArc(rect, 0.25 * 3.14159, 1.5 * 3.14159);
    canvas.drawPath(path, paint);
  }

  void _drawOutlineD(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    
    final path = Path()
      ..moveTo(leftX, topY)
      ..cubicTo(size.width * 0.6, topY, size.width * 0.6, bottomY, leftX, bottomY);
    canvas.drawPath(path, paint);
  }

  void _drawOutlineE(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX * 0.9, midY), paint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineF(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX * 0.9, midY), paint);
  }

  void _drawOutlineG(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = Path();
    path.addArc(rect, 0.25 * 3.14159, 1.5 * 3.14159);
    canvas.drawPath(path, paint);
    
    final rightX = center.dx + radius * 0.7;
    final midRightX = center.dx + radius * 0.3;
    canvas.drawLine(Offset(rightX, center.dy), Offset(midRightX, center.dy), paint);
  }

  void _drawOutlineH(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, midY), paint);
  }

  void _drawOutlineI(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final lineWidth = size.width * 0.2;
    
    canvas.drawLine(Offset(centerX - lineWidth / 2, topY), Offset(centerX + lineWidth / 2, topY), paint);
    canvas.drawLine(Offset(centerX, topY), Offset(centerX, bottomY), paint);
    canvas.drawLine(Offset(centerX - lineWidth / 2, bottomY), Offset(centerX + lineWidth / 2, bottomY), paint);
  }

  void _drawOutlineJ(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final leftX = size.width * 0.3;
    
    canvas.drawLine(Offset(centerX, topY), Offset(centerX, bottomY * 0.9), paint);
    
    final path = Path()
      ..moveTo(centerX, bottomY * 0.9)
      ..quadraticBezierTo(leftX, bottomY, leftX, bottomY * 0.8);
    canvas.drawPath(path, paint);
  }

  void _drawOutlineK(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(leftX, midY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineL(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineM(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.25;
    final rightX = size.width * 0.75;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.6;
    
    canvas.drawLine(Offset(leftX, bottomY), Offset(leftX, topY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(centerX, midY), paint);
    canvas.drawLine(Offset(centerX, midY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineN(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, bottomY), Offset(leftX, topY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, bottomY), paint);
    canvas.drawLine(Offset(rightX, bottomY), Offset(rightX, topY), paint);
  }

  void _drawOutlineO(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawOutlineP(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, midY), paint);
    canvas.drawLine(Offset(rightX, midY), Offset(leftX, midY), paint);
  }

  void _drawOutlineQ(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    canvas.drawCircle(center, radius, paint);
    
    final startX = center.dx + radius * 0.5;
    final startY = center.dy + radius * 0.5;
    final endX = center.dx + radius * 1.2;
    final endY = center.dy + radius * 1.2;
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  void _drawOutlineR(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, midY), paint);
    canvas.drawLine(Offset(rightX, midY), Offset(leftX, midY), paint);
    canvas.drawLine(Offset(leftX + (rightX - leftX) * 0.7, midY), Offset(rightX, bottomY), paint);
  }

  void _drawOutlineS(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height / 2;
    final width = size.width * 0.25;
    
    final path = Path()
      ..moveTo(centerX + width, topY + width * 0.5)
      ..quadraticBezierTo(centerX - width, topY, centerX, midY)
      ..quadraticBezierTo(centerX + width, bottomY, centerX - width, bottomY - width * 0.5);
    canvas.drawPath(path, paint);
  }

  void _drawOutlineT(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(centerX, topY), Offset(centerX, bottomY), paint);
  }

  void _drawOutlineU(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final centerX = size.width / 2;
    
    final path = Path()
      ..moveTo(leftX, topY)
      ..lineTo(leftX, bottomY * 0.7)
      ..quadraticBezierTo(centerX, bottomY, rightX, bottomY * 0.7)
      ..lineTo(rightX, topY);
    canvas.drawPath(path, paint);
  }

  void _drawOutlineV(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final centerX = size.width / 2;
    
    canvas.drawLine(Offset(leftX, topY), Offset(centerX, bottomY), paint);
    canvas.drawLine(Offset(centerX, bottomY), Offset(rightX, topY), paint);
  }

  void _drawOutlineW(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.2;
    final rightX = size.width * 0.8;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final quarter1X = size.width * 0.4;
    final quarter3X = size.width * 0.6;
    final centerX = size.width / 2;
    final midY = size.height * 0.6;
    
    canvas.drawLine(Offset(leftX, topY), Offset(quarter1X, bottomY), paint);
    canvas.drawLine(Offset(quarter1X, bottomY), Offset(centerX, midY), paint);
    canvas.drawLine(Offset(centerX, midY), Offset(quarter3X, bottomY), paint);
    canvas.drawLine(Offset(quarter3X, bottomY), Offset(rightX, topY), paint);
  }

  void _drawOutlineX(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, bottomY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(leftX, bottomY), paint);
  }

  void _drawOutlineY(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    canvas.drawLine(Offset(leftX, topY), Offset(centerX, midY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(centerX, midY), paint);
    canvas.drawLine(Offset(centerX, midY), Offset(centerX, bottomY), paint);
  }

  void _drawOutlineZ(Canvas canvas, Size size, Paint paint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);
    canvas.drawLine(Offset(rightX, topY), Offset(leftX, bottomY), paint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pintor animado que demuestra cómo escribir cada letra
class _LetterDemoPainter extends CustomPainter {
  final String letter;
  final double progress;
  final bool showDemo;

  _LetterDemoPainter({
    required this.letter,
    required this.progress,
    required this.showDemo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showDemo) return; // Solo mostrar durante la demostración
    
    // Pincel para la animación de demostración (más visible para niños)
    final demoPaint = Paint()
      ..color = Colors.green[600]!
      ..strokeWidth = 12.0 // Más grueso para mejor visibilidad
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    
    // Pincel para puntos de inicio (muy prominente y pulsante)
    final pulseSize = 8.0 + (4.0 * (0.5 + 0.5 * math.sin(progress * math.pi * 4))); // Efecto pulsante
    final startPaint = Paint()
      ..color = Colors.orange[600]! // Naranja vibrante para llamar atención
      ..strokeWidth = pulseSize
      ..style = PaintingStyle.fill;
    
    // Pincel para flechas direccionales
    final arrowPaint = Paint()
      ..color = Colors.red[500]! // Rojo para dirección
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (letter.toUpperCase()) {
      case 'A':
        _paintDemoLetterA(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'B':
        _paintDemoLetterB(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'C':
        _paintDemoLetterC(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'O':
        _paintDemoLetterO(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'I':
        _paintDemoLetterI(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'L':
        _paintDemoLetterL(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'D':
        _paintDemoLetterD(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'E':
        _paintDemoLetterE(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'F':
        _paintDemoLetterF(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'G':
        _paintDemoLetterG(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'H':
        _paintDemoLetterH(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'J':
        _paintDemoLetterJ(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'K':
        _paintDemoLetterK(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'M':
        _paintDemoLetterM(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'N':
        _paintDemoLetterN(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case '\u00D1':
        _paintDemoLetterN_tilde(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'P':
        _paintDemoLetterP(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'Q':
        _paintDemoLetterQ(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'R':
        _paintDemoLetterR(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'S':
        _paintDemoLetterS(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'T':
        _paintDemoLetterT(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'U':
        _paintDemoLetterU(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'V':
        _paintDemoLetterV(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'W':
        _paintDemoLetterW(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'X':
        _paintDemoLetterX(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'Y':
        _paintDemoLetterY(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      case 'Z':
        _paintDemoLetterZ(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
      default:
        _paintDemoGenericLetter(canvas, size, demoPaint, startPaint, arrowPaint);
        break;
    }
  }

  // Métodos de demostración animada para cada letra
  void _paintDemoLetterA(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    // Si no hay progreso, no dibujar nada
    if (progress <= 0.0) return;
    
    final centerX = size.width / 2;
    final topPoint = Offset(centerX, size.height * 0.2);
    final leftPoint = Offset(centerX - size.width * 0.25, size.height * 0.8);
    final rightPoint = Offset(centerX + size.width * 0.25, size.height * 0.8);
    final midLeftPoint = Offset(centerX - size.width * 0.125, size.height * 0.55);
    final midRightPoint = Offset(centerX + size.width * 0.125, size.height * 0.55);
    
    // Version simplificada y más rápida para la letra A
    
    // Trazo 1: Línea izquierda (0-33%)
    if (progress > 0.0) {
      final stroke1Progress = math.min(progress * 3.0, 1.0);
      _drawAnimatedLine(canvas, topPoint, leftPoint, stroke1Progress, paint);
      
      // Punto de inicio MUY visible con números
      if (progress < 0.33) {
        // Círculo pulsante grande
        canvas.drawCircle(topPoint, 16 + (4 * (0.5 + 0.5 * math.sin(progress * math.pi * 8))), startPaint);
        // Número "1" para indicar primer trazo
        _drawNumber(canvas, topPoint.translate(0, -25), "1", startPaint);
        // Flecha direccional hacia abajo-izquierda
        _drawArrow(canvas, topPoint, leftPoint, arrowPaint);
      }
    }
    
    // Trazo 2: Línea derecha (33-66%)
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3.0, 1.0);
      _drawAnimatedLine(canvas, topPoint, rightPoint, stroke2Progress, paint);
      
      // Mostrar punto durante el trazo con número "2"
      if (progress >= 0.33 && progress < 0.66) {
        canvas.drawCircle(topPoint, 16 + (4 * (0.5 + 0.5 * math.sin(progress * math.pi * 8))), startPaint);
        _drawNumber(canvas, topPoint.translate(0, -25), "2", startPaint);
        _drawArrow(canvas, topPoint, rightPoint, arrowPaint);
      }
    }
    
    // Trazo 3: Barra horizontal (66-100%)
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3.0, 1.0);
      _drawAnimatedLine(canvas, midLeftPoint, midRightPoint, stroke3Progress, paint);
      
      // Mostrar punto durante el trazo final con número "3"
      if (progress >= 0.66 && stroke3Progress < 1.0) {
        canvas.drawCircle(midLeftPoint, 16 + (4 * (0.5 + 0.5 * math.sin(progress * math.pi * 8))), startPaint);
        _drawNumber(canvas, midLeftPoint.translate(0, -25), "3", startPaint);
        _drawArrow(canvas, midLeftPoint, midRightPoint, arrowPaint);
      }
    }
  }
  
  void _paintDemoLetterO(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    final startAngle = -math.pi / 2; // Comenzar desde arriba
    final sweepAngle = 2 * math.pi * progress; // Completar el círculo progresivamente
    
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final path = Path();
      path.addArc(rect, startAngle, sweepAngle);
      canvas.drawPath(path, paint);
      
      // Mostrar punto de inicio solo al comienzo
      if (progress < 0.1) {
        final startPoint = Offset(center.dx, center.dy - radius);
        canvas.drawCircle(startPoint, 8, startPaint);
      }
    }
  }
  
  void _paintDemoLetterI(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final lineWidth = size.width * 0.2;
    
    if (progress > 0.0) {
      // Trazo 1: Línea superior (0-25%)
      final stroke1Progress = math.min(progress * 4, 1.0);
      if (stroke1Progress > 0) {
        final leftPoint = Offset(centerX - lineWidth / 2, topY);
        final rightPoint = Offset(centerX + lineWidth / 2, topY);
        _drawAnimatedLine(canvas, leftPoint, rightPoint, stroke1Progress, paint);
        if (stroke1Progress < 1.0) {
          canvas.drawCircle(leftPoint, 8, startPaint);
        }
      }
    }
    
    if (progress > 0.25) {
      // Trazo 2: Línea vertical (25-75%)
      final stroke2Progress = math.min((progress - 0.25) * 2, 1.0);
      if (stroke2Progress > 0) {
        _drawAnimatedLine(canvas, Offset(centerX, topY), Offset(centerX, bottomY), stroke2Progress, paint);
        if (stroke2Progress < 1.0) {
          canvas.drawCircle(Offset(centerX, topY), 8, startPaint);
        }
      }
    }
    
    if (progress > 0.75) {
      // Trazo 3: Línea inferior (75-100%)
      final stroke3Progress = math.min((progress - 0.75) * 4, 1.0);
      if (stroke3Progress > 0) {
        final leftPoint = Offset(centerX - lineWidth / 2, bottomY);
        final rightPoint = Offset(centerX + lineWidth / 2, bottomY);
        _drawAnimatedLine(canvas, leftPoint, rightPoint, stroke3Progress, paint);
        if (stroke3Progress < 1.0) {
          canvas.drawCircle(leftPoint, 8, startPaint);
        }
      }
    }
  }
  
  void _paintDemoLetterL(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    if (progress > 0.0) {
      // Trazo 1: Línea vertical (0-70%)
      final stroke1Progress = math.min(progress * 1.43, 1.0);
      if (stroke1Progress > 0) {
        _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
        if (stroke1Progress < 1.0) {
          canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
        }
      }
    }
    
    if (progress > 0.7) {
      // Trazo 2: Línea horizontal (70-100%)
      final stroke2Progress = math.min((progress - 0.7) * 3.33, 1.0);
      if (stroke2Progress > 0) {
        _drawAnimatedLine(canvas, Offset(leftX, bottomY), Offset(rightX, bottomY), stroke2Progress, paint);
        if (stroke2Progress < 1.0) {
          canvas.drawCircle(Offset(leftX, bottomY), 8, startPaint);
        }
      }
    }
  }
  
  void _paintDemoLetterC(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    final startAngle = math.pi * 0.25; // 45 grados
    final sweepAngle = math.pi * 1.5 * progress; // 270 grados máximo
    
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final path = Path();
      path.addArc(rect, startAngle, sweepAngle);
      canvas.drawPath(path, paint);
      
      // Mostrar punto de inicio
      if (progress < 0.1) {
        final startPoint = Offset(center.dx + radius * 0.7, center.dy - radius * 0.7);
        canvas.drawCircle(startPoint, 8, startPaint);
      }
    }
  }
  
  void _paintDemoLetterB(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final middleY = size.height * 0.5;
    final bottomY = size.height * 0.8;
    
    if (progress > 0.0) {
      // Trazo 1: Línea vertical (0-40%)
      final stroke1Progress = math.min(progress * 2.5, 1.0);
      if (stroke1Progress > 0) {
        _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
        if (stroke1Progress < 1.0) {
          canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
        }
      }
    }
    
    if (progress > 0.4) {
      // Trazo 2: Semicircle superior (40-70%)
      final stroke2Progress = math.min((progress - 0.4) * 3.33, 1.0);
      if (stroke2Progress > 0) {
        final rect = Rect.fromPoints(Offset(leftX, topY), Offset(rightX, middleY));
        final path = Path();
        path.addArc(rect, -math.pi / 2, math.pi * stroke2Progress);
        canvas.drawPath(path, paint);
      }
    }
    
    if (progress > 0.7) {
      // Trazo 3: Semicircle inferior (70-100%)
      final stroke3Progress = math.min((progress - 0.7) * 3.33, 1.0);
      if (stroke3Progress > 0) {
        final rect = Rect.fromPoints(Offset(leftX, middleY), Offset(rightX, bottomY));
        final path = Path();
        path.addArc(rect, -math.pi / 2, math.pi * stroke3Progress);
        canvas.drawPath(path, paint);
      }
    }
  }
  
  // Nuevas implementaciones para letras faltantes
  void _paintDemoLetterD(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Línea vertical izquierda (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Curva derecha (50-100%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 2, 1.0);
      final path = Path()
        ..moveTo(leftX, topY)
        ..cubicTo(rightX, topY, rightX, bottomY, leftX, bottomY);
      final pathMetrics = path.computeMetrics();
      if (pathMetrics.isNotEmpty) {
        final pathMetric = pathMetrics.first;
        final extractPath = pathMetric.extractPath(0, pathMetric.length * stroke2Progress);
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  void _paintDemoLetterE(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Línea vertical (0-25%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea superior (25-50%)
    if (progress > 0.25) {
      final stroke2Progress = math.min((progress - 0.25) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, topY), stroke2Progress, paint);
    }
    
    // Línea media (50-75%)
    if (progress > 0.5) {
      final stroke3Progress = math.min((progress - 0.5) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, midY), Offset(rightX * 0.9, midY), stroke3Progress, paint);
    }
    
    // Línea inferior (75-100%)
    if (progress > 0.75) {
      final stroke4Progress = math.min((progress - 0.75) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, bottomY), Offset(rightX, bottomY), stroke4Progress, paint);
    }
  }

  void _paintDemoLetterF(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Similar a E pero sin línea inferior
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 3.33, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, topY), stroke2Progress, paint);
    }
    
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, midY), Offset(rightX * 0.9, midY), stroke3Progress, paint);
    }
  }

  void _paintDemoLetterG(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    
    // Similar a C pero con línea horizontal interna
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 1.5, 1.0);
      final startAngle = math.pi * 0.25;
      final sweepAngle = math.pi * 1.5 * stroke1Progress;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final path = Path();
      path.addArc(rect, startAngle, sweepAngle);
      canvas.drawPath(path, paint);
      
      if (stroke1Progress < 0.1) {
        final startPoint = Offset(center.dx + radius * 0.7, center.dy - radius * 0.7);
        canvas.drawCircle(startPoint, 8, startPaint);
      }
    }
    
    // Línea horizontal interna (75-100%)
    if (progress > 0.75) {
      final stroke2Progress = math.min((progress - 0.75) * 4, 1.0);
      final rightX = center.dx + radius * 0.7;
      final midRightX = center.dx + radius * 0.3;
      _drawAnimatedLine(canvas, Offset(rightX, center.dy), Offset(midRightX, center.dy), stroke2Progress, paint);
    }
  }

  void _paintDemoLetterH(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Línea vertical izquierda (0-33%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea horizontal media (33-66%)
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, midY), Offset(rightX, midY), stroke2Progress, paint);
    }
    
    // Línea vertical derecha (66-100%)
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, topY), Offset(rightX, bottomY), stroke3Progress, paint);
    }
  }

  void _paintDemoLetterJ(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final leftX = size.width * 0.3;
    
    // Línea vertical (0-75%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 1.33, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, topY), Offset(centerX, bottomY * 0.9), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(centerX, topY), 8, startPaint);
    }
    
    // Curva inferior (75-100%)
    if (progress > 0.75) {
      final stroke2Progress = math.min((progress - 0.75) * 4, 1.0);
      final path = Path()
        ..moveTo(centerX, bottomY * 0.9)
        ..quadraticBezierTo(leftX, bottomY, leftX, bottomY * 0.8);
      final pathMetrics = path.computeMetrics();
      if (pathMetrics.isNotEmpty) {
        final pathMetric = pathMetrics.first;
        final extractPath = pathMetric.extractPath(0, pathMetric.length * stroke2Progress);
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  void _paintDemoLetterK(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Línea vertical izquierda (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea diagonal superior (50-75%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, midY), Offset(rightX, topY), stroke2Progress, paint);
    }
    
    // Línea diagonal inferior (75-100%)
    if (progress > 0.75) {
      final stroke3Progress = math.min((progress - 0.75) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, midY), Offset(rightX, bottomY), stroke3Progress, paint);
    }
  }

  void _paintDemoLetterM(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.25;
    final rightX = size.width * 0.75;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.6;
    
    // Línea vertical izquierda (0-25%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, bottomY), Offset(leftX, topY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, bottomY), 8, startPaint);
    }
    
    // Línea diagonal al centro (25-50%)
    if (progress > 0.25) {
      final stroke2Progress = math.min((progress - 0.25) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(centerX, midY), stroke2Progress, paint);
    }
    
    // Línea diagonal del centro a derecha (50-75%)
    if (progress > 0.5) {
      final stroke3Progress = math.min((progress - 0.5) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, midY), Offset(rightX, topY), stroke3Progress, paint);
    }
    
    // Línea vertical derecha (75-100%)
    if (progress > 0.75) {
      final stroke4Progress = math.min((progress - 0.75) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, topY), Offset(rightX, bottomY), stroke4Progress, paint);
    }
  }

  void _paintDemoLetterN(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    // Línea vertical izquierda (0-33%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, bottomY), Offset(leftX, topY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, bottomY), 8, startPaint);
    }
    
    // Línea diagonal (33-66%)
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, bottomY), stroke2Progress, paint);
    }
    
    // Línea vertical derecha (66-100%)
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, bottomY), Offset(rightX, topY), stroke3Progress, paint);
    }
  }

  void _paintDemoLetterN_tilde(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    // Similar a N pero con tilde arriba
    _paintDemoLetterN(canvas, size, paint, startPaint, arrowPaint);
    
    // Tilde arriba (se dibuja al final)
    if (progress > 0.8) {
      final tildeProgress = math.min((progress - 0.8) * 5, 1.0);
      final centerX = size.width / 2;
      final tildeY = size.height * 0.1;
      final tildeWidth = size.width * 0.2;
      
      final path = Path()
        ..moveTo(centerX - tildeWidth / 2, tildeY)
        ..quadraticBezierTo(centerX, tildeY - 10, centerX + tildeWidth / 2, tildeY);
      final pathMetrics = path.computeMetrics();
      if (pathMetrics.isNotEmpty) {
        final pathMetric = pathMetrics.first;
        final extractPath = pathMetric.extractPath(0, pathMetric.length * tildeProgress);
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  void _paintDemoLetterP(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Línea vertical (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(leftX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea superior (50-75%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, topY), stroke2Progress, paint);
    }
    
    // Línea derecha y curva (75-100%)
    if (progress > 0.75) {
      final stroke3Progress = math.min((progress - 0.75) * 4, 1.0);
      final path = Path()
        ..moveTo(rightX, topY)
        ..lineTo(rightX, midY * 0.9)
        ..lineTo(leftX, midY);
      final pathMetrics = path.computeMetrics();
      if (pathMetrics.isNotEmpty) {
        final pathMetric = pathMetrics.first;
        final extractPath = pathMetric.extractPath(0, pathMetric.length * stroke3Progress);
        canvas.drawPath(extractPath, paint);
      }
    }
  }

  void _paintDemoLetterQ(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    
    // Círculo (0-80%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 1.25, 1.0);
      final sweepAngle = math.pi * 2 * stroke1Progress;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final path = Path();
      path.addArc(rect, -math.pi / 2, sweepAngle);
      canvas.drawPath(path, paint);
      
      if (stroke1Progress < 0.1) {
        final startPoint = Offset(center.dx, center.dy - radius);
        canvas.drawCircle(startPoint, 8, startPaint);
      }
    }
    
    // Cola diagonal (80-100%)
    if (progress > 0.8) {
      final stroke2Progress = math.min((progress - 0.8) * 5, 1.0);
      final startX = center.dx + radius * 0.5;
      final startY = center.dy + radius * 0.5;
      final endX = center.dx + radius * 1.2;
      final endY = center.dy + radius * 1.2;
      _drawAnimatedLine(canvas, Offset(startX, startY), Offset(endX, endY), stroke2Progress, paint);
    }
  }

  void _paintDemoLetterR(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    // Similar a P pero con línea diagonal adicional
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.6;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Similar a P (0-75%)
    if (progress > 0) {
      final pProgress = math.min(progress * 1.33, 1.0);
      _paintDemoLetterP(canvas, size, paint, startPaint, arrowPaint);
    }
    
    // Línea diagonal adicional (75-100%)
    if (progress > 0.75) {
      final stroke4Progress = math.min((progress - 0.75) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX + (rightX - leftX) * 0.7, midY), 
                       Offset(rightX, bottomY), stroke4Progress, paint);
    }
  }

  void _paintDemoLetterS(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height / 2;
    final width = size.width * 0.25;
    
    // Curva S completa
    final path = Path()
      ..moveTo(centerX + width, topY + width * 0.5)
      ..quadraticBezierTo(centerX - width, topY, centerX, midY)
      ..quadraticBezierTo(centerX + width, bottomY, centerX - width, bottomY - width * 0.5);
    
    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final extractPath = pathMetric.extractPath(0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint);
      
      if (progress < 0.1) {
        canvas.drawCircle(Offset(centerX + width, topY + width * 0.5), 8, startPaint);
      }
    }
  }

  void _paintDemoLetterT(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final centerX = size.width / 2;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    // Línea horizontal superior (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, topY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea vertical central (50-100%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, topY), Offset(centerX, bottomY), stroke2Progress, paint);
    }
  }

  void _paintDemoLetterU(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final centerX = size.width / 2;
    
    // Forma de U con curva
    final path = Path()
      ..moveTo(leftX, topY)
      ..lineTo(leftX, bottomY * 0.7)
      ..quadraticBezierTo(centerX, bottomY, rightX, bottomY * 0.7)
      ..lineTo(rightX, topY);
    
    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final extractPath = pathMetric.extractPath(0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint);
      
      if (progress < 0.1) {
        canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
      }
    }
  }

  void _paintDemoLetterV(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final centerX = size.width / 2;
    
    // Línea diagonal izquierda (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(centerX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Línea diagonal derecha (50-100%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, bottomY), Offset(rightX, topY), stroke2Progress, paint);
    }
  }

  void _paintDemoLetterW(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.2;
    final rightX = size.width * 0.8;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final quarter1X = size.width * 0.4;
    final quarter3X = size.width * 0.6;
    final centerX = size.width / 2;
    final midY = size.height * 0.6;
    
    // V doble - 4 líneas
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(quarter1X, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    if (progress > 0.25) {
      final stroke2Progress = math.min((progress - 0.25) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(quarter1X, bottomY), Offset(centerX, midY), stroke2Progress, paint);
    }
    
    if (progress > 0.5) {
      final stroke3Progress = math.min((progress - 0.5) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, midY), Offset(quarter3X, bottomY), stroke3Progress, paint);
    }
    
    if (progress > 0.75) {
      final stroke4Progress = math.min((progress - 0.75) * 4, 1.0);
      _drawAnimatedLine(canvas, Offset(quarter3X, bottomY), Offset(rightX, topY), stroke4Progress, paint);
    }
  }

  void _paintDemoLetterX(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    // Diagonal \ (0-50%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, bottomY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Diagonal / (50-100%)
    if (progress > 0.5) {
      final stroke2Progress = math.min((progress - 0.5) * 2, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, topY), Offset(leftX, bottomY), stroke2Progress, paint);
    }
  }

  void _paintDemoLetterY(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    final midY = size.height * 0.5;
    
    // Diagonal izquierda (0-33%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(centerX, midY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Diagonal derecha (33-66%)
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, topY), Offset(centerX, midY), stroke2Progress, paint);
    }
    
    // Línea vertical inferior (66-100%)
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(centerX, midY), Offset(centerX, bottomY), stroke3Progress, paint);
    }
  }

  void _paintDemoLetterZ(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    if (progress <= 0.0) return;
    final leftX = size.width * 0.3;
    final rightX = size.width * 0.7;
    final topY = size.height * 0.2;
    final bottomY = size.height * 0.8;
    
    // Línea superior (0-33%)
    if (progress > 0) {
      final stroke1Progress = math.min(progress * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, topY), Offset(rightX, topY), stroke1Progress, paint);
      if (stroke1Progress < 1.0) canvas.drawCircle(Offset(leftX, topY), 8, startPaint);
    }
    
    // Diagonal (33-66%)
    if (progress > 0.33) {
      final stroke2Progress = math.min((progress - 0.33) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(rightX, topY), Offset(leftX, bottomY), stroke2Progress, paint);
    }
    
    // Línea inferior (66-100%)
    if (progress > 0.66) {
      final stroke3Progress = math.min((progress - 0.66) * 3, 1.0);
      _drawAnimatedLine(canvas, Offset(leftX, bottomY), Offset(rightX, bottomY), stroke3Progress, paint);
    }
  }

  void _paintDemoGenericLetter(Canvas canvas, Size size, Paint paint, Paint startPaint, Paint arrowPaint) {
    // Para letras no implementadas, mostrar solo el punto de inicio
    if (progress > 0) {
      final startPoint = Offset(size.width * 0.3, size.height * 0.2);
      canvas.drawCircle(startPoint, 8, startPaint);
    }
  }
  
  // Dibuja una línea animada según el progreso
  void _drawAnimatedLine(Canvas canvas, Offset start, Offset end, double progress, Paint paint) {
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );
    canvas.drawLine(start, currentEnd, paint);
  }

  // Dibuja un número en la posición especificada para guiar al niño
  void _drawNumber(Canvas canvas, Offset position, String number, Paint paint) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position.translate(-textPainter.width / 2, -textPainter.height / 2));
  }

  // Dibuja una flecha direccional para mostrar al niño hacia dónde trazar
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final direction = Offset(end.dx - start.dx, end.dy - start.dy);
    final length = math.sqrt(direction.dx * direction.dx + direction.dy * direction.dy);
    if (length == 0) return;
    
    final normalizedDirection = Offset(direction.dx / length, direction.dy / length);
    final arrowLength = math.min(length * 0.3, 40.0); // Flecha de longitud moderada
    final arrowEnd = Offset(
      start.dx + normalizedDirection.dx * arrowLength,
      start.dy + normalizedDirection.dy * arrowLength,
    );
    
    // Dibujar línea principal de la flecha
    canvas.drawLine(start, arrowEnd, paint);
    
    // Dibujar punta de la flecha
    final arrowHeadLength = 8.0;
    final perpendicular = Offset(-normalizedDirection.dy, normalizedDirection.dx);
    
    final arrowHead1 = Offset(
      arrowEnd.dx - normalizedDirection.dx * arrowHeadLength + perpendicular.dx * arrowHeadLength * 0.5,
      arrowEnd.dy - normalizedDirection.dy * arrowHeadLength + perpendicular.dy * arrowHeadLength * 0.5,
    );
    
    final arrowHead2 = Offset(
      arrowEnd.dx - normalizedDirection.dx * arrowHeadLength - perpendicular.dx * arrowHeadLength * 0.5,
      arrowEnd.dy - normalizedDirection.dy * arrowHeadLength - perpendicular.dy * arrowHeadLength * 0.5,
    );
    
    canvas.drawLine(arrowEnd, arrowHead1, paint);
    canvas.drawLine(arrowEnd, arrowHead2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Siempre repintar para la animación
}

// Widget de celebración con estrellas flotantes
class _CelebrationStarsWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const _CelebrationStarsWidget({required this.onComplete});

  @override
  State<_CelebrationStarsWidget> createState() => _CelebrationStarsWidgetState();
}

class _CelebrationStarsWidgetState extends State<_CelebrationStarsWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_StarAnimation> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Crear múltiples estrellas con animaciones aleatorias
    _stars = List.generate(20, (index) => _StarAnimation());
    
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Fondo semi-transparente con brillo
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      colors: [
                        Colors.blue.withOpacity(0.1 * _controller.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Mensaje de felicitación
                Center(
                  child: Transform.scale(
                    scale: _controller.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.lightBlue[400]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡EXCELENTE!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Estrellas flotantes
                ...(_stars.map((star) {
                  final progress = _controller.value;
                  final x = star.startX + (star.endX - star.startX) * progress;
                  final y = star.startY + (star.endY - star.startY) * progress;
                  final scale = star.scale * (1 - progress * 0.5);
                  final opacity = (1 - progress).clamp(0.0, 1.0);
                  
                  return Positioned(
                    left: x * size.width,
                    top: y * size.height,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: progress * star.rotation,
                        child: Icon(
                          Icons.star,
                          color: star.color.withOpacity(opacity),
                          size: star.size,
                        ),
                      ),
                    ),
                  );
                }).toList()),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Clase para manejar la animación de cada estrella individual
class _StarAnimation {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double scale;
  final double rotation;
  final double size;
  final Color color;

  _StarAnimation()
      : startX = 0.3 + (math.Random().nextDouble() * 0.4), // Centro de pantalla
        startY = 0.4 + (math.Random().nextDouble() * 0.2),
        endX = math.Random().nextDouble(), // Posición final aleatoria
        endY = math.Random().nextDouble(),
        scale = 0.5 + (math.Random().nextDouble() * 1.0),
        rotation = math.Random().nextDouble() * math.pi * 4,
        size = 20 + (math.Random().nextDouble() * 30),
        color = [
          Colors.blue[600]!,
          Colors.orange[500]!,
          Colors.amber[500]!,
          Colors.amber[700]!,
        ][math.Random().nextInt(4)];
}

// Widget de feedback cuando falla (rojo)
class _FailureFeedbackWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const _FailureFeedbackWidget({required this.onComplete});

  @override
  State<_FailureFeedbackWidget> createState() => _FailureFeedbackWidgetState();
}

class _FailureFeedbackWidgetState extends State<_FailureFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Fondo rojo suave
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      colors: [
                        Colors.orange.withOpacity(0.1 * _controller.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Mensaje de ánimo
                Center(
                  child: Transform.scale(
                    scale: _controller.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Inténtalo otra vez!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),

                      
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Widget para mostrar mensaje de éxito con la palabra
class _SuccessMessageWidget extends StatefulWidget {
  final String wordName;
  final String letterName;
  final VoidCallback onComplete;

  const _SuccessMessageWidget({
    required this.wordName,
    required this.letterName,
    required this.onComplete,
  });

  @override
  State<_SuccessMessageWidget> createState() => _SuccessMessageWidgetState();
}

class _SuccessMessageWidgetState extends State<_SuccessMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200), // ULTRA-OPTIMIZADO para flujo perfecto
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.elasticOut), // ULTRA-RÁPIDO: aparece en 550ms
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOut), // Fade suave y coordinado
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3 * (1 - _fadeAnimation.value)),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: (_scaleAnimation.value - 1) * 0.1, // Rotación sutil dinámica
                  child: Opacity(
                    opacity: 1 - _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(28), // Más espacioso
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: RadialGradient( // Gradiente radial más dinámico
                          colors: [
                            Colors.green[300]!,
                            Colors.green[500]!,
                            Colors.green[700]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24), // Más redondeado
                        border: Border.all(color: Colors.white, width: 3), // Borde blanco
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // Título dinámico "¡Perfecto!"
                        Text(
                          '¡PERFECTO!',
                          style: TextStyle(
                            fontSize: 36, // Más grande
                            fontWeight: FontWeight.w900, // Extra bold
                            color: Colors.white,
                            letterSpacing: 2.0, // Espaciado de letras
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mensaje principal
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.wordName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[300],
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const TextSpan(
                                text: '\nse escribe con ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: widget.letterName,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[300],
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(2, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Icono de éxito
                        Icon(
                          Icons.star,
                          color: Colors.amber[300],
                          size: 48,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
      },
    );
  }
}
