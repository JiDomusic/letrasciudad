import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../widgets/ar_overlay_widget.dart';
import '../widgets/letter_selector_widget.dart';
import 'syllable_game_screen.dart';
import '../services/gesture_detection_service.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class ARCityScreen extends StatefulWidget {
  const ARCityScreen({super.key});

  @override
  State<ARCityScreen> createState() => _ARCityScreenState();
}

class _ARCityScreenState extends State<ARCityScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showInstructions = true;
  final AudioService _audioService = AudioService();
  final GestureDetectionService _gestureService = GestureDetectionService();
  StreamSubscription<InteractionEvent>? _interactionSubscription;
  String? _highlightedLetter;
  double _houseScale = 1.0;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupGestureDetection();
    _playWelcomeMessage();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraError('No hay cámaras disponibles');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startImageStream();
      }
    } catch (e) {
      _showCameraError('Error al inicializar la cámara: $e');
    }
  }

  void _showCameraError(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de Cámara'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _audioService.speakText('¡Bienvenido a mi parque encantado! Soy Luna y he preparado kioscos especiales con cada letra. Mueve tu teléfono para pasear por todo el parque');
  }

  void _setupGestureDetection() {
    // Habilitar detección de gestos en todas las plataformas para VR
    _interactionSubscription = _gestureService.interactionStream.listen((event) {
      _handleInteractionEvent(event);
    });
  }

  void _startImageStream() {
    if (_cameraController?.value.isInitialized == true) {
      // Habilitar stream de imagen para todas las plataformas
      try {
        _cameraController!.startImageStream((image) {
          _gestureService.processImage(image, _cameraController!.description);
        });
      } catch (e) {
        debugPrint('Error starting image stream: $e');
        // En web, simular eventos de interacción para testing
        if (kIsWeb) {
          _simulateVRInteractions();
        }
      }
    }
  }

  void _simulateVRInteractions() {
    // Simular interacciones VR cada 3 segundos para testing en web
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final provider = context.read<LetterCityProvider>();
      if (provider.unlockedLetters.isNotEmpty) {
        // Simular detección de mano en posición aleatoria
        final randomPosition = Offset(
          0.3 + (math.Random().nextDouble() * 0.4), // Entre 0.3 y 0.7
          0.3 + (math.Random().nextDouble() * 0.4), // Entre 0.3 y 0.7
        );
        
        final event = InteractionEvent(
          type: InteractionType.handGesture,
          position: randomPosition,
          strength: 0.8,
          gestureType: HandGestureType.point,
        );
        
        _handleInteractionEvent(event);
        
        // Cancelar después de 10 simulaciones
        if (timer.tick >= 20) {
          timer.cancel();
        }
      }
    });
  }

  void _handleInteractionEvent(InteractionEvent event) {
    if (!mounted) return;

    final provider = context.read<LetterCityProvider>();
    final closestLetter = _findClosestLetterToPosition(
      event.position, 
      provider.unlockedLetters,
    );

    if (closestLetter != null) {
      setState(() {
        _highlightedLetter = closestLetter.character;
        // Escala SÚPER DRAMÁTICA para casas gigantes
        if (event.gestureType == HandGestureType.point || event.gestureType == HandGestureType.thumbsUp) {
          _houseScale = 1.5 + (event.strength * 1.5); // Escala de 1.5 a 3.0 - MUY GRANDE!
        } else {
          _houseScale = 1.2 + (event.strength * 1.2); // Escala de 1.2 a 2.4 - GRANDE!
        }
      });

      // Auto-seleccionar con gestos específicos o alta intensidad
      final shouldAutoSelect = event.strength > 0.6 || // Más sensible
                              event.gestureType == HandGestureType.point ||
                              event.gestureType == HandGestureType.thumbsUp;
                              
      if (shouldAutoSelect) {
        _onLetterTap(closestLetter.character);
        
        // Mensaje específico según el tipo de interacción
        String message = '¡Genial!';
        if (event.type == InteractionType.faceClose) {
          message = '¡Detecté tu cara! ¡Excelente!';
        } else if (event.gestureType == HandGestureType.point) {
          message = '¡Vi que estás señalando! ¡Perfecto!';
        } else if (event.gestureType == HandGestureType.thumbsUp) {
          message = '¡Me gusta tu pulgar arriba! ¡Súper!';
        } else if (event.gestureType == HandGestureType.openPalm) {
          message = '¡Veo tu mano abierta! ¡Genial!';
        } else {
          message = '¡Detecté tu mano! ¡Fantástico!';
        }
        _audioService.speakText(message);
      }

      // Resetear la escala después de un tiempo
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _highlightedLetter = null;
            _houseScale = 5.0;
          });
        }
      });
    }
  }

  dynamic _findClosestLetterToPosition(Offset position, List<dynamic> letters) {
    if (letters.isEmpty) return null;

    double minDistance = double.infinity;
    dynamic closestLetter;

    for (final letter in letters) {
      // Calcular distancia aproximada basada en la posición de la casa
      final letterIndex = letters.indexOf(letter);
      final housePosition = _calculateHouseScreenPosition(letterIndex);
      
      final distance = (housePosition - position).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestLetter = letter;
      }
    }

    // Radio más amplio para casas más grandes - más sensible
    return minDistance < 0.5 ? closestLetter : null;
  }

  Offset _calculateHouseScreenPosition(int index) {
    // Aproximación de la posición de la casa en pantalla (0-1)
    final angle = (index / 6) * 2 * 3.14159; // Distribución circular aproximada
    final radius = 0.3; // Radio normalizado
    
    return Offset(
      0.5 + radius * math.cos(angle),
      0.5 + radius * math.sin(angle) * 0.7,
    );
  }

  @override
  void dispose() {
    _interactionSubscription?.cancel();
    _cameraController?.dispose();
    _gestureService.dispose(); // Dispose en todas las plataformas
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(),
          if (_isCameraInitialized) _buildAROverlay(),
          _buildTopBar(),
          if (_showInstructions) _buildInstructionsOverlay(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando cámara...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildAROverlay() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTapDown: (details) {
            // Simular detección de mano en la posición del tap para testing
            final position = Offset(
              details.localPosition.dx / MediaQuery.of(context).size.width,
              details.localPosition.dy / MediaQuery.of(context).size.height,
            );
            
            final event = InteractionEvent(
              type: InteractionType.handGesture,
              position: position,
              strength: 0.9,
              gestureType: HandGestureType.point,
            );
            
            _handleInteractionEvent(event);
          },
          child: AROverlayWidget(
            letters: provider.unlockedLetters,
            onLetterTap: (letter) => _onLetterTap(letter.character),
            highlightedLetter: _highlightedLetter,
            houseScale: _houseScale,
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Parque AR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => _showHelp(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Realidad Aumentada!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mueve tu dispositivo para explorar la ciudad de letras en 3D. Toca las casas para acceder a las actividades.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  child: const Text('¡Explorar!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Consumer<LetterCityProvider>(
            builder: (context, provider, child) {
              return LetterSelectorWidget(
                letters: provider.unlockedLetters,
                onLetterSelected: (letter) => _onLetterTap(letter.character),
                selectedLetter: provider.selectedLetter,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onLetterTap(String character) async {
    final provider = context.read<LetterCityProvider>();
    provider.selectLetter(character);
    
    final letter = provider.getLetterByCharacter(character);
    if (letter != null) {
      await _audioService.playLetterSound(character);
      await _audioService.speakText('¡Genial! Has visitado el kiosco de la letra ${letter.name}. ¿Qué quieres hacer aquí?');
      
      if (mounted) {
        _showLetterOptions(letter);
      }
    }
  }

  void _showLetterOptions(dynamic letter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 20),
              
              // Cabecera con la letra
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [letter.primaryColor, letter.primaryColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: letter.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter.character,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Casa de la letra ${letter.character}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          letter.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (letter.stars > 0)
                          Row(
                            children: List.generate(
                              3,
                              (index) => Icon(
                                index < letter.stars ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Descripción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  '¡Hola! Soy Luna y vivo en esta casita. Aquí aprenderás todo sobre mi letra favorita: la ${letter.character}. ¡Vamos a jugar juntas!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botones de acción mejorados
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _audioService.playLetterSound(letter.character);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: letter.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.volume_up),
                      label: const Text(
                        'Escuchar mi sonido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        // TODO: Navegar a detalles de letra con actividades específicas
                        _showActivitiesMenu(letter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: letter.primaryColor,
                        side: BorderSide(color: letter.primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.games),
                      label: const Text(
                        'Ver actividades divertidas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Seguir explorando el parque',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivitiesMenu(dynamic letter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Actividades de la letra ${letter.character}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige qué quieres aprender conmigo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lista de actividades
              Column(
                children: [
                  _buildActivityTile(
                    icon: Icons.hearing,
                    title: 'Sonidos y Fonemas',
                    description: 'Aprende cómo suena mi letra',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _audioService.speakLetterIntroduction(
                        letter.character,
                        letter.character.toLowerCase(),
                        ['ejemplo', 'palabra'],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityTile(
                    icon: Icons.text_fields,
                    title: 'Formar Sílabas',
                    description: 'Combino con otras letras para hacer sílabas',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _startSyllableGame(letter);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityTile(
                    icon: Icons.book,
                    title: 'Palabras Divertidas',
                    description: 'Descubre palabras que empiezan conmigo',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      // Mensaje dinámico con palabras que realmente empiecen con la letra
                      final exampleWords = _getExampleWords(letter.character);
                      _audioService.speakText('¡Vamos a buscar palabras que empiecen con ${letter.character}! Como $exampleWords');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityTile(
                    icon: Icons.draw,
                    title: 'Trazar y Escribir',
                    description: 'Practica escribiendo mi forma',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      _audioService.speakText('¡Muy pronto podrás trazar mi forma! Esta función llegará pronto.');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Volver al parque',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExampleWords(String letter) {
    // Palabras correctas para cada letra
    final exampleWords = {
      'A': ['ala', 'abeja', 'árbol'],
      'B': ['bola', 'burro', 'barco'],
      'C': ['casa', 'carro', 'caballo'], // CORREGIDO: ahora están en la letra correcta
      'D': ['dado', 'dedo', 'diente'],
      'E': ['elefante', 'estrella', 'escuela'],
      'F': ['foca', 'flor', 'fuego'],
      'G': ['gato', 'gallo', 'globo'],
      'H': ['hola', 'hoja', 'helado'],
      'I': ['isla', 'iguana', 'imán'],
      'J': ['jirafa', 'jardín', 'jugo'],
      'K': ['kiwi', 'karate', 'kilo'],
      'L': ['luna', 'león', 'libro'],
      'M': ['mama', 'mono', 'mesa'],
      'N': ['nube', 'nariz', 'nido'],
      'Ñ': ['niño', 'ñame', 'ñu'],
      'O': ['oso', 'ojo', 'oreja'],
      'P': ['papa', 'pez', 'perro'],
      'Q': ['queso', 'quinoa', 'quetzal'],
      'R': ['rosa', 'ratón', 'río'],
      'S': ['sol', 'sapo', 'silla'],
      'T': ['taza', 'tigre', 'tambor'],
      'U': ['uva', 'uno', 'unicornio'],
      'V': ['vaca', 'verde', 'ventana'],
      'W': ['wifi', 'water', 'western'],
      'X': ['xilófono', 'xenón', 'xerez'],
      'Y': ['yate', 'yema', 'yuca'],
      'Z': ['zapato', 'zebra', 'zorro'],
    };
    
    final words = exampleWords[letter.toUpperCase()] ?? ['palabra'];
    return words.take(3).join(', ');
  }

  void _startSyllableGame(dynamic letter) {
    // Palabras correctamente vinculadas con cada letra
    final gameWords = {
      'A': {'word': 'ala', 'syllables': ['a', 'la']},
      'B': {'word': 'bola', 'syllables': ['bo', 'la']},
      'C': {'word': 'casa', 'syllables': ['ca', 'sa']}, // CORREGIDO: casa va con C
      'D': {'word': 'dado', 'syllables': ['da', 'do']},
      'E': {'word': 'elefante', 'syllables': ['e', 'le', 'fan', 'te']}, // CORREGIDO: elefante va con E
      'F': {'word': 'foca', 'syllables': ['fo', 'ca']},
      'G': {'word': 'gato', 'syllables': ['ga', 'to']},
      'H': {'word': 'hola', 'syllables': ['ho', 'la']},
      'I': {'word': 'isla', 'syllables': ['is', 'la']},
      'J': {'word': 'jirafa', 'syllables': ['ji', 'ra', 'fa']}, // MEJORADO: jirafa es más educativa
      'K': {'word': 'kiwi', 'syllables': ['ki', 'wi']}, // CORREGIDO: kiwi va con K
      'L': {'word': 'luna', 'syllables': ['lu', 'na']},
      'M': {'word': 'mama', 'syllables': ['ma', 'ma']},
      'N': {'word': 'nube', 'syllables': ['nu', 'be']}, // MEJORADO: nube es más clara que nana
      'Ñ': {'word': 'niño', 'syllables': ['ni', 'ño']},
      'O': {'word': 'oso', 'syllables': ['o', 'so']},
      'P': {'word': 'papa', 'syllables': ['pa', 'pa']},
      'Q': {'word': 'queso', 'syllables': ['que', 'so']},
      'R': {'word': 'rosa', 'syllables': ['ro', 'sa']},
      'S': {'word': 'sol', 'syllables': ['sol']},
      'T': {'word': 'taza', 'syllables': ['ta', 'za']},
      'U': {'word': 'uva', 'syllables': ['u', 'va']},
      'V': {'word': 'vaca', 'syllables': ['va', 'ca']},
      'W': {'word': 'wifi', 'syllables': ['wi', 'fi']}, // MEJORADO: wifi es más familiar
      'X': {'word': 'xilófono', 'syllables': ['xi', 'ló', 'fo', 'no']}, // CORREGIDO: xilófono va con X
      'Y': {'word': 'yate', 'syllables': ['ya', 'te']}, // MEJORADO: yate es más clara
      'Z': {'word': 'zapato', 'syllables': ['za', 'pa', 'to']}, // CORREGIDO: zapato va con Z
    };

    final gameData = gameWords[letter.character.toUpperCase()];
    if (gameData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SyllableGameScreen(
            letter: letter.character,
            targetWord: gameData['word']! as String,
            syllables: gameData['syllables']! as List<String>,
          ),
        ),
      );
    } else {
      _audioService.speakText('¡Ups! Este juego aún no está listo para esta letra, pero pronto estará disponible.');
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Parque AR'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏛️ Kioscos de Letras',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Cada kiosco del parque tiene una letra especial. Están dispuestos en círculos como una plaza.'),
              SizedBox(height: 12),
              Text(
                '🚶 Paseo Virtual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Mueve tu teléfono para caminar por todo el parque y descubrir cada rincón.'),
              SizedBox(height: 12),
              Text(
                '👆 Exploración',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Toca cualquier kiosco para visitar esa letra y jugar con Luna.'),
              SizedBox(height: 12),
              Text(
                '👧 Guía Luna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Luna te acompañará con su voz dulce y te enseñará cada letra de forma divertida.'),
            ],
          ),
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
}