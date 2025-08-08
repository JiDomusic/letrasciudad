import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:camera/camera.dart'; // Removido - funcionalidad AR deshabilitada
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../widgets/ar_overlay_widget.dart';
import 'dart:async';

class ARCityScreen extends StatefulWidget {
  const ARCityScreen({super.key});

  @override
  State<ARCityScreen> createState() => _ARCityScreenState();
}

class _ARCityScreenState extends State<ARCityScreen> {
  // CameraController? _cameraController; // Comentado - AR deshabilitado
  bool _isCameraInitialized = false;
  bool _showInstructions = true;
  final AudioService _audioService = AudioService();
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _playWelcomeMessage();
  }

  Future<void> _initializeCamera() async {
    // FUNCIONALIDAD AR DESHABILITADA - Simular inicialización
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // void _showCameraError(String message) { // Comentado - no se usa
  //   if (mounted) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Error de Cámara'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Volver'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _audioService.speakText('¡Bienvenido a mi parque encantado! Soy Luna y he creado casitas especiales con cada letra. ¡Arrastra las casitas hacia abajo para formar palabras mágicas! Cada palabra que formes me mostrará su imagen. ¡Vamos a jugar!');
  }

  // Variables para el juego de formación de palabras
  final List<String> _formedSyllables = [];
  String _currentWord = '';
  String? _wordImage;
  
  // Zona de juego responsiva para formar palabras
  Widget _buildGameZone() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // final screenHeight = constraints.maxHeight; // No se usa actualmente
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
        
        // Altura adaptativa - más pequeña para estar realmente abajo
        final gameZoneHeight = isSmallScreen 
            ? 120.0  // Altura fija pequeña en móviles
            : isMediumScreen 
                ? 140.0  // Altura fija en tablets
                : 160.0; // Altura fija en desktop
        
        // Margen adaptativo
        final margin = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
        
        return Positioned(
          bottom: 0, // Pegado completamente a la parte inferior
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              height: gameZoneHeight,
              margin: EdgeInsets.only(
                left: margin,
                right: margin,
                bottom: 10, // Pequeño margen desde el borde
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: isSmallScreen ? 1.5 : 2,
                ),
              ),
              child: Column(
                children: [
                  // Área de formación de sílabas
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16, 
                        vertical: isSmallScreen ? 6 : 8
                      ),
                      child: Row(
                        children: [
                          Text(
                            isSmallScreen ? 'Palabras: ' : 'Forma palabras: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: isSmallScreen ? 40 : (isMediumScreen ? 50 : 60),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: isSmallScreen ? 1 : 1.5,
                                ),
                              ),
                          child: DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              setState(() {
                                _formedSyllables.add(details.data);
                                _currentWord = _formedSyllables.join('');
                                _checkForValidWord();
                              });
                              _audioService.speakText('¡Genial! Agregaste ${details.data}');
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    ..._formedSyllables.map((syllable) => 
                                      Container(
                                        margin: EdgeInsets.only(right: isSmallScreen ? 2 : 4),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 6 : 8, 
                                          vertical: isSmallScreen ? 2 : 4
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          syllable,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 12 : (isMediumScreen ? 14 : 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (candidateData.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(right: isSmallScreen ? 2 : 4),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 6 : 8, 
                                          vertical: isSmallScreen ? 2 : 4
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.yellow),
                                        ),
                                        child: Text(
                                          candidateData.first ?? '',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 12 : (isMediumScreen ? 14 : 16),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Botones de control responsivos
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 36 : (isMediumScreen ? 44 : 52),
                            height: isSmallScreen ? 36 : (isMediumScreen ? 44 : 52),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: _clearWord,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Container(
                            width: isSmallScreen ? 36 : (isMediumScreen ? 44 : 52),
                            height: isSmallScreen ? 36 : (isMediumScreen ? 44 : 52),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: _speakCurrentWord,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.volume_up,
                                color: Colors.blue,
                                size: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Área de imagen de la palabra responsiva
              if (_wordImage != null)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(isSmallScreen ? 6 : (isMediumScreen ? 8 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: isSmallScreen ? 4 : 6,
                          offset: Offset(0, isSmallScreen ? 2 : 3),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(_wordImage!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    },
  );
}

  void _clearWord() {
    setState(() {
      _formedSyllables.clear();
      _currentWord = '';
      _wordImage = null;
    });
    _audioService.speakText('Palabra borrada, ¡inténtalo de nuevo!');
  }

  void _speakCurrentWord() {
    if (_currentWord.isNotEmpty) {
      _audioService.speakText('La palabra es: $_currentWord');
    } else {
      _audioService.speakText('¡Arrastra las casitas para formar palabras!');
    }
  }

  void _checkForValidWord() {
    // Diccionario de palabras válidas con sus imágenes
    final validWords = {
      'yo': 'assets/images/words/yo.png',
      'casa': 'assets/images/words/casa.png',
      'mama': 'assets/images/words/mama.png',
      'papa': 'assets/images/words/papa.png',
      'gato': 'assets/images/words/gato.png',
      'perro': 'assets/images/words/perro.png',
      'sol': 'assets/images/words/sol.png',
      'luna': 'assets/images/words/luna.png',
      'flor': 'assets/images/words/flor.png',
      'agua': 'assets/images/words/agua.png',
      'arbol': 'assets/images/words/arbol.png',
    };

    final word = _currentWord.toLowerCase();
    if (validWords.containsKey(word)) {
      setState(() {
        _wordImage = validWords[word];
      });
      _audioService.speakText('¡Excelente! Formaste la palabra $_currentWord');
      
      // Celebración visual
      _showWordCelebration(word);
    } else if (_formedSyllables.length >= 2) {
      _audioService.speakText('Mmm, $_currentWord no es una palabra que conozco. ¡Sigue intentando!');
    }
  }

  void _showWordCelebration(String word) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            
            // Tamaños responsivos
            final imageSize = isSmallScreen ? 120.0 : (isMediumScreen ? 150.0 : 180.0);
            final titleSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 24.0);
            final wordSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
            final buttonTextSize = isSmallScreen ? 14.0 : 16.0;
            
            return AlertDialog(
              title: Text(
                '¡Palabra formada!',
                style: TextStyle(fontSize: titleSize),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_wordImage != null)
                    Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(_wordImage!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    word.toUpperCase(),
                    style: TextStyle(
                      fontSize: wordSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearWord();
                  },
                  child: Text(
                    isSmallScreen ? '¡Continuar!' : '¡Continuar jugando!',
                    style: TextStyle(fontSize: buttonTextSize),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // _cameraController?.dispose(); // Comentado - AR deshabilitado
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
          _buildGameZone(), // Nueva zona de juego en lugar del selector
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
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
                'Inicializando vista...',
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

    // VISTA SIMULADA SIN CÁMARA - Fondo degradado
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Azul cielo
            Color(0xFFB0E2FF), // Azul claro
            Color(0xFF98FB98), // Verde claro
            Color(0xFF90EE90), // Verde lima
          ],
        ),
      ),
      child: Stack(
        children: [
          // Efecto de partículas flotantes
          ...List.generate(20, (index) => 
            Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: (index * 80.0) % MediaQuery.of(context).size.height,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAROverlay() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return AROverlayWidget(
          letters: provider.unlockedLetters,
          onLetterTap: (letter) {
            // Simple tap feedback without showing modal
            _audioService.speakText('Letra ${letter.character}. Arrástrala para formar palabras.');
          },
          highlightedLetter: null,
          houseScale: 1.0,
        );
      },
    );
  }

  Widget _buildTopBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        
        // Tamaños responsivos
        final iconSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
        final fontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
        final padding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
        final borderRadius = isSmallScreen ? 16.0 : 20.0;
        
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16, 
                    vertical: isSmallScreen ? 6 : 8
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: iconSize * 0.7),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Text(
                        isSmallScreen ? 'AR' : 'Parque AR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.white, size: iconSize),
                    onPressed: () => _showGameInfo(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        
        // Tamaños responsivos
        final iconSize = isSmallScreen ? 36.0 : (isMediumScreen ? 48.0 : 56.0);
        final titleSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
        final textSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
        final margin = isSmallScreen ? 24.0 : (isMediumScreen ? 32.0 : 40.0);
        final padding = isSmallScreen ? 16.0 : (isMediumScreen ? 24.0 : 32.0);
        final spacing = isSmallScreen ? 12.0 : 16.0;
        
        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Card(
              margin: EdgeInsets.all(margin),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: iconSize,
                      color: const Color(0xFF4F46E5),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      isSmallScreen ? '¡Parque AR!' : '¡Parque de Letras Interactivo!',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing),
                    Text(
                      isSmallScreen 
                          ? '¡Arrastra las casitas para formar palabras! Cada palabra mostrará su imagen.'
                          : '¡Arrastra las casitas de letras para formar palabras! Cada palabra que formes mostrará su imagen. ¡Descubre cuántas palabras puedes crear!',
                      style: TextStyle(fontSize: textSize),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing * 1.5),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showInstructions = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 32,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      child: Text(
                        '¡Explorar!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isMediumScreen = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            
            // Tamaños responsivos
            final titleSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 24.0);
            final sectionTitleSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
            final textSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
            final spacing = isSmallScreen ? 8.0 : 12.0;
            final buttonTextSize = isSmallScreen ? 14.0 : 16.0;
            
            return AlertDialog(
              title: Text(
                '¿Cómo jugar?',
                style: TextStyle(fontSize: titleSize),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🏠 Casitas de Letras',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sectionTitleSize),
                    ),
                    Text(
                      isSmallScreen 
                          ? 'Arrastra las casitas con letras para formar palabras.'
                          : 'Cada casita flotante contiene una letra. Puedes arrastrarlas para formar palabras.',
                      style: TextStyle(fontSize: textSize),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      '🎯 Formar Palabras',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sectionTitleSize),
                    ),
                    Text(
                      isSmallScreen
                          ? 'Arrastra hacia la zona inferior para formar palabras.'
                          : 'Arrastra las casitas hacia la zona de juego en la parte inferior para formar palabras.',
                      style: TextStyle(fontSize: textSize),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      '🖼️ Descubrir Imágenes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sectionTitleSize),
                    ),
                    Text(
                      'Cuando formes una palabra válida, aparecerá su imagen correspondiente.',
                      style: TextStyle(fontSize: textSize),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      '🔊 Escuchar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sectionTitleSize),
                    ),
                    Text(
                      isSmallScreen
                          ? 'Usa el botón de sonido para escuchar la palabra.'
                          : 'Usa el botón de sonido para escuchar la palabra que has formado.',
                      style: TextStyle(fontSize: textSize),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '¡Entendido!',
                    style: TextStyle(fontSize: buttonTextSize),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
