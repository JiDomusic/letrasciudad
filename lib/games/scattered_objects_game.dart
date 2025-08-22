import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_service.dart';

/// Juego de objetos dispersos al estilo de la imagen
/// Busca objetos que empiecen con la letra seleccionada
class ScatteredObjectsGame extends StatefulWidget {
  final String currentLetter;
  final AudioService audioService;

  const ScatteredObjectsGame({
    super.key,
    required this.currentLetter,
    required this.audioService,
  });

  @override
  State<ScatteredObjectsGame> createState() => _ScatteredObjectsGameState();
}

class _ScatteredObjectsGameState extends State<ScatteredObjectsGame>
    with TickerProviderStateMixin {
  late String _currentLetter;
  late List<Map<String, dynamic>> _allObjects;
  late Set<String> _foundObjects;
  late int _totalTargets;
  late AnimationController _successController;
  late AnimationController _rotationController;
  late Animation<double> _successAnimation;
  late Animation<double> _rotationAnimation;
  bool _animationsCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentLetter = widget.currentLetter.toUpperCase();
    _foundObjects = {};
    _setupAnimations();
    _generateObjects();
    _speakInstructions();
  }

  @override
  void didUpdateWidget(ScatteredObjectsGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLetter != widget.currentLetter) {
      _currentLetter = widget.currentLetter.toUpperCase();
      _foundObjects.clear();
      _animationsCompleted = false;
      _rotationController.reset();
      _generateObjects();
      _speakInstructions();
      
      // Reiniciar animaciones para nueva letra
      Future.delayed(const Duration(milliseconds: 500), () {
        _rotationController.forward().then((_) {
          setState(() {
            _animationsCompleted = true;
          });
        });
      });
    }
  }

  void _setupAnimations() {
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _successAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );
    
    // Iniciar animaciones de entrada
    Future.delayed(const Duration(milliseconds: 500), () {
      _rotationController.forward().then((_) {
        setState(() {
          _animationsCompleted = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _speakInstructions() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final instructions = _getDetailedInstructions(_currentLetter);
      widget.audioService.speakText(instructions);
    });
  }
  
  String _getDetailedInstructions(String letter) {
    // Instrucciones específicas y más humanas para cada letra
    const specialLetters = {'W', 'V', 'B', 'Y', 'X', 'K', 'Ñ'};
    
    if (specialLetters.contains(letter)) {
      switch (letter) {
        case 'W':
          return '¡Hola! Vamos a buscar cosas que empiecen con la letra W. Es una letra especial que viene del inglés. Mirá por toda la pantalla y encontrá objetos como WhatsApp, Web o WiFi. ¡Tocá cada uno que veas!';
        case 'V':
          return '¡Qué divertido! Ahora buscamos la letra V. Mirá alrededor y encontrá cosas como Vaca, Vaso o Violín. La V es como dos líneas que se juntan. ¡Tocá todos los que empiecen con V!';
        case 'B':
          return '¡Genial! Es el turno de la letra B. Buscá por todos lados objetos que empiecen con B, como Banana, Bus o Bicicleta. La B tiene dos pancitas, ¿te acordás? ¡Tocá todo lo que veas con B!';
        case 'Y':
          return '¡Fantástico! Vamos con la letra Y. Es como un árbol con dos ramas. Buscá y tocá cosas como Yate, Yoga o Yo-yo. Mirá bien por toda la pantalla, están esperándote!';
        case 'X':
          return '¡Súper! Ahora la letra X, que es como dos líneas que se cruzan haciendo un abrazo. Buscá Xilófono, Examen o México. Son un poquito más difíciles de encontrar, ¡pero vos podés!';
        case 'K':
          return '¡Qué inteligente sos! La letra K es especial y viene de otros idiomas. Buscá cosas como Koala, Kiwi o Kayak. Mirá bien por toda la pantalla, ¡están escondidos esperándote!';
        case 'Ñ':
          return '¡La letra más especial de todas! La Ñ con su sombrerito. Buscá cosas como Ñoquis, que son muy ricos, o palabras que tengan Ñ como Niño. ¡Es nuestra letra argentina favorita!';
        default:
          return 'Buscá y tocá todos los objetos que empiecen con $_currentLetter. Mirá bien por toda la pantalla, ¡están esperándote!';
      }
    } else {
      // Instrucciones más humanas para letras normales
      final randomIntros = [
        '¡Hola pequeño explorador!',
        '¡Qué emocionante!',
        '¡Muy bien!',
        '¡Excelente!',
        '¡Genial!'
      ];
      
      final randomInstructions = [
        'Ahora vamos a buscar la letra $_currentLetter. Mirá por toda la pantalla y tocá todos los objetos que empiecen con esta letra.',
        'Es el turno de la letra $_currentLetter. Buscá cuidadosamente y tocá cada cosa que empiece con $_currentLetter.',
        'Vamos a encontrar la letra $_currentLetter. Explorá la pantalla y tocá todo lo que veas que empiece con $_currentLetter.',
      ];
      
      final intro = randomIntros[DateTime.now().millisecondsSinceEpoch % randomIntros.length];
      final instruction = randomInstructions[DateTime.now().millisecondsSinceEpoch % randomInstructions.length];
      
      return '$intro $instruction ¡Vos podés!';
    }
  }

  void _generateObjects() {
    final objectsData = _getObjectsForLetter(_currentLetter);
    
    // Obtener 6 objetos correctos y 6 distractores
    final correctObjects = objectsData
        .where((obj) => obj['correct'] == true)
        .take(6)
        .toList();
    
    final incorrectObjects = objectsData
        .where((obj) => obj['correct'] == false)
        .take(6)
        .toList();

    _allObjects = [...correctObjects, ...incorrectObjects];
    _totalTargets = correctObjects.length;
    
    setState(() {});
  }

  void _onObjectTapped(Map<String, dynamic> object) {
    if (_foundObjects.contains(object['name'])) return;

    if (object['correct'] == true) {
      setState(() {
        _foundObjects.add(object['name'] as String);
      });
      
      _successController.forward().then((_) {
        _successController.reset();
      });
      
      // Feedback más variado y humano
      final encouragements = [
        '¡Súper! ${object['name']} empieza con $_currentLetter',
        '¡Excelente! Encontraste ${object['name']}',
        '¡Muy bien! ${object['name']} es perfecto',
        '¡Genial! ${object['name']} está correcto',
        '¡Fantástico! ${object['name']} empieza con $_currentLetter',
        '¡Qué inteligente! ${object['name']} es la respuesta correcta'
      ];
      final randomMessage = encouragements[DateTime.now().millisecondsSinceEpoch % encouragements.length];
      widget.audioService.speakText(randomMessage);
      
      if (_foundObjects.length == _totalTargets) {
        _showCompletionDialog();
      }
    } else {
      // Efecto de error visual
      _showIncorrectFeedback(object);
      
      // Feedback de error más amable y educativo
      final corrections = [
        '¡Casi! Pero ${object['name']} no empieza con $_currentLetter. Seguí buscando, vos podés.',
        'Mm, ${object['name']} empieza con otra letra. ¡Intentá de nuevo, sos muy inteligente!',
        '¡Qué bueno que intentaste! Pero ${object['name']} no es con $_currentLetter. ¡Seguí explorando!',
        'No es ${object['name']} esta vez, pero estás aprendiendo genial. ¡Probá otro!',
        '${object['name']} empieza con otra letra. ¡No te preocupes, lo vas a encontrar!'
      ];
      final randomCorrection = corrections[DateTime.now().millisecondsSinceEpoch % corrections.length];
      widget.audioService.speakText(randomCorrection);
    }
  }

  void _showIncorrectFeedback(Map<String, dynamic> object) {
    // Mostrar feedback visual de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ "${object['name']}" no empieza con $_currentLetter'),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.green[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animación de estrellas
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡FELICITACIONES!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Encontraste todos los objetos que empiezan con "$_currentLetter"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '⭐ $_totalTargets de $_totalTargets objetos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Jugar otra vez'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
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
    
    // Audio de felicitación más humano y específico
    Future.delayed(const Duration(milliseconds: 500), () {
      final completionMessages = [
        '¡Sos una súper estrella! Encontraste todos los objetos con $_currentLetter. ¡Me encanta cómo aprendés!',
        '¡Increíble trabajo! Completaste toda la letra $_currentLetter. ¡Estoy súper orgullosa de vos!',
        '¡Fantástico! Sos un detective de letras genial. Encontraste todo lo que empezaba con $_currentLetter.',
        '¡Qué inteligente sos! Terminaste la letra $_currentLetter perfectamente. ¡Sos mi héroe!',
        '¡Excelente! Sos un campeón de las letras. $_currentLetter ya no tiene secretos para vos.'
      ];
      final randomMessage = completionMessages[DateTime.now().millisecondsSinceEpoch % completionMessages.length];
      widget.audioService.speakText(randomMessage);
    });
  }

  void _resetGame() {
    setState(() {
      _foundObjects.clear();
    });
    _generateObjects();
    widget.audioService.speakText('¡Empecemos de nuevo con la letra $_currentLetter!');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompleted = _foundObjects.length == _totalTargets;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue[100]!,
            Colors.lightGreen[100]!,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isCompleted),
          Expanded(
            child: _buildScatteredObjectsArea(size),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _currentLetter,
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Encontrá objetos con $_currentLetter',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${_foundObjects.length}/${_totalTargets}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScatteredObjectsArea(Size screenSize) {
    // Calcular zona de juego perfectamente segura
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final appBarHeight = AppBar().preferredSize.height;
    final bottomBarHeight = 80.0;
    final safeMargin = 60.0; // Margen más generoso para evitar bordes
    
    // Área de juego disponible (sin tocar nada)
    final gameAreaTop = safeAreaTop + appBarHeight + safeMargin;
    final gameAreaBottom = screenSize.height - bottomBarHeight - safeMargin;
    final gameAreaLeft = safeMargin;
    final gameAreaRight = screenSize.width - safeMargin;
    
    final gameWidth = gameAreaRight - gameAreaLeft;
    final gameHeight = gameAreaBottom - gameAreaTop;
    
    // Posiciones perfectamente separadas evitando cualquier superposición
    final positions = [
      const Offset(0.2, 0.15),  // Objeto 1 - izquierda superior
      const Offset(0.5, 0.15),  // Objeto 2 - centro superior  
      const Offset(0.8, 0.15),  // Objeto 3 - derecha superior
      const Offset(0.2, 0.4),   // Objeto 4 - izquierda centro
      const Offset(0.8, 0.4),   // Objeto 5 - derecha centro
      const Offset(0.2, 0.65),  // Objeto 6 - izquierda inferior
      
      // Distractores distribuidos con máxima separación
      const Offset(0.5, 0.4),   // Distractor 1 - centro exacto
      const Offset(0.35, 0.25), // Distractor 2 - centro-izquierda superior
      const Offset(0.65, 0.25), // Distractor 3 - centro-derecha superior
      const Offset(0.35, 0.55), // Distractor 4 - centro-izquierda inferior
      const Offset(0.65, 0.55), // Distractor 5 - centro-derecha inferior
      const Offset(0.5, 0.65),  // Distractor 6 - centro inferior
    ];

    return Stack(
      children: [
        // Fondo con nubes
        Positioned(
          top: 50,
          left: 50,
          child: Icon(Icons.cloud, size: 60, color: Colors.white.withValues(alpha: 0.7)),
        ),
        Positioned(
          top: 80,
          right: 80,
          child: Icon(Icons.cloud, size: 40, color: Colors.white.withValues(alpha: 0.6)),
        ),
        Positioned(
          top: 120,
          left: screenSize.width * 0.3,
          child: Icon(Icons.cloud, size: 50, color: Colors.white.withValues(alpha: 0.5)),
        ),
        
        // Objetos dispersos con tamaños responsivos
        ...List.generate(_allObjects.length, (index) {
          if (index >= positions.length) return Container();
          
          final object = _allObjects[index];
          final position = positions[index];
          final isFound = _foundObjects.contains(object['name']);
          
          // Tamaños responsivos optimizados evitando superposiciones
          final isTablet = screenSize.shortestSide >= 600;
          final isDesktop = screenSize.width >= 1200;
          
          final objectSize = isDesktop ? 120.0 : (isTablet ? 100.0 : 75.0);
          final emojiSize = isDesktop ? 60.0 : (isTablet ? 45.0 : 35.0);
          final textSize = isDesktop ? 16.0 : (isTablet ? 12.0 : 10.0);
          
          return AnimatedPositioned(
            duration: Duration(milliseconds: _animationsCompleted ? 300 : 1500),
            curve: _animationsCompleted ? Curves.easeInOut : Curves.bounceOut,
            left: gameAreaLeft + (gameWidth * position.dx) - (objectSize / 2),
            top: gameAreaTop + (gameHeight * position.dy) - (objectSize / 2),
            child: AnimatedBuilder(
              animation: Listenable.merge([_successAnimation, _rotationAnimation]),
              builder: (context, child) {
                final scale = isFound ? _successAnimation.value : 1.0;
                final rotation = _animationsCompleted ? 0.0 : _rotationAnimation.value;
                
                return Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () => _onObjectTapped(object),
                      child: Container(
                        width: objectSize,
                        height: objectSize,
                        decoration: BoxDecoration(
                          color: isFound 
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: isFound 
                            ? Border.all(color: Colors.green, width: 4)
                            : Border.all(color: Colors.grey[300]!, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isFound ? 0.3 : 0.1),
                              blurRadius: isFound ? 8 : 4,
                              offset: Offset(0, isFound ? 4 : 2),
                            ),
                          ],
                        ),
                        child: ClipRect(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Text(
                                  object['emoji'] as String,
                                  style: TextStyle(fontSize: emojiSize),
                                ),
                              ),
                              SizedBox(height: isDesktop ? 4 : (isTablet ? 2 : 1)),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  object['name'] as String,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: isFound ? FontWeight.bold : FontWeight.w600,
                                    color: isFound ? Colors.green[700] : Colors.black87,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isFound)
                                Flexible(
                                  flex: 1,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: isDesktop ? 24 : (isTablet ? 20 : 16),
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
        }),
      ],
    );
  }

  /// Obtiene objetos para una letra específica con vocabulario argentino mejorado
  List<Map<String, dynamic>> _getObjectsForLetter(String letter) {
    final objectsData = {
      'A': {
        'correct': [
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '👵', 'name': 'Abuela'},
          {'emoji': '💧', 'name': 'Agua'},
          {'emoji': '🌳', 'name': 'Árbol'},
          {'emoji': '💍', 'name': 'Anillo'},
          {'emoji': '✈️', 'name': 'Avión'},
        ],
        'incorrect': [
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🚌', 'name': 'Bus'},
          {'emoji': '⏰', 'name': 'Reloj'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🐱', 'name': 'Gato'},
          {'emoji': '🌙', 'name': 'Luna'},
        ]
      },
      'B': {
        'correct': [
          {'emoji': '🍌', 'name': 'Banana'},
          {'emoji': '🚌', 'name': 'Bus'},
          {'emoji': '🍼', 'name': 'Biberón'},
          {'emoji': '🚲', 'name': 'Bicicleta'},
          {'emoji': '⚽', 'name': 'Balón'},
          {'emoji': '🚢', 'name': 'Barco'},
        ],
        'incorrect': [
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🐻', 'name': 'Oso'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '⏰', 'name': 'Reloj'},
          {'emoji': '🌺', 'name': 'Girasol'},
          {'emoji': '🐱', 'name': 'Gato'},
        ]
      },
      'C': {
        'correct': [
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🚗', 'name': 'Coche'},
          {'emoji': '❤️', 'name': 'Corazón'},
          {'emoji': '🍒', 'name': 'Cereza'},
          {'emoji': '🐴', 'name': 'Caballo'},
          {'emoji': '🛏️', 'name': 'Cama'},
        ],
        'incorrect': [
          {'emoji': '🍌', 'name': 'Banana'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🎸', 'name': 'Guitarra'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🐻', 'name': 'Oso'},
        ]
      },
      'D': {
        'correct': [
          {'emoji': '👆', 'name': 'Dedo'},
          {'emoji': '🦕', 'name': 'Dinosaurio'},
          {'emoji': '🍬', 'name': 'Dulce'},
          {'emoji': '🎲', 'name': 'Dado'},
          {'emoji': '🦷', 'name': 'Diente'},
          {'emoji': '🐬', 'name': 'Delfín'},
        ],
        'incorrect': [
          {'emoji': '🚲', 'name': 'Bicicleta'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '🌈', 'name': 'Arcoíris'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'E': {
        'correct': [
          {'emoji': '🐘', 'name': 'Elefante'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🏫', 'name': 'Escuela'},
          {'emoji': '🪜', 'name': 'Escalera'},
          {'emoji': '💌', 'name': 'Envelope'},
          {'emoji': '🌱', 'name': 'Espiga'},
        ],
        'incorrect': [
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '🚁', 'name': 'Helicóptero'},
          {'emoji': '🍰', 'name': 'Torta'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'F': {
        'correct': [
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🔥', 'name': 'Fuego'},
          {'emoji': '👨‍👩‍👧‍👦', 'name': 'Familia'},
          {'emoji': '📸', 'name': 'Foto'},
          {'emoji': '🍓', 'name': 'Frutilla'},
          {'emoji': '🎪', 'name': 'Feria'},
        ],
        'incorrect': [
          {'emoji': '🎶', 'name': 'Música'},
          {'emoji': '🌍', 'name': 'Mundo'},
          {'emoji': '🎨', 'name': 'Arte'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🐱', 'name': 'Gato'},
        ]
      },
      'G': {
        'correct': [
          {'emoji': '🐱', 'name': 'Gato'},
          {'emoji': '🎈', 'name': 'Globo'},
          {'emoji': '🎸', 'name': 'Guitarra'},
          {'emoji': '🪱', 'name': 'Gusano'},
          {'emoji': '🥽', 'name': 'Gafas'},
          {'emoji': '🧤', 'name': 'Guantes'},
        ],
        'incorrect': [
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '📚', 'name': 'Libro'},
          {'emoji': '🚀', 'name': 'Cohete'},
          {'emoji': '🍎', 'name': 'Manzana'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌙', 'name': 'Luna'},
        ]
      },
      'H': {
        'correct': [
          {'emoji': '🧊', 'name': 'Hielo'},
          {'emoji': '🍃', 'name': 'Hoja'},
          {'emoji': '🥚', 'name': 'Huevo'},
          {'emoji': '👨', 'name': 'Hombre'},
          {'emoji': '🔨', 'name': 'Martillo'},
          {'emoji': '🐹', 'name': 'Hámster'},
        ],
        'incorrect': [
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '🍰', 'name': 'Pastel'},
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'I': {
        'correct': [
          {'emoji': '⛪', 'name': 'Iglesia'},
          {'emoji': '🧲', 'name': 'Imán'},
          {'emoji': '🏖️', 'name': 'Isla'},
          {'emoji': '🌈', 'name': 'Iris'},
          {'emoji': '🦎', 'name': 'Iguana'},
          {'emoji': '💡', 'name': 'Idea'},
        ],
        'incorrect': [
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🚲', 'name': 'Bicicleta'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🐱', 'name': 'Gato'},
          {'emoji': '🌙', 'name': 'Luna'},
        ]
      },
      'J': {
        'correct': [
          {'emoji': '🦒', 'name': 'Jirafa'},
          {'emoji': '🎮', 'name': 'Juego'},
          {'emoji': '🌻', 'name': 'Jardín'},
          {'emoji': '💎', 'name': 'Joya'},
          {'emoji': '🧴', 'name': 'Jabón'},
          {'emoji': '🍯', 'name': 'Jarabe'},
        ],
        'incorrect': [
          {'emoji': '🌊', 'name': 'Ola'},
          {'emoji': '🎨', 'name': 'Pincel'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'K': {
        'correct': [
          {'emoji': '🐨', 'name': 'Koala'},
          {'emoji': '🍅', 'name': 'Ketchup'},
          {'emoji': '⚖️', 'name': 'Kilo'},
          {'emoji': '👘', 'name': 'Kimono'},
          {'emoji': '🥝', 'name': 'Kiwi'},
          {'emoji': '🛶', 'name': 'Kayak'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '🌞', 'name': 'Sol'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '🍎', 'name': 'Manzana'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'L': {
        'correct': [
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '📖', 'name': 'Libro'},
          {'emoji': '✏️', 'name': 'Lápiz'},
          {'emoji': '🍋', 'name': 'Limón'},
          {'emoji': '🔍', 'name': 'Lupa'},
        ],
        'incorrect': [
          {'emoji': '🚢', 'name': 'Barco'},
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '🐱', 'name': 'Gato'},
        ]
      },
      'M': {
        'correct': [
          {'emoji': '👩', 'name': 'Mamá'},
          {'emoji': '🪑', 'name': 'Mesa'},
          {'emoji': '🍯', 'name': 'Miel'},
          {'emoji': '🍎', 'name': 'Manzana'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '⛰️', 'name': 'Montaña'},
        ],
        'incorrect': [
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🎈', 'name': 'Globo'},
          {'emoji': '📱', 'name': 'Teléfono'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'N': {
        'correct': [
          {'emoji': '👶', 'name': 'Niño'},
          {'emoji': '🍊', 'name': 'Naranja'},
          {'emoji': '🌃', 'name': 'Noche'},
          {'emoji': '☁️', 'name': 'Nube'},
          {'emoji': '🥜', 'name': 'Nuez'},
          {'emoji': '🪺', 'name': 'Nido'},
        ],
        'incorrect': [
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚲', 'name': 'Bicicleta'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'Ñ': {
        'correct': [
          {'emoji': '🍲', 'name': 'Ñoquis'},
          {'emoji': '💤', 'name': 'Sueño'},
          {'emoji': '👶', 'name': 'Niño'},
          {'emoji': '🪄', 'name': 'Caña'},
          {'emoji': '🎯', 'name': 'Señal'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '🌈', 'name': 'Arcoíris'},
          {'emoji': '🦋', 'name': 'Mariposa'},
        ]
      },
      'O': {
        'correct': [
          {'emoji': '🐻', 'name': 'Oso'},
          {'emoji': '👁️', 'name': 'Ojo'},
          {'emoji': '🐑', 'name': 'Oveja'},
          {'emoji': '🥇', 'name': 'Oro'},
          {'emoji': '🌊', 'name': 'Ola'},
          {'emoji': '👂', 'name': 'Oreja'},
        ],
        'incorrect': [
          {'emoji': '🎸', 'name': 'Guitarra'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🎈', 'name': 'Globo'},
          {'emoji': '📚', 'name': 'Libro'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'P': {
        'correct': [
          {'emoji': '👨', 'name': 'Papá'},
          {'emoji': '🏀', 'name': 'Pelota'},
          {'emoji': '🌲', 'name': 'Pino'},
          {'emoji': '🐔', 'name': 'Pollo'},
          {'emoji': '🍞', 'name': 'Pan'},
          {'emoji': '🐧', 'name': 'Pingüino'},
        ],
        'incorrect': [
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'Q': {
        'correct': [
          {'emoji': '🧀', 'name': 'Queso'},
          {'emoji': '🌾', 'name': 'Quinoa'},
          {'emoji': '❤️', 'name': 'Querer'},
          {'emoji': '5️⃣', 'name': 'Quinto'},
          {'emoji': '🔥', 'name': 'Quemar'},
          {'emoji': '🏠', 'name': 'Quiosco'},
        ],
        'incorrect': [
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚲', 'name': 'Bicicleta'},
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'R': {
        'correct': [
          {'emoji': '🐭', 'name': 'Ratón'},
          {'emoji': '🎁', 'name': 'Regalo'},
          {'emoji': '🏞️', 'name': 'Río'},
          {'emoji': '🌹', 'name': 'Rosa'},
          {'emoji': '👑', 'name': 'Rey'},
          {'emoji': '⏰', 'name': 'Reloj'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'S': {
        'correct': [
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🐍', 'name': 'Serpiente'},
          {'emoji': '🪑', 'name': 'Sillón'},
          {'emoji': '➕', 'name': 'Suma'},
          {'emoji': '🦢', 'name': 'Cisne'},
          {'emoji': '💤', 'name': 'Sueño'},
        ],
        'incorrect': [
          {'emoji': '🌙', 'name': 'Luna'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🎈', 'name': 'Globo'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'T': {
        'correct': [
          {'emoji': '🎂', 'name': 'Torta'},
          {'emoji': '📞', 'name': 'Teléfono'},
          {'emoji': '🐢', 'name': 'Tortuga'},
          {'emoji': '🚂', 'name': 'Tren'},
          {'emoji': '🐅', 'name': 'Tigre'},
          {'emoji': '📺', 'name': 'Televisión'},
        ],
        'incorrect': [
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'U': {
        'correct': [
          {'emoji': '🍇', 'name': 'Uva'},
          {'emoji': '🌌', 'name': 'Universo'},
          {'emoji': '🦄', 'name': 'Unicornio'},
          {'emoji': '1️⃣', 'name': 'Uno'},
          {'emoji': '🏙️', 'name': 'Urbano'},
          {'emoji': '📦', 'name': 'Usar'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'V': {
        'correct': [
          {'emoji': '🐄', 'name': 'Vaca'},
          {'emoji': '🥛', 'name': 'Vaso'},
          {'emoji': '🎻', 'name': 'Violín'},
          {'emoji': '⛵', 'name': 'Velero'},
          {'emoji': '🪟', 'name': 'Ventana'},
          {'emoji': '🌋', 'name': 'Volcán'},
        ],
        'incorrect': [
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🎈', 'name': 'Globo'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '🌸', 'name': 'Flor'},
        ]
      },
      'W': {
        'correct': [
          {'emoji': '📱', 'name': 'WhatsApp'},
          {'emoji': '🌐', 'name': 'Web'},
          {'emoji': '📶', 'name': 'WiFi'},
          {'emoji': '🎵', 'name': 'Walkman'},
          {'emoji': '🤠', 'name': 'Western'},
          {'emoji': '⌚', 'name': 'Watch'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'X': {
        'correct': [
          {'emoji': '🎼', 'name': 'Xilófono'},
          {'emoji': '📝', 'name': 'Examen'},
          {'emoji': '🇲🇽', 'name': 'México'},
          {'emoji': '💨', 'name': 'Oxígeno'},
          {'emoji': '❌', 'name': 'Equis'},
          {'emoji': '🎯', 'name': 'Exacto'},
        ],
        'incorrect': [
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🎨', 'name': 'Pintura'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '☀️', 'name': 'Sol'},
        ]
      },
      'Y': {
        'correct': [
          {'emoji': '🛥️', 'name': 'Yate'},
          {'emoji': '🧘', 'name': 'Yoga'},
          {'emoji': '🍳', 'name': 'Yema'},
          {'emoji': '🪀', 'name': 'Yo-yo'},
          {'emoji': '🌿', 'name': 'Yerba'},
          {'emoji': '👤', 'name': 'Yo'},
        ],
        'incorrect': [
          {'emoji': '🎪', 'name': 'Circo'},
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🚗', 'name': 'Auto'},
          {'emoji': '⭐', 'name': 'Estrella'},
          {'emoji': '🦁', 'name': 'León'},
          {'emoji': '🏠', 'name': 'Casa'},
        ]
      },
      'Z': {
        'correct': [
          {'emoji': '👟', 'name': 'Zapato'},
          {'emoji': '🦓', 'name': 'Cebra'},
          {'emoji': '🦊', 'name': 'Zorro'},
          {'emoji': '🌪️', 'name': 'Zona'},
          {'emoji': '🥕', 'name': 'Zanahoria'},
          {'emoji': '💎', 'name': 'Zafiro'},
        ],
        'incorrect': [
          {'emoji': '🎵', 'name': 'Música'},
          {'emoji': '🌸', 'name': 'Flor'},
          {'emoji': '🏠', 'name': 'Casa'},
          {'emoji': '🦋', 'name': 'Mariposa'},
          {'emoji': '☀️', 'name': 'Sol'},
          {'emoji': '🐱', 'name': 'Gato'},
        ]
      },
    };

    final letterData = objectsData[letter] ?? {'correct': [], 'incorrect': []};
    
    return [
      ...letterData['correct']!.map((obj) => {...obj, 'correct': true}),
      ...letterData['incorrect']!.map((obj) => {...obj, 'correct': false}),
    ];
  }
}