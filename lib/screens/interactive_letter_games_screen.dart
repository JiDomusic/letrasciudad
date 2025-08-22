import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:async';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../models/letter.dart';
import '../widgets/mini_tracing_canvas.dart';
// import '../widgets/kids_ai_chat.dart'; // Removed to fix errors
import '../widgets/letter_tracing_widget.dart';

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
  
  // Contador específico para letra Ñ
  int _nAttempts = 0;
  
  // Letters grid for find game
  List<Map<String, dynamic>>? _lettersGrid;

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
    _nAttempts = 0; // Reset counter for Ñ
    
    // Inicializar AudioService para mensajes de voz
    _audioService.initialize();
    
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // El niño puede interrumpir tocando la pantalla
    if (widget.letter.character.toUpperCase() == 'Ñ') {
      _audioService.speakText(
        '¡Bienvenido a la casa de la letra ${widget.letter.character}! Aquí hay pocas palabras que empiezan con Ñ. A todo esto, ¿has encontrado el Ñandú?'
      );
    } else {
      _audioService.speakText(
        '¡Bienvenido a la casa de la letra ${widget.letter.character}!'
      );
    }
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
                  widget.letter.primaryColor.withValues(alpha: 0.7),
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
                    color: Colors.white.withValues(alpha: 0.9),
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
        return _buildFindAllLettersGame(); // Juego original de cubos rosa/naranja
      case 3:
        return _buildLetterSoundGame();
      case 4:
        return _buildSpecialGame(); // Quinto juego especial
      default:
        return _buildObjectSelectionGame();
    }
  }

  Widget _buildGameSelector() {
    final baseGames = [
      {'icon': Icons.touch_app, 'title': 'Seleccionar', 'color': Colors.green[400]!},
      {'icon': Icons.edit, 'title': 'Trazar', 'color': Colors.blue[400]!},
      {'icon': Icons.search, 'title': 'Buscar', 'color': Colors.purple[400]!},
      {'icon': Icons.volume_up, 'title': 'Sonidos', 'color': Colors.orange[400]!},
    ];
    
    // Agregar quinto juego SOLO para las letras B, V, K, Y, Ñ, W
    final specialLetters = ['B', 'V', 'K', 'Y', 'Ñ', 'W'];
    final games = [...baseGames];
    
    if (specialLetters.contains(widget.letter.character)) {
      games.add({
        'icon': Icons.star, 
        'title': 'Nuevo', 
        'color': Colors.red[400]!
      });
    }

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
                // Reset letters grid when switching games
                _lettersGrid = null;
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
                    color: (game['color'] as Color).withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                  ? (isCorrect ? Colors.green.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.4))
                  : Colors.black.withValues(alpha: 0.1),
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
      if (widget.letter.character.toUpperCase() == 'Ñ') {
        _nAttempts++;
        if (_nAttempts >= 3) {
          _audioService.speakText('¡Muy bien! La letra Ñ no tiene muchas palabras. Toca el ícono de la estrella para jugar a trazar la letra Ñ.');
        } else {
          _audioService.speakText('¡Sigue buscando! ¿Puedes encontrar el Ñandú?');
        }
      } else {
        _audioService.speakText('¡Inténtalo de nuevo! Busca palabras que empiecen con ${widget.letter.character.toUpperCase()}');
      }
      
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
          // Header mejorado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[600]!, Colors.blue[400]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✍️ TRAZADO INTERACTIVO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Traza la letra ${widget.letter.character.toUpperCase()} siguiendo las guías',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '✨ NUEVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Widget de trazado interactivo
          Expanded(
            child: LetterTracingWidget(
              letter: widget.letter.character.toUpperCase(),
              audioService: _audioService,
              playerName: context.read<LetterCityProvider>().playerName,
              isSpecialLetter: false, // Regular letters get normal feedback
              onTracingComplete: () {
                // Completar actividad y mostrar celebración
                final provider = context.read<LetterCityProvider>();
                provider.completeActivity(
                  'letter_tracing_${widget.letter.character}', 
                  100
                );
                
                // Mostrar celebración después de un breve delay
                Future.delayed(const Duration(seconds: 1), () {
                  _showCelebrationStars();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicalSearchGame() {
    // Lista de objetos que empiezan con la letra actual
    final searchObjects = _getSearchObjectsForLetter(widget.letter.character.toUpperCase());
    final foundCount = searchObjects.where((obj) => obj['found'] == true).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Título mágico
          Text(
            'BUSCA TODOS LOS ELEMENTOS QUE COMIENZAN CON ${widget.letter.character.toUpperCase()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Has click en la imagen y encuentra los 7 elementos que comienzan con ${widget.letter.character.toUpperCase()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Indicador de progreso con círculos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < foundCount ? Colors.green : Colors.white,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: index < foundCount 
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
              );
            }),
          ),
          
          const SizedBox(height: 30),
          
          // Grid de objetos en casilleros mágicos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: searchObjects.length,
              itemBuilder: (context, index) {
                final obj = searchObjects[index];
                return _buildMagicalSearchTile(obj);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Objetos de búsqueda para cada letra
  List<Map<String, dynamic>> _getSearchObjectsForLetter(String letter) {
    switch (letter) {
      case 'A':
        return [
          {'emoji': '🐝', 'name': 'Abeja', 'correct': true, 'found': false},
          {'emoji': '🎨', 'name': 'Arte', 'correct': true, 'found': false}, 
          {'emoji': '🏠', 'name': 'Casa', 'correct': false, 'found': false},
          {'emoji': '🌳', 'name': 'Árbol', 'correct': true, 'found': false},
          {'emoji': '🐘', 'name': 'Elefante', 'correct': false, 'found': false},
          {'emoji': '⚓', 'name': 'Ancla', 'correct': true, 'found': false},
          {'emoji': '🚗', 'name': 'Auto', 'correct': true, 'found': false},
          {'emoji': '🌸', 'name': 'Flor', 'correct': false, 'found': false},
          {'emoji': '💍', 'name': 'Anillo', 'correct': true, 'found': false},
          {'emoji': '✈️', 'name': 'Avión', 'correct': true, 'found': false},
          {'emoji': '🐕', 'name': 'Perro', 'correct': false, 'found': false},
          {'emoji': '🌟', 'name': 'Estrella', 'correct': false, 'found': false},
        ];
      default:
        return [
          {'emoji': '🍌', 'name': 'Banana', 'correct': true, 'found': false},
          {'emoji': '⚽', 'name': 'Balón', 'correct': true, 'found': false},
          {'emoji': '🚌', 'name': 'Bus', 'correct': true, 'found': false},
          {'emoji': '🧸', 'name': 'Oso', 'correct': false, 'found': false},
          {'emoji': '🚲', 'name': 'Bicicleta', 'correct': true, 'found': false},
          {'emoji': '📖', 'name': 'Libro', 'correct': false, 'found': false},
          {'emoji': '🍼', 'name': 'Biberón', 'correct': true, 'found': false},
          {'emoji': '🎈', 'name': 'Globo', 'correct': false, 'found': false},
          {'emoji': '🚢', 'name': 'Barco', 'correct': true, 'found': false},
          {'emoji': '🎯', 'name': 'Blanco', 'correct': true, 'found': false},
          {'emoji': '🌸', 'name': 'Flor', 'correct': false, 'found': false},
          {'emoji': '🐱', 'name': 'Gato', 'correct': false, 'found': false},
        ];
    }
  }

  Widget _buildMagicalSearchTile(Map<String, dynamic> obj) {
    final isCorrect = obj['correct'] as bool;
    final isFound = obj['found'] as bool;
    
    return GestureDetector(
      onTap: () => _handleMagicalSearch(obj),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFound 
                ? (isCorrect ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isFound ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isFound 
                  ? (isCorrect ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3))
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFound && isCorrect
                  ? [Colors.green[100]!, Colors.green[200]!]
                  : isFound
                      ? [Colors.red[100]!, Colors.red[200]!]
                      : [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                obj['emoji'] as String,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 4),
              if (isFound)
                Text(
                  obj['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[700] : Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              if (isFound && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
              if (isFound && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMagicalSearch(Map<String, dynamic> obj) {
    if (obj['found'] == true) return; // Ya fue encontrado
    
    setState(() {
      obj['found'] = true;
    });
    
    final isCorrect = obj['correct'] as bool;
    if (isCorrect) {
      _audioService.speakText('¡Excelente! ${obj['name']} empieza con ${widget.letter.character.toUpperCase()}');
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('magical_search_${widget.letter.character}', 10);
    } else {
      if (widget.letter.character.toUpperCase() == 'Ñ') {
        _nAttempts++;
        if (_nAttempts >= 3) {
          _audioService.speakText('${obj['name']} no empieza con Ñ. Toca el ícono de la estrella para jugar a trazar la letra Ñ.');
        } else {
          _audioService.speakText('${obj['name']} no empieza con Ñ. ¡Sigue intentando!');
        }
      } else {
        _audioService.speakText('¡Inténtalo de nuevo! ${obj['name']} no empieza con ${widget.letter.character.toUpperCase()}');
      }
    }
  }

  Widget _buildMagicalColoringGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple[50]!,
            Colors.pink[50]!,
            Colors.orange[50]!,
            Colors.yellow[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Título mágico con efectos rainbow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[400]!,
                  Colors.pink[400]!,
                  Colors.orange[400]!,
                  Colors.yellow[400]!,
                  Colors.green[400]!,
                  Colors.blue[400]!,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              '🌈✨ ¡JUEGO MÁGICO DE COLOREAR! ✨🌈',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          // Subtítulo mágico
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink[200]!,
                  Colors.purple[200]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple[300]!,
                width: 2,
              ),
            ),
            child: Text(
              '🎨 ¡Toca los colores mágicos para pintar la letra ${widget.letter.character.toUpperCase()}! 🌟',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          
          // Paleta de colores mágicos
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMagicalColorButton(Colors.red, '❤️'),
                _buildMagicalColorButton(Colors.orange, '🧡'),
                _buildMagicalColorButton(Colors.yellow, '💛'),
                _buildMagicalColorButton(Colors.green, '💚'),
                _buildMagicalColorButton(Colors.blue, '💙'),
                _buildMagicalColorButton(Colors.purple, '💜'),
                _buildMagicalColorButton(Colors.pink, '🩷'),
                _buildMagicalColorButton(Colors.brown, '🤎'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Área de colorear con la letra gigante
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () => _colorLetter(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.letter.character.toUpperCase(),
                      style: TextStyle(
                        fontSize: 200,
                        fontWeight: FontWeight.w900,
                        color: _selectedColor ?? Colors.grey[300],
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _selectedColor;

  Widget _buildMagicalColorButton(Color color, String emoji) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        _audioService.speakText('¡${_getColorName(color)} seleccionado!');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[300]!,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
              spreadRadius: isSelected ? 3 : 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Rojo';
    if (color == Colors.orange) return 'Naranja';
    if (color == Colors.yellow) return 'Amarillo';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.blue) return 'Azul';
    if (color == Colors.purple) return 'Morado';
    if (color == Colors.pink) return 'Rosa';
    if (color == Colors.brown) return 'Marrón';
    return 'Color';
  }

  void _colorLetter() {
    if (_selectedColor != null) {
      _audioService.speakText('¡Qué hermoso quedó! ¡Excelente trabajo!');
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('magical_coloring_${widget.letter.character}', 25);
    } else {
      _audioService.speakText('¡Primero selecciona un color mágico!');
    }
  }

  Widget _buildFindAllLettersGame() {
    // Generar grid solo si no existe o si cambió el juego
    if (_lettersGrid == null) {
      _lettersGrid = _generateLetterGrid();
    }
    final letters = _lettersGrid!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.pink[50]!,
            Colors.orange[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink[300]!,
                  Colors.orange[300]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Busca y marca todas las letras "${widget.letter.character.toUpperCase()}"',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Casillero de progreso compacto con 8 círculos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[100]!,
                  Colors.pink[100]!,
                  Colors.orange[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.purple[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Busca y marca todas las ${widget.letter.character.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
                const SizedBox(height: 8),
                // Casillero compacto con 8 círculos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purple[200]!,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (index) {
                        int foundCount = _lettersGrid?.where((l) => l['isTarget'] == true && l['found'] == true).length ?? 0;
                        bool isCompleted = index < foundCount;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted 
                                    ? _getColorForIndex(index)
                                    : Colors.white,
                                border: Border.all(
                                  color: isCompleted ? _getColorForIndex(index) : Colors.grey[400]!,
                                  width: 2,
                                ),
                                boxShadow: isCompleted ? [
                                  BoxShadow(
                                    color: _getColorForIndex(index).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isCompleted 
                                    ? Text(
                                        widget.letter.character.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      )
                                    : null, // Casillero vacío
                              ),
                          );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Mensaje de progreso compacto
                () {
                  int foundCount = _lettersGrid?.where((l) => l['isTarget'] == true && l['found'] == true).length ?? 0;
                  return Text(
                    foundCount < 8 
                        ? '${foundCount}/8 ¡Faltan ${8 - foundCount}! 🌟'
                        : '¡COMPLETADO! 🎉✨',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: foundCount < 8 ? Colors.orange[700] : Colors.green[700],
                    ),
                    textAlign: TextAlign.center,
                  );
                }(),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letterData = letters[index];
                  return _buildMagicalCubeLetter(letterData);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewStyleLetter(Map<String, dynamic> letterData) {
    final letter = letterData['letter'] as String;
    final isTarget = letterData['isTarget'] as bool;
    final isFound = letterData['found'] as bool? ?? false;
    final isWeb = MediaQuery.of(context).size.width > 800;
    final fontSize = isWeb ? 50.0 : 36.0;

    return GestureDetector(
      onTap: () => _handleLetterFind(letterData),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.lightBlue[200]!,
                Colors.blue[300]!,
                Colors.blue[500]!,
                Colors.blue[700]!,
                Colors.indigo[800]!,
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              // Sombra exterior azul brillante
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 6,
              ),
              // Sombra cyan brillante
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.6),
                blurRadius: 15,
                offset: const Offset(0, -5),
                spreadRadius: 3,
              ),
              // Resplandor exterior tipo neón
              BoxShadow(
                color: Colors.lightBlue.withValues(alpha: 0.7),
                blurRadius: 30,
                offset: const Offset(0, 0),
                spreadRadius: 12,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Brillo superior adicional
              Positioned(
                top: 6,
                left: 6,
                right: 6,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Letra central
              Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: fontSize * 1.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue[100],
                    letterSpacing: 3,
                    shadows: [
                      // Sombra profunda azul
                      Shadow(
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                        color: Colors.blue[900]!,
                      ),
                      // Sombra media
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 6,
                        color: Colors.blue[700]!,
                      ),
                      // Brillo cyan superior
                      Shadow(
                        offset: const Offset(-2, -2),
                        blurRadius: 8,
                        color: Colors.cyan[300]!,
                      ),
                      // Resplandor exterior
                      Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 15,
                        color: Colors.lightBlue[200]!,
                      ),
                    ],
                  ),
                ),
              ),
              // Checkmark verde cuando se encuentra
              if (isFound && isTarget)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
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

  Widget _buildMagicalCubeLetter(Map<String, dynamic> letterData) {
    final letter = letterData['letter'] as String;
    final isTarget = letterData['isTarget'] as bool;
    final isFound = letterData['found'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _handleLetterFind(letterData),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isFound 
                ? (isTarget ? Colors.green : Colors.red)
                : Colors.purple[300]!,
            width: isFound ? 4 : 3,
          ),
          boxShadow: [
            // Sombra mágica principal
            BoxShadow(
              color: isFound 
                  ? (isTarget 
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.red.withValues(alpha: 0.6))
                  : Colors.purple.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 3,
            ),
            // Resplandor mágico exterior
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 0),
              spreadRadius: 8,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFound && isTarget
                  ? [
                      Colors.green[200]!, 
                      Colors.green[400]!,
                      Colors.green[600]!,
                    ]
                  : isFound
                      ? [
                          Colors.red[200]!, 
                          Colors.red[400]!,
                          Colors.red[600]!,
                        ]
                      : [
                          Colors.pink[100]!,
                          Colors.pink[300]!,
                          Colors.orange[300]!,
                          Colors.orange[500]!,
                          Colors.purple[400]!,
                        ],
              stops: isFound ? const [0.0, 0.5, 1.0] : const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // Brillo interior superior
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(-3, -3),
              ),
              // Sombra interior inferior
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decoración de casillero mágico - esquinas brillantes
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Líneas decorativas mágicas
              Positioned(
                top: 15,
                left: 15,
                right: 15,
                height: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              
              // Letra central con efecto mágico
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        // Sombra profunda
                        Shadow(
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                        // Brillo superior
                        Shadow(
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        // Resplandor mágico
                        Shadow(
                          offset: const Offset(0, 0),
                          blurRadius: 12,
                          color: Colors.cyan.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Estrellitas mágicas en las esquinas cuando no está encontrado
              if (!isFound) ...[
                Positioned(
                  top: 5,
                  left: 5,
                  child: Text('✨', style: TextStyle(fontSize: 12)),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Text('✨', style: TextStyle(fontSize: 12)),
                ),
              ],
              
              // Checkmark mágico cuando se encuentra correctamente
              if (isFound && isTarget)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.green[400]!, Colors.green[700]!],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              // X mágico cuando es incorrecto
              if (isFound && !isTarget)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.red[400]!, Colors.red[700]!],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para obtener diferentes colores para cada casillero
  Color _getColorForIndex(int index) {
    final colors = [
      Colors.red[500]!,       // 1er casillero - rojo
      Colors.orange[500]!,    // 2do casillero - naranja  
      Colors.yellow[600]!,    // 3er casillero - amarillo
      Colors.green[500]!,     // 4to casillero - verde
      Colors.blue[500]!,      // 5to casillero - azul
      Colors.purple[500]!,    // 6to casillero - púrpura
      Colors.pink[500]!,      // 7mo casillero - rosa
      Colors.teal[500]!,      // 8vo casillero - verde azulado
    ];
    return colors[index % colors.length];
  }

  void _handleLetterFind(Map<String, dynamic> letterData) {
    setState(() {
      letterData['found'] = true;
    });

    // Debug: verificar el estado
    final foundCount = _lettersGrid?.where((l) => l['isTarget'] == true && l['found'] == true).length ?? 0;
    print('DEBUG: Letra encontrada: ${letterData['letter']}, Es target: ${letterData['isTarget']}, Total encontradas: $foundCount');

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
              color: Colors.white.withValues(alpha: 0.9),
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
                      fontSize: 20,
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
                              widget.letter.primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.letter.primaryColor.withValues(alpha: 0.4),
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
        {'emoji': '🚗', 'name': 'Auto', 'correct': true},
        {'emoji': '🏠', 'name': 'Armario', 'correct': true},
        {'emoji': '🐝', 'name': 'Abeja', 'correct': true},
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
        {'emoji': '🥕', 'name': 'Cebolla', 'correct': true},
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
        {'emoji': '🍄', 'name': 'Hongo', 'correct': true},
        {'emoji': '🔨', 'name': 'Herramienta', 'correct': true},
        {'emoji': '🐹', 'name': 'Hámster', 'correct': true},
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
        {'emoji': '🧉', 'name': 'Mate', 'correct': true},
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
        {'emoji': '⌚', 'name': 'Watch', 'correct': false},
        {'emoji': '💻', 'name': 'Windows', 'correct': false},
        {'emoji': '🌍', 'name': 'Mundo', 'correct': false},
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
        {'emoji': '🍲', 'name': 'Ñoquis', 'correct': true},
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
      {'emoji': '🚗', 'name': 'Auto', 'correct': false},
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
    
    // Agregar exactamente 8 letras target para completar el casillero
    for (int i = 0; i < 8; i++) {
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
    
    for (int i = 0; i < 40; i++) {
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
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⭐ ¡EXCELENTE! ⭐',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '🎉 ¡Muy bien hecho! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Eliminar automáticamente después de 2 segundos
    Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // ignore: unused_element
  void _showSuccessMessage(String wordName) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎯 ¡CORRECTO!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Encontraste $wordName!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Eliminar automáticamente después de 1.5 segundos
    Timer(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }

  // MÉTODO PARA FEEDBACK CUANDO FALLA (ROJO)
  void _showFailureFeedback() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '❌ ¡INTÉNTALO DE NUEVO!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Sigue intentando! 💪',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Eliminar automáticamente después de 1 segundo
    Timer(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  Widget _buildSpecialGame() {
    final letterChar = widget.letter.character;
    
    switch (letterChar) {
      case 'B':
        return _buildFindObjectsGame(); // Juego de búsqueda de objetos con B
      case 'V':
        return _buildColoringGame(); // Juego de colorear objetos con V
      case 'K':
        return _buildCompletionGame(); // Juego de completar palabras con K
      case 'Y':
        return _buildWordCompletionGame(); // Juego completar _ATE, _OGUR etc
      case 'Ñ':
        return _buildSpecialCompletionGame(); // Juego completar TA_I, SA_O 
      case 'W':
        return _buildDigitalSelectionGame(); // Juego digital de selección
      default:
        return _buildObjectSelectionGame();
    }
  }

  Widget _buildFindObjectsGame() {
    // Juego basado en imagen #2 - Buscar objetos que empiecen con B - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    
    // Añadir narración de voz para la letra B
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Hola! Vamos a jugar con la letra B. En este juego tienes que trazar la letra B para completar palabras que empiecen con B. ¡Observa bien cada imagen y completa las palabras!');
    });
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.orange[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🔍 ¡EL QUE BUSCA ENCUENTRA! OBSERVA DETENIDAMENTE',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA QUE EMPIECE CON "B"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _WordTracingGameB(),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameB() {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final words = ['_ARCO', '_EBÉ', '_ALDE', '_OTELLA', '_ICICLETA'];
    final completedWords = ['BARCO', 'BEBÉ', 'BALDE', 'BOTELLA', 'BICICLETA'];
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCard(
            words[index], 
            completedWords[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCard(String incompleteWord, String completeWord, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIcon(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra B
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[400]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: completeWord[0],
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Excelente! Completaste la palabra $completeWord. ¡Eres fantástico!');
                  },
                  audioService: _audioService,
                ),
              ),
              Text(
                incompleteWord.substring(1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIcon(String word) {
    switch (word) {
      case 'BARCO': return '🚢';
      case 'BEBÉ': return '👶';
      case 'BALDE': return '🪣';
      case 'BOTELLA': return '🍼';
      case 'BICICLETA': return '🚲';
      default: return '📝';
    }
  }

  Widget _buildColoringGame() {
    // Juego basado en imagen #1 - Colorear objetos que empiecen con V - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    // Añadir narración de voz para la letra V
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Bienvenido al juego de la letra V! Aquí vamos a completar palabras que empiecen con V. Traza la letra V en cada casilla y descubre palabras fantásticas. ¡Es muy divertido!');
    });
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.color_lens, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎨 TRAZA PARA COMPLETAR PALABRAS CON "V"',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA QUE EMPIECE CON \"V\"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _WordTracingGameV(isPhone: isPhone),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameV({required bool isPhone}) {
    final words = ['_ACA', '_ASO', '_IOLÍN', '_ELERO', '_ENTANA'];
    final completedWords = ['VACA', 'VASO', 'VIOLÍN', 'VELERO', 'VENTANA'];
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCardV(
            words[index], 
            completedWords[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCardV(String incompleteWord, String completeWord, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIconV(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra V
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[400]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: completeWord[0],
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Fantástico! Completaste la palabra $completeWord. ¡Eres increíble!');
                  },
                  audioService: _audioService,
                ),
              ),
              Text(
                incompleteWord.substring(1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIconV(String word) {
    switch (word) {
      case 'VACA': return '🐄';
      case 'VASO': return '🥤';
      case 'VIOLÍN': return '🎻';
      case 'VELERO': return '⛵';
      case 'VENTANA': return '🪟';
      default: return '📝';
    }
  }

  Widget _buildCompletionGame() {
    // Juego basado en imagen #3 - Completar palabras que empiecen con K - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    // Añadir narración de voz cuando se construye el juego
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Hola! En este juego vamos a completar palabras que empiecen con la letra K. Traza la letra K en cada casilla para completar las palabras. ¡Vamos a comenzar!');
    });
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.purple[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.extension, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🧩 TRAZA PARA COMPLETAR PALABRAS CON \"K\"',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA QUE EMPIECE CON \"K\"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _WordTracingGameK(isPhone: isPhone),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameK({required bool isPhone}) {
    final words = ['_IWI', '_ARATE', '_OALA', '_IOSCO'];
    final completedWords = ['KIWI', 'KARATE', 'KOALA',  'KIOSCO'];
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCardK(
            words[index], 
            completedWords[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCardK(String incompleteWord, String completeWord, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIconK(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra K
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[400]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: completeWord[0],
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Excelente! Completaste la palabra $completeWord. ¡Qué bien lo hiciste!');
                  },
                  audioService: _audioService,
                ),
              ),
              Text(
                incompleteWord.substring(1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIconK(String word) {
    switch (word) {
      case 'KIWI': return '🥝';
      case 'KARATE': return '🥋';
      case 'KOALA': return '🐨';

      case 'KIOSCO': return '🏪';
      default: return '📝';
    }
  }

  Widget _buildWordCompletionGame() {
    // Juego para la letra Y - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    // Añadir narración de voz para la letra Y
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Bienvenido al juego de la letra Y! Aquí vamos a completar palabras que empiecen con Y. Traza la letra Y en cada casilla y descubre palabras fantásticas. ¡Empecemos!');
    });
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.yellow[600],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🏆 TRAZA PARA COMPLETAR PALABRAS CON \"Y\"',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA QUE EMPIECE CON \"Y\"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _WordTracingGameY(isPhone: isPhone),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameY({required bool isPhone}) {
    final words = ['_ATE', '_OGUR', '_ERBA', '_EMA', ];
    final completedWords = ['YATE', 'YOGUR', 'YERBA', 'YEMA', ];
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCardY(
            words[index], 
            completedWords[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCardY(String incompleteWord, String completeWord, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIconY(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra Y
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow[600]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: completeWord[0],
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Perfecto! Completaste la palabra $completeWord. ¡Qué inteligente eres!');
                  },
                  audioService: _audioService,
                ),
              ),
              Text(
                incompleteWord.substring(1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIconY(String word) {
    switch (word) {
      case 'YATE': return '🛥️';
      case 'YOGUR': return '🍦';
      case 'YERBA': return '🧉';
      case 'YEMA': return '🥚';

      default: return '📝';
    }
  }

  Widget _buildSpecialCompletionGame() {
    // Juego para la letra Ñ - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    // Añadir narración de voz para la letra Ñ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Hola! Este es el juego especial de la letra Ñ. La Ñ es una letra muy especial del español. Vamos a completar palabras que tienen la letra Ñ. ¡Comencemos a trazar!');
    });
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.brown[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.brown[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '❤️ TRAZA PARA COMPLETAR PALABRAS CON \"Ñ\"',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.brown[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA CON \"Ñ\"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _WordTracingGameN(isPhone: isPhone),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameN({required bool isPhone}) {
    final words = ['A_O', 'BA_O', 'NI_O', 'SO_AR', 'SUE_O'];
    final completedWords = ['AÑO', 'BAÑO', 'NIÑO', 'SOÑAR', 'SUEÑO'];
    final positions = [1, 2, 2, 2, 3]; // Posición de la Ñ en cada palabra
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.brown[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCardN(
            words[index], 
            completedWords[index],
            positions[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCardN(String incompleteWord, String completeWord, int nPosition, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIconN(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra Ñ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Parte inicial de la palabra
              if (nPosition > 0)
                Text(
                  completeWord.substring(0, nPosition),
                  style: TextStyle(
                    fontSize: isPhone ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              // Área de trazado para la Ñ
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown[400]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: '\u00D1',
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Maravilloso! Completaste la palabra $completeWord. ¡La Ñ es muy especial!');
                  },
                  audioService: _audioService,
                ),
              ),
              // Parte final de la palabra
              Text(
                completeWord.substring(nPosition + 1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIconN(String word) {
    switch (word) {
      case 'AÑO': return '📅';
      case 'BAÑO': return '🛁';
      case 'NIÑO': return '🧒';
      case 'SOÑAR': return '💭';
      case 'SUEÑO': return '😴';
      default: return '📝';
    }
  }

  Widget _buildDigitalSelectionGame() {
    // Juego para la letra W - RESPONSIVO
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final iconSize = isPhone ? 48.0 : 64.0;
    final titleSize = isPhone ? 18.0 : 24.0;
    final instructionSize = isPhone ? 16.0 : 20.0;
    
    // Añadir narración de voz para la letra W
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.speakText('¡Hola! Bienvenido al juego de la letra W. La W es una letra especial que usamos en palabras de otros idiomas. Vamos a completar palabras que tienen W. ¡Empecemos a trazar!');
    });
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.indigo[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.wifi, color: Colors.white, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📱 TRAZA PARA COMPLETAR PALABRAS CON \"W\"',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[200]!, width: 2),
            ),
            child: Text(
              'TRAZA PARA COMPLETAR CADA PALABRA QUE EMPIECE CON \"W\"',
              style: TextStyle(
                fontSize: instructionSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _WordTracingGameW(isPhone: isPhone),
          ),
        ],
      ),
    );
  }

  Widget _WordTracingGameW({required bool isPhone}) {
    final words = ['_IFI', '_EB', '_EBCAM', '_ALKIE', '_ISKEY'];
    final completedWords = ['WIFI', 'WEB', 'WEBCAM', 'WALKIE', 'WISKEY'];
    
    return Container(
      padding: EdgeInsets.all(isPhone ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo[200]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 3.5 : 4.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordTracingCardW(
            words[index], 
            completedWords[index],
            index,
            isPhone
          );
        },
      ),
    );
  }

  Widget _buildWordTracingCardW(String incompleteWord, String completeWord, int index, bool isPhone) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono o emoji grande representativo
          Flexible(
            child: Text(
              _getWordIconW(completeWord),
              style: TextStyle(fontSize: isPhone ? 32 : 48),
            ),
          ),
          SizedBox(height: isPhone ? 4 : 6),
          // Palabra a completar con área de trazado para la letra W
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPhone ? 40 : 60,
                height: isPhone ? 50 : 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo[400]!, width: 2),
                ),
                child: MiniTracingCanvas(
                  letter: completeWord[0],
                  onTracingComplete: () {
                    _showFlowerRainEffect();
                    _audioService.speakText('¡Genial! Completaste la palabra $completeWord. ¡Excelente trabajo!');
                  },
                  audioService: _audioService,
                ),
              ),
              Text(
                incompleteWord.substring(1),
                style: TextStyle(
                  fontSize: isPhone ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getWordIconW(String word) {
    switch (word) {
      case 'WIFI': return '📶';
      case 'WEB': return '🌐';
      case 'WEBCAM': return '📹';
      case 'WALKIE': return '📻';
      case 'WISKEY': return '🥃';
      default: return '📝';
    }
  }

  Widget _buildSoundRecognitionGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Juego de sonidos próximamente',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showFlowerRainEffect() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => FlowerRainWidget(
        onAnimationComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

class FlowerRainWidget extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  
  const FlowerRainWidget({
    Key? key,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<FlowerRainWidget> createState() => _FlowerRainWidgetState();
}

class _FlowerRainWidgetState extends State<FlowerRainWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<FlowerParticle> _flowers;
  final int _flowerCount = 15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _initializeFlowers();
    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  void _initializeFlowers() {
    final size = MediaQuery.of(context).size;
    _flowers = List.generate(_flowerCount, (index) {
      return FlowerParticle(
        startX: (size.width * 0.1) + (size.width * 0.8 * index / _flowerCount),
        startY: -50.0,
        endY: size.height + 100,
        delay: index * 0.15,
        emoji: ['🌸', '🌺', '🌻', '🌷', '🌹', '🌼', '🍀', '🌿'][index % 8],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _flowers.map((flower) {
              final progress = (_controller.value - flower.delay).clamp(0.0, 1.0);
              final y = flower.startY + (flower.endY - flower.startY) * progress;
              final opacity = progress > 0.8 ? (1.0 - progress) * 5 : 1.0;
              
              if (progress <= 0) return const SizedBox.shrink();
              
              return Positioned(
                left: flower.startX + math.sin(progress * math.pi * 2) * 25,
                top: y,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: progress * math.pi * 2,
                    child: Text(
                      flower.emoji,
                      style: TextStyle(
                        fontSize: 28 + math.sin(progress * math.pi * 3) * 6,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class FlowerParticle {
  final double startX;
  final double startY;
  final double endY;
  final double delay;
  final String emoji;

  FlowerParticle({
    required this.startX,
    required this.startY,
    required this.endY,
    required this.delay,
    required this.emoji,
  });
}
