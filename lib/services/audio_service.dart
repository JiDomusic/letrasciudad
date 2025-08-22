import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  double _volume = 1.0;
  double _speechRate = 0.6; // Velocidad más lenta y clara para una mujer educadora
  double _speechPitch = 1.4; // Pitch claramente femenino para voz de mujer

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🎤 Inicializando AudioService...');
      debugPrint('🌐 Plataforma: ${kIsWeb ? "Web" : "Móvil"}');
      
      // Configurar callbacks para monitorear el estado
      _flutterTts.setStartHandler(() {
        debugPrint('🎤 TTS comenzó a hablar');
      });
      
      _flutterTts.setCompletionHandler(() {
        debugPrint('🎤 TTS terminó de hablar');
      });
      
      _flutterTts.setErrorHandler((msg) {
        debugPrint('❌ TTS Error: $msg');
      });
      
      // Configuración específica por plataforma
      if (kIsWeb) {
        await _configureWebTTS();
      } else {
        await _configureMobileTTS();
      }
      
      // Configuración universal con voz argentina femenina
      await _flutterTts.setLanguage("es-AR");
      await _flutterTts.setSpeechRate(0.6); // Más lenta para claridad
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.4); // Más agudo para voz femenina
      
      debugPrint('🧪 TTS configurado con voz argentina');
      
      _isInitialized = true;
      debugPrint('✅ AudioService inicializado correctamente con voz argentina');
    } catch (e) {
      debugPrint('❌ Error initializing AudioService: $e');
      // Reintentar con configuración mínima
      await _fallbackInitialization();
    }
  }

  Future<void> _configureWebTTS() async {
    try {
      debugPrint('🌐 Configurando TTS para Web con voz argentina');
      await _flutterTts.setLanguage("es-AR");
      
      // Lista de voces argentinas preferidas
      final preferredVoices = [
        'Google español (Argentina)',
        'Google español (Argentina) - Isabella',
        'es-AR',
        'Spanish (Argentina)',
        'Español (Argentina)',
      ];
      
      dynamic voices = await _flutterTts.getVoices;
      debugPrint('🎤 Voces disponibles: ${voices?.length ?? 0}');
      
      if (voices is List) {
        bool voiceSet = false;
        
        // Buscar voces argentinas
        for (String preferredVoice in preferredVoices) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['name'] != null) {
              String voiceName = voice['name'].toString();
              String locale = voice['locale']?.toString() ?? '';
              
              if (voiceName.toLowerCase().contains('argentina') || 
                  locale.toLowerCase().contains('es-ar') ||
                  locale.toLowerCase().contains('es_ar')) {
                debugPrint('✅ Configurando voz argentina: $voiceName');
                await _flutterTts.setVoice(Map<String, String>.from(voice));
                voiceSet = true;
                break;
              }
            }
          }
          if (voiceSet) break;
        }
        
        if (!voiceSet) {
          debugPrint('⚠️ No se encontró voz argentina, usando configuración por defecto');
        }
      }
      
      await _flutterTts.awaitSpeakCompletion(false);
      
    } catch (e) {
      debugPrint('⚠️ Error configurando voz para web: $e');
    }
  }

  Future<void> _configureMobileTTS() async {
    try {
      debugPrint('📱 Configurando TTS para móvil con voz argentina');
      await _flutterTts.setLanguage("es-AR");
      
      // Configurar motor de Google TTS (mejor calidad)
      try {
        await _flutterTts.setEngine("com.google.android.tts");
        debugPrint('✅ Motor Google TTS configurado');
      } catch (e) {
        debugPrint('⚠️ Motor Google TTS no disponible, usando por defecto');
      }
      
      // Lista de voces argentinas para móvil
      final argentineVoices = [
        'es-ar-x-ard-network',
        'es-ar-x-ard-local',
        'Google español (Argentina)',
        'Spanish (Argentina)',
        'Español (Argentina)',
      ];
      
      dynamic voices = await _flutterTts.getVoices;
      debugPrint('📱 Voces móviles disponibles: ${voices?.length ?? 0}');
      
      if (voices is List) {
        bool voiceSet = false;
        
        // Buscar voces argentinas para móvil
        for (dynamic voice in voices) {
          if (voice is Map && voice['name'] != null) {
            String voiceName = voice['name'].toString();
            String locale = voice['locale']?.toString() ?? '';
            
            if (voiceName.toLowerCase().contains('argentina') || 
                locale.toLowerCase().contains('es-ar') ||
                locale.toLowerCase().contains('es_ar')) {
              debugPrint('✅ Configurando voz argentina móvil: $voiceName');
              try {
                await _flutterTts.setVoice(Map<String, String>.from(voice));
                voiceSet = true;
                break;
              } catch (e) {
                debugPrint('⚠️ Error con voz argentina: $e');
                continue;
              }
            }
          }
        }
        
        if (!voiceSet) {
          debugPrint('⚠️ No se encontró voz argentina en móvil');
        }
        
        await _flutterTts.awaitSpeakCompletion(false);
        await _flutterTts.setSharedInstance(true);
      }
      
    } catch (e) {
      debugPrint('⚠️ Error configurando TTS para móvil: $e');
    }
  }

  Future<void> _fallbackInitialization() async {
    try {
      debugPrint('🔄 Intentando inicialización de respaldo...');
      await _flutterTts.setLanguage("es-AR");
      await _flutterTts.setSpeechRate(0.7);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.2);
      
      _isInitialized = true;
      debugPrint('✅ AudioService inicializado con configuración de respaldo argentina');
    } catch (e) {
      debugPrint('❌ Error en inicialización de respaldo: $e');
      _isInitialized = false;
    }
  }

  Future<void> playLetterSound(String letterCharacter) async {
    await initialize();
    // Usar solo síntesis de voz para compatibilidad total
    await speakText(letterCharacter);
  }

  Future<void> playWordSound(String word) async {
    await initialize();
    // Usar solo síntesis de voz para compatibilidad total
    await speakText(word);
  }

  Future<void> playSyllableSound(String syllable) async {
    await initialize();
    // Usar solo síntesis de voz para compatibilidad total
    await speakText(syllable);
  }

  Future<void> speakText(String text) async {
    if (text.isEmpty) return;
    
    try {
      debugPrint('🎤 Solicitud de voz: "$text"');
      
      if (!_isInitialized) {
        await initialize();
      }
      
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 300)); // Más tiempo para evitar cortes
      
      // Configuración argentina simple con voz femenina
      await _flutterTts.setLanguage("es-AR");
      await _flutterTts.setSpeechRate(0.6); // Más lenta y clara
      await _flutterTts.setPitch(1.4); // Claramente femenino
      await _flutterTts.setVolume(1.0);
      await _flutterTts.awaitSpeakCompletion(false);
      
      if (!kIsWeb) {
        await _flutterTts.setSharedInstance(true);
      }
      
      // Sin procesamiento complejo del texto - usar directamente
      await _flutterTts.speak(text);
      
      // Esperar que termine completamente antes de continuar
      if (kIsWeb) {
        await Future.delayed(Duration(milliseconds: (text.length * 100).clamp(500, 3000)));
      }
      
      debugPrint('✅ Audio completado: "$text"');
      
    } catch (e) {
      debugPrint('❌ Error reproduciendo audio: $e');
      try {
        await _flutterTts.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        await _flutterTts.speak(text);
      } catch (retryError) {
        debugPrint('❌ Error en reintento: $retryError');
      }
    }
  }
  

  Future<void> _ensureArgentineVoiceSettings() async {
    try {
      await _flutterTts.setLanguage("es-AR");
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setPitch(1.4);
      await _flutterTts.setVolume(1.0);
      
      _speechRate = 0.6;
      _speechPitch = 1.4;
      _volume = 1.0;
      
    } catch (e) {
      debugPrint('⚠️ Error configurando voz argentina: $e');
    }
  }

  Future<void> speakPhoneme(String phoneme) async {
    await initialize();
    
    try {
      await _flutterTts.speak(phoneme);
    } catch (e) {
      debugPrint('Error speaking phoneme: $phoneme, Error: $e');
    }
  }

  Future<void> playSuccessSound() async {
    await initialize();
    // Usar sonidos de texto para mayor compatibilidad
    await speakText('¡Muy bien!');
  }

  Future<void> playErrorSound() async {
    await initialize();
    // Usar sonidos de texto para mayor compatibilidad
    await speakText('Oops, inténtalo de nuevo');
  }

  Future<void> playClickSound() async {
    // Sin sonido de click para evitar errores - solo funcionalidad visual
    debugPrint('Click sound requested');
  }

  Future<void> playBackgroundMusic() async {
    // Música de fondo deshabilitada para evitar errores de archivos faltantes
    debugPrint('Background music requested - using ambient sound synthesis');
  }

  Future<void> stopBackgroundMusic() async {
    // Música de fondo deshabilitada - no hay nada que detener
    debugPrint('Stop background music requested');
  }

  Future<void> pauseBackgroundMusic() async {
    // Música de fondo deshabilitada - no hay nada que pausar
    debugPrint('Pause background music requested');
  }

  Future<void> resumeBackgroundMusic() async {
    // Música de fondo deshabilitada - no hay nada que reanudar
    debugPrint('Resume background music requested');
  }

  Future<void> stopAllSounds() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping all sounds: $e');
    }
  }

  // Método abreviado para detener sonidos al navegar
  Future<void> stop() async {
    await stopAllSounds();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_speechPitch);
  }

  double get volume => _volume;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    await _flutterTts.stop();
  }

  Future<void> speakLetterIntroduction(String letter, String phoneme, List<String> exampleWords) async {
    await initialize();
    
    try {
      await speakText('¡Hola! Soy la letra $letter');
      await Future.delayed(const Duration(milliseconds: 700));
      await speakText('Mi sonido es $phoneme');
      await Future.delayed(const Duration(milliseconds: 700));
      
      if (exampleWords.isNotEmpty) {
        await speakText('¿Quieres conocer mis palabras favoritas?');
        await Future.delayed(const Duration(milliseconds: 500));
        
        for (final word in exampleWords.take(3)) {
          await speakText('¡$word!');
          await Future.delayed(const Duration(milliseconds: 900));
        }
        await speakText('¿A que son divertidas?');
      }
    } catch (e) {
      debugPrint('Error speaking letter introduction: $e');
    }
  }

  Future<void> speakSyllableLesson(String letter, List<String> syllables) async {
    await initialize();
    
    try {
      await speakText('¡Vamos a jugar con mis sílabas de la letra $letter!');
      await Future.delayed(const Duration(milliseconds: 700));
      
      await speakText('Escucha bien:');
      await Future.delayed(const Duration(milliseconds: 500));
      
      for (final syllable in syllables) {
        await speakText(syllable);
        await Future.delayed(const Duration(milliseconds: 700));
      }
      
      await speakText('¡Genial! Ahora repite conmigo');
      await Future.delayed(const Duration(milliseconds: 600));
      
      for (final syllable in syllables) {
        await speakText('$syllable... tu turno');
        await Future.delayed(const Duration(milliseconds: 1200));
      }
      
      await speakText('¡Qué bien lo haces!');
    } catch (e) {
      debugPrint('Error speaking syllable lesson: $e');
    }
  }

  Future<void> speakEncouragement() async {
    final encouragements = [
      '¡Eres increíble!',
      '¡Qué inteligente eres!',
      '¡Me encanta como aprendes!',
      '¡Lo estás haciendo genial!',
      '¡Eres un súper estudiante!',
      '¡Qué bien vas aprendiendo!',
      '¡Estoy muy orgullosa de ti!',
      '¡Sigue así, campeón!',
      '¡Eres fantástico!',
      '¡Qué divertido es aprender contigo!',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % encouragements.length;
    await speakText(encouragements[random]);
  }

  Future<void> speakTryAgain() async {
    final tryAgainPhrases = [
      '¡Vamos, tú puedes hacerlo!',
      '¡Casi lo tienes! Inténtalo otra vez',
      '¡No te preocupes, todos aprendemos!',
      '¡Ánimo! Estoy aquí para ayudarte',
      '¡Qué valiente eres al intentarlo!',
      '¡Cada error nos ayuda a aprender!',
      '¡Vamos, sé que lo puedes lograr!',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % tryAgainPhrases.length;
    await speakText(tryAgainPhrases[random]);
  }

  // Método para llamar al niño por su nombre cuando complete su nombre
  Future<void> speakNameCompletion(String childName) async {
    if (childName.isEmpty) return;
    
    final nameCompletionPhrases = [
      '¡Muy bien, $childName! ¡Has escrito tu nombre correctamente!',
      '¡Excelente trabajo, $childName! ¡Tu nombre se ve hermoso!',
      '¡Fantástico, $childName! ¡Qué bien escribes tu nombre!',
      '¡Bravo, $childName! ¡Me encanta como escribes!',
      '¡Perfecto, $childName! ¡Tu nombre está muy bien escrito!',
      '¡Qué inteligente eres, $childName! ¡Lo has hecho genial!',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % nameCompletionPhrases.length;
    await speakText(nameCompletionPhrases[random]);
  }

  // Método para saludar al niño por su nombre al iniciar
  Future<void> speakWelcomeWithName(String childName) async {
    if (childName.isEmpty) {
      await speakText('¡Hola! ¡Qué gusto verte aquí para aprender!');
      return;
    }
    
    final welcomePhrases = [
      '¡Hola, $childName! ¡Qué alegría verte de nuevo!',
      '¡Buenos días, $childName! ¿Listos para aprender juntos?',
      '¡Hola, mi querido $childName! ¡Vamos a divertirnos aprendiendo!',
      '¡Qué bueno verte, $childName! ¡Hoy será un día genial!',
      '¡Hola, $childName! ¡Estoy muy feliz de estar contigo!',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % welcomePhrases.length;
    await speakText(welcomePhrases[random]);
  }
}