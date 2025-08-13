import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  double _volume = 1.0;
  double _speechRate = 0.8; // Velocidad más rápida y activa para personaje animado
  double _speechPitch = 1.3; // Pitch femenino animado como dibujito

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
      
      // Configuración universal con voz de niña
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.7); // Más lento para niños
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.5); // Pitch más alto para voz de niña
      
      // Probar hablar para verificar funcionamiento (SIN DELAY para mejor sincronización)
      debugPrint('🧪 Probando TTS con voz de niña...');
      _flutterTts.speak("¡Hola! Soy tu amiga virtual");
      // REMOVIDO: await Future.delayed() para respuesta inmediata
      
      _isInitialized = true;
      debugPrint('✅ AudioService inicializado correctamente con voz de niña');
    } catch (e) {
      debugPrint('❌ Error initializing AudioService: $e');
      // Reintentar con configuración mínima
      await _fallbackInitialization();
    }
  }

  Future<void> _configureWebTTS() async {
    try {
      debugPrint('🌐 Configurando TTS para Web con voces específicas');
      await _flutterTts.setLanguage("es-ES");
      
      // Lista de voces preferidas para niñas (ordenadas por preferencia)
      final preferredVoices = [
        // Voces de Google más naturales para niñas
        'Google español (España) - Carmen (Femenina)',
        'Google español (España) - Elena (Femenina)',
        'Google español (España) - Sofia (Femenina)',
        'Google español (México) - Angelica (Femenina)',
        'Google español (Argentina) - Isabella (Femenina)',
        
        // Voces de Microsoft
        'Microsoft Helena - Spanish (Spain)',
        'Microsoft Sabina - Spanish (Mexico)',
        'Microsoft Maria - Spanish (Spain)',
        
        // Voces nativas del navegador
        'Mónica',
        'Carmen',
        'Elena',
        'Sofia',
        'Paulina',
        'Marisol',
        'Esperanza',
        
        // Voces genéricas pero femeninas
        'Spanish (Spain) Female',
        'Spanish Female',
        'es-ES Female',
        'es-MX Female'
      ];
      
      // Obtener todas las voces disponibles
      dynamic voices = await _flutterTts.getVoices;
      debugPrint('🎤 Voces disponibles: ${voices?.length ?? 0}');
      
      if (voices is List) {
        // Imprimir todas las voces para debugging
        for (int i = 0; i < voices.length && i < 10; i++) {
          final voice = voices[i];
          if (voice is Map) {
            debugPrint('📢 Voz $i: ${voice['name']} (${voice['locale']})');
          }
        }
        
        // Intentar configurar la mejor voz disponible
        bool voiceSet = false;
        
        // Buscar voces preferidas en orden de preferencia
        for (String preferredVoice in preferredVoices) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['name'] != null) {
              String voiceName = voice['name'].toString();
              // String locale = voice['locale']?.toString() ?? '';
              
              if (voiceName.toLowerCase().contains(preferredVoice.toLowerCase()) ||
                  (voice['locale']?.toString().contains('es') == true && voiceName.toLowerCase().contains('female'))) {
                debugPrint('✅ Configurando voz preferida: $voiceName');
                await _flutterTts.setVoice(Map<String, String>.from(voice));
                voiceSet = true;
                break;
              }
            }
          }
          if (voiceSet) break;
        }
        
        // Si no encontramos una voz específica, buscar cualquier voz femenina en español
        if (!voiceSet) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['locale'] != null) {
              String locale = voice['locale'].toString().toLowerCase();
              String voiceName = voice['name']?.toString().toLowerCase() ?? '';
              
              if ((locale.contains('es-es') || locale.contains('es_es') || 
                   locale.contains('es-mx') || locale.contains('es_mx') ||
                   locale.contains('spa')) &&
                  !voiceName.contains('male') &&
                  (voiceName.contains('female') || voiceName.contains('mujer') ||
                   voiceName.contains('woman') || voiceName.isEmpty)) {
                debugPrint('🎯 Configurando voz femenina alternativa: $voiceName');
                await _flutterTts.setVoice(Map<String, String>.from(voice));
                voiceSet = true;
                break;
              }
            }
          }
        }
        
        if (!voiceSet) {
          debugPrint('⚠️ No se encontró voz femenina específica, usando configuración por defecto');
        }
      }
      
      // Configuración adicional para web - NO ESPERAR completion para mejor sincronización
      await _flutterTts.awaitSpeakCompletion(false);
      
    } catch (e) {
      debugPrint('⚠️ Error configurando voz para web: $e');
    }
  }

  Future<void> _configureMobileTTS() async {
    try {
      debugPrint('📱 Configurando TTS para móvil con voces premium');
      await _flutterTts.setLanguage("es-ES");
      
      // Lista de motores de TTS preferidos (ordenados por calidad)
      final preferredEngines = [
        "com.google.android.tts", // Google TTS (mejor calidad)
        "com.samsung.android.tts", // Samsung TTS
        "com.android.tts", // Android TTS por defecto
      ];
      
      // Intentar configurar el mejor motor disponible
      for (String engine in preferredEngines) {
        try {
          debugPrint('🔧 Intentando motor: $engine');
          await _flutterTts.setEngine(engine);
          break;
        } catch (engineError) {
          debugPrint('⚠️ Motor $engine no disponible: $engineError');
          continue;
        }
      }
      
      // Lista de voces preferidas para móvil (niñas)
      final mobilePreferredVoices = [
        // Voces de Google para Android
        'es-es-x-eea-network', // Voz neural de Google España
        'es-es-x-eea-local',
        'es-mx-x-eem-network', // Voz neural de Google México
        'es-mx-x-eem-local',
        'es-ar-x-ard-network', // Voz neural de Google Argentina
        
        // Voces tradicionales de alta calidad
        'Google español (España)',
        'Google español (México)',
        'Google español (Argentina)',
        
        // Voces Samsung
        'Samsung Carmen',
        'Samsung Elena',
        'Samsung Sofia',
        
        // Voces genéricas
        'Spanish (Spain)',
        'Spanish (Mexico)',
        'Español (España)',
        'Español (México)',
      ];
      
      // Obtener voces disponibles
      dynamic voices = await _flutterTts.getVoices;
      debugPrint('📱 Voces móviles disponibles: ${voices?.length ?? 0}');
      
      if (voices is List) {
        // Mostrar algunas voces para debugging
        for (int i = 0; i < voices.length && i < 5; i++) {
          final voice = voices[i];
          if (voice is Map) {
            debugPrint('📱 Voz móvil $i: ${voice['name']} (${voice['locale']})');
          }
        }
        
        bool mobileVoiceSet = false;
        
        // Buscar voces preferidas para móvil
        for (String preferredVoice in mobilePreferredVoices) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['name'] != null) {
              String voiceName = voice['name'].toString();
              // String locale = voice['locale']?.toString() ?? '';
              
              if (voiceName.toLowerCase().contains(preferredVoice.toLowerCase())) {
                debugPrint('✅ Configurando voz móvil preferida: $voiceName');
                try {
                  await _flutterTts.setVoice(Map<String, String>.from(voice));
                  mobileVoiceSet = true;
                  break;
                } catch (voiceError) {
                  debugPrint('⚠️ Error configurando voz $voiceName: $voiceError');
                  continue;
                }
              }
            }
          }
          if (mobileVoiceSet) break;
        }
        
        // Búsqueda alternativa si no encontramos voces preferidas
        if (!mobileVoiceSet) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['locale'] != null) {
              String locale = voice['locale'].toString().toLowerCase();
              String voiceName = voice['name']?.toString().toLowerCase() ?? '';
              
              // Buscar cualquier voz femenina en español
              if ((locale.startsWith('es') || locale.contains('spa')) &&
                  !voiceName.contains('male') &&
                  !voiceName.contains('hombre')) {
                debugPrint('🎯 Configurando voz móvil alternativa: $voiceName');
                try {
                  await _flutterTts.setVoice(Map<String, String>.from(voice));
                  mobileVoiceSet = true;
                  break;
                } catch (voiceError) {
                  debugPrint('⚠️ Error con voz alternativa: $voiceError');
                  continue;
                }
              }
            }
          }
        }
        
        if (!mobileVoiceSet) {
          debugPrint('⚠️ No se encontró voz femenina específica en móvil');
        }
        
        // Configuraciones adicionales para móvil - NO ESPERAR completion para mejor sincronización
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
      await _flutterTts.setLanguage("es");
      await _flutterTts.setSpeechRate(0.7);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.5);
      
      _isInitialized = true;
      debugPrint('✅ AudioService inicializado con configuración de respaldo');
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
    try {
      debugPrint('🎤 Hablar INMEDIATO: "$text"');
      
      if (!_isInitialized) {
        debugPrint('⚠️ TTS no inicializado, inicialización rápida...');
        await initialize();
      }
      
      // RESPUESTA INMEDIATA: detener cualquier audio anterior y hablar inmediatamente
      await _flutterTts.stop();
      
      // Configuración mínima y rápida sin delays
      _flutterTts.setLanguage("es-ES");
      _flutterTts.setSpeechRate(0.8); // Ligeramente más rápida para respuesta inmediata
      _flutterTts.setPitch(1.5); // Voz de niña
      _flutterTts.setVolume(1.0);
      
      // COMANDO INMEDIATO sin await para no bloquear la UI
      _flutterTts.speak(text);
      debugPrint('✅ Audio INMEDIATO enviado: "$text"');
      
    } catch (e) {
      debugPrint('❌ Error audio inmediato: $e');
      // Reintentar con método simplificado
      try {
        await _flutterTts.stop();
        _flutterTts.speak(text);
      } catch (retryError) {
        debugPrint('❌ Error en reintento inmediato: $retryError');
      }
    }
  }

  Future<void> _ensureChildVoiceSettings() async {
    try {
      // Configurar parámetros optimizados para voz de niña
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.7); // Más lento para que niños entiendan
      await _flutterTts.setPitch(1.5); // Pitch alto para voz de niña
      await _flutterTts.setVolume(1.0);
      
      // Actualizar variables internas
      _speechRate = 0.7;
      _speechPitch = 1.5;
      _volume = 1.0;
      
    } catch (e) {
      debugPrint('⚠️ Error configurando voz de niña: $e');
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
}