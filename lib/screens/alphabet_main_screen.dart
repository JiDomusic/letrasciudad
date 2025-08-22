import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sin;
import '../services/audio_service.dart';
import '../games/scattered_objects_game.dart';
import '../widgets/letter_tracing_widget.dart';
import '../providers/letter_city_provider.dart';

/// Pantalla principal del juego del alfabeto con barra inferior A-Z
class AlphabetMainScreen extends StatefulWidget {
  final AudioService audioService;

  const AlphabetMainScreen({
    super.key,
    required this.audioService,
  });

  @override
  State<AlphabetMainScreen> createState() => _AlphabetMainScreenState();
}

class _AlphabetMainScreenState extends State<AlphabetMainScreen> {
  String _currentLetter = 'B'; // Empezar con B como en la imagen
  final PageController _pageController = PageController(initialPage: 1); // B es index 1
  bool _hasGivenInitialWelcome = false;

  // Alfabeto argentino completo
  final List<String> _alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  // Todas las letras usan el mismo juego ahora (sin juegos especiales de trazado)
  final Set<String> _tracingLetters = <String>{}; // Set vacío - no hay letras especiales

  bool _shouldUseTracingGame(String letter) {
    return false; // Siempre usar el juego estándar, no el de trazado
  }

  Widget _buildTracingGameScreen(String letter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red[100]!,
            Colors.pink[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header con estrella roja para indicar que es juego especial  
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 8 : 16), // Menos padding en móvil
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.red[600],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Juego Especial de Trazado!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'Traza la letra $letter con tu mano',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Widget de trazado
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 8 : 16), // Menos padding en móvil
              child: LetterTracingWidget(
                letter: letter,
                audioService: widget.audioService,
                playerName: context.read<LetterCityProvider>().playerName,
                isSpecialLetter: true, // Marcar como letra especial para mejor feedback
                onTracingComplete: () {
                  // Celebración personalizada con estrellas para cada letra especial
                  _showSpecialLetterCelebrationWithStars(letter);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpecialLetterCelebrationWithStars(String letter) {
    final provider = context.read<LetterCityProvider>();
    final playerName = provider.playerName.isNotEmpty ? provider.playerName : 'pequeño artista';
    
    // Mostrar diálogo especial con estrellas
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700), // Dorado
                  const Color(0xFFFFA500), // Naranja dorado
                  const Color(0xFFFF6347), // Naranja rojizo
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ANIMACIÓN DE ESTRELLAS GIRATORIAS
                SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      // Estrella grande central que gira
                      Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 2),
                          tween: Tween(begin: 0.0, end: 2 * 3.14159),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value,
                              child: Transform.scale(
                                scale: 1.2,
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Repetir animación
                          },
                        ),
                      ),
                      // Estrellas pequeñas orbitando
                      ...List.generate(8, (index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1500 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 2 * 3.14159),
                          builder: (context, value, child) {
                            final angle = (index * 3.14159 / 4) + value;
                            final radius = 45.0;
                            final x = 60 + radius * cos(angle);
                            final y = 60 + radius * sin(angle);
                            
                            return Positioned(
                              left: x - 10,
                              top: y - 10,
                              child: Transform.scale(
                                scale: 0.6,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
                
                // Título especial con emojis
                Text(
                  '🌟 ¡SÚPER ESTRELLA! 🌟',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Mensaje personalizado con voz de niña
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Text(
                    _getFluentGirlVoiceMessage(letter, playerName),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Fila de 5 estrellas doradas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 150)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 35,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 25),
                
                // Botón continuar con estilo alegre
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6347),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    '¡Seguir jugando!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Audio con voz de niña más fluida y humana
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.audioService.speakText(_getFluentGirlAudioMessage(letter, playerName));
    });
  }
  
  // Mensajes con voz de niña más fluida y humana
  String _getFluentGirlVoiceMessage(String letter, String name) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return '¡Ay, $name! ¡Me encanta cómo trazaste la Ñ! Es mi letra favorita porque tiene sombrerito. ¡Sos genial!';
      case 'B':
        return '¡Wow $name! Tu B quedó preciosa con sus dos pancitas. ¡Me dan ganas de abrazarla! ¡Eres súper talentoso!';
      case 'V':
        return '¡Qué lindo $name! Tu V parece las alas de una mariposa. ¡Es una victoria total! ¡Te quedo divina!';
      case 'W':
        return '¡No puedo creer $name! La W es súper difícil y vos la hiciste como un profesional. ¡Sos increíble de verdad!';
      case 'X':
        return '¡Ay qué genial $name! Tu X parece un abrazo gigante. ¡Me dan ganas de abrazarte también! ¡Qué bien te salió!';
      case 'Y':
        return '¡Me encanta $name! Tu Y parece un arbolito con brazos abiertos dando la bienvenida. ¡Qué hermosa!';
      case 'K':
        return '¡Sos un genio $name! La K es súper especial y complicada, pero vos la dominaste completamente. ¡Bravo!';
      default:
        return '¡Sos increíble $name! ¡Me encanta cómo trazás las letras especiales! ¡Eres mi héroe!';
    }
  }
  
  String _getFluentGirlAudioMessage(String letter, String name) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return 'Ay $name, ¡me fascina cómo trazaste la Ñ! Sabés que es mi letra argentina favorita porque tiene su sombrerito tan lindo. La hiciste con tanto cariño que me emociona. ¡Sos realmente genial!';
      case 'B':
        return 'Wow $name, ¡tu B quedó hermosísima! Me encantan sus dos pancitas redonditas. Parece que está sonriendo igual que yo. ¡Tenés un talento increíble para las letras!';
      case 'V':
        return 'Qué precioso $name, tu V me parece las alitas de una mariposa que está por volar. Es una verdadera victoria porque te quedó perfecta. ¡Me da mucha alegría verte trazar tan bien!';
      case 'W':
        return 'No puedo creer lo bien que lo hiciste $name. La W es súper complicada, hasta para mí a veces, pero vos la trazaste como todo un experto. ¡Estoy súper orgullosa de vos!';
      case 'X':
        return 'Ay me encanta $name, tu X parece un abrazo gigante lleno de amor. Me dan ganas de darte un abrazo igual de grande porque lo hiciste increíble. ¡Qué talentoso que sos!';
      case 'Y':
        return 'Me fascina $name, tu Y parece un arbolito con los brazos abiertos dando la bienvenida a todos. Igual que vos, que siempre estás dispuesto a aprender. ¡Qué hermosa te quedó!';
      case 'K':
        return 'Sos un verdadero genio $name. La K es una letra súper especial que viene de otros lugares del mundo, y vos la dominaste como si fuera tu idioma. ¡Estoy impresionada!';
      default:
        return 'Sos absolutamente increíble $name. Me encanta verte trazar estas letras especiales con tanto amor y dedicación. ¡Eres mi pequeño héroe de las letras!';
    }
  }

  void _giveSpecialLetterWelcome(String letter) {
    final provider = context.read<LetterCityProvider>();
    final playerName = provider.playerName.isNotEmpty ? provider.playerName : 'pequeño artista';
    
    // Bienvenida con voz de niña más fluida y cálida
    Future.delayed(const Duration(milliseconds: 800), () {
      switch (letter.toUpperCase()) {
        case 'Ñ':
          widget.audioService.speakText(
            'Holi $playerName, ¡me emociona tanto que estés aquí! Vamos a jugar con la Ñ, que es mi letra argentina súper especial. ¿Sabés qué? Tiene un gorrito muy lindo arriba que se llama tilde. Primero vamos a hacer una N normalita, y después le ponemos su gorrito encima. ¡Va a quedar preciosa!'
          );
          break;
        case 'K':
          widget.audioService.speakText(
            'Ay $playerName, ¡qué genial que llegaste hasta la K! Esta letra me parece súper interesante porque es como una bailarina haciendo un paso especial. Tiene una línea derechita parada, y después dos líneas que la tocan como si fueran sus bracitos bailando. ¡Sé que vos lo vas a hacer increíble!'
          );
          break;
        case 'Y':
          widget.audioService.speakText(
            'Hola mi querido $playerName, ¡me encanta que llegaste a la Y! ¿Sabés que esta letra me recuerda a un arbolito con los brazos abiertos dándote la bienvenida? Tiene dos líneas que se abrazan arriba y después un palito abajo. Es como si estuviera diciendo "¡hola amigo!". ¡Vamos a hacer tu Y más linda!'
          );
          break;
        case 'X':
          widget.audioService.speakText(
            'Ay $playerName, ¡llegaste a la X que es súper divertida! A mí me parece como un abrazo gigante porque tiene dos líneas que se cruzan en el medio. Es la letra de los tesoros piratas y de las aventuras mágicas. ¡Vamos a hacer tu X como el abrazo más cálido del mundo!'
          );
          break;
        case 'B':
          widget.audioService.speakText(
            'Hola hermoso $playerName, ¡qué alegría verte aquí con la B! Esta letra me parece tan bonita y bella. ¿Te digo un secreto? Tiene una línea recta como un palito de helado, y después dos pancitas redonditas que parecen dos sonrisas. ¡Vamos a hacer la B más bella y feliz que puedas imaginar!'
          );
          break;
        case 'V':
          widget.audioService.speakText(
            'Holi $playerName, ¡llegaste a la V de victoria! Me encanta esta letra porque me recuerda a las alitas de una mariposa o a un valle entre montañitas. Son dos líneas que se hacen amigas abajo y forman como un corazoncito al revés. ¡Tu V va a ser una súper victoria!'
          );
          break;
        case 'W':
          widget.audioService.speakText(
            'Wow $playerName, ¡llegaste a la W que es la más especial de todas! ¿Sabés que es como si fueran dos V que se hicieron súper amigas? A mí me recuerda a las onditas del mar o a una montaña rusa súper divertida. Es un poquito complicadita, pero vos sos tan inteligente que sé que la vas a dominar. ¡Vamos juntos!'
          );
          break;
        default:
          widget.audioService.speakText(
            'Hola mi lindo $playerName, ¡qué emocionante que llegaste a esta letra súper especial! Me encanta acompañarte en estas aventuras de las letras. ¡Sé que lo vas a hacer increíble como siempre!'
          );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Dar bienvenida inicial solo una vez
    if (!_hasGivenInitialWelcome) {
      _hasGivenInitialWelcome = true;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _shouldUseTracingGame(_currentLetter)) {
          _giveSpecialLetterWelcome(_currentLetter);
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        toolbarHeight: 48, // AppBar más pequeño para más espacio de juego
        title: const Text(
          'Alfabeto Argentino',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.audioService.stop(); // Detener audio antes de navegar
            Navigator.of(context).pop();
            widget.audioService.speakText('Volviendo al parque de letras');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              widget.audioService.stop(); // Detener audio antes de navegar
              Navigator.of(context).popUntil((route) => route.isFirst);
              widget.audioService.speakText('Volviendo al parque principal');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Área principal del juego
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _alphabet.length,
              onPageChanged: (index) {
                setState(() {
                  _currentLetter = _alphabet[index];
                });
                
                // Dar bienvenida especial para letras con estrella roja
                if (_shouldUseTracingGame(_alphabet[index])) {
                  _giveSpecialLetterWelcome(_alphabet[index]);
                }
                
                // También anunciar navegación para letras regulares
                else {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    widget.audioService.speakText('¡Hola! Ahora vamos a jugar con esta letra.');
                  });
                }
              },
              itemBuilder: (context, index) {
                final letter = _alphabet[index];
                
                if (_shouldUseTracingGame(letter)) {
                  // Usar juego de trazado para letras especiales (estrella roja)
                  return _buildTracingGameScreen(letter);
                } else {
                  // Usar juego de objetos dispersos para otras letras
                  return ScatteredObjectsGame(
                    currentLetter: letter,
                    audioService: widget.audioService,
                  );
                }
              },
            ),
          ),
          
          // Barra inferior con letras A-Z
          _buildBottomLetterBar(),
        ],
      ),
    );
  }

  Widget _buildBottomLetterBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _alphabet.length,
        itemBuilder: (context, index) {
          final letter = _alphabet[index];
          final isSelected = letter == _currentLetter;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentLetter = letter;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              
              // Dar feedback inmediato al tocar letras especiales
              if (_shouldUseTracingGame(letter)) {
                final playerName = context.read<LetterCityProvider>().playerName;
                Future.delayed(const Duration(milliseconds: 400), () {
                  widget.audioService.speakText('¡Excelente! Tocaste la estrella roja de la letra. ¡Prepárate para el juego especial!');
                });
              }
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (_shouldUseTracingGame(letter) ? Colors.red[600] : Colors.blue[600]) 
                  : (_shouldUseTracingGame(letter) ? Colors.red[100] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(30),
                border: isSelected 
                  ? Border.all(
                      color: _shouldUseTracingGame(letter) ? Colors.red[800]! : Colors.blue[800]!, 
                      width: 2
                    )
                  : (_shouldUseTracingGame(letter) 
                      ? Border.all(color: Colors.red[300]!, width: 1)
                      : null),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                          ? Colors.white 
                          : Colors.grey[700],
                      ),
                    ),
                  ),
                  // Las estrellas rojas han sido eliminadas - todas las letras usan el mismo juego
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}