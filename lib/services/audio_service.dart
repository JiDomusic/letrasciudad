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
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_speechPitch);
      
      if (!kIsWeb) {
        // Buscar voces femeninas animadas para personaje de dibujos
        final voices = await _flutterTts.getVoices;
        if (voices != null) {
          // Prioridad 1: Voces femeninas jóvenes y expresivas en español
          var preferredVoices = voices.where((voice) => 
            (voice['name']?.toString().toLowerCase().contains('female') == true ||
             voice['name']?.toString().toLowerCase().contains('mujer') == true ||
             voice['name']?.toString().toLowerCase().contains('woman') == true ||
             voice['name']?.toString().toLowerCase().contains('girl') == true ||
             voice['name']?.toString().toLowerCase().contains('young') == true ||
             voice['name']?.toString().toLowerCase().contains('elena') == true ||
             voice['name']?.toString().toLowerCase().contains('sofia') == true ||
             voice['name']?.toString().toLowerCase().contains('maria') == true ||
             voice['name']?.toString().toLowerCase().contains('lucia') == true ||
             voice['name']?.toString().toLowerCase().contains('carmen') == true) &&
             voice['locale']?.toString().startsWith('es') == true &&
             !(voice['name']?.toString().toLowerCase().contains('old') ?? false) &&
             !(voice['name']?.toString().toLowerCase().contains('senior') ?? false)
          ).toList();
          
          // Prioridad 2: Cualquier voz femenina en español si no hay específicas
          if (preferredVoices.isEmpty) {
            preferredVoices = voices.where((voice) => 
              (voice['name']?.toString().toLowerCase().contains('female') == true ||
               voice['name']?.toString().toLowerCase().contains('woman') == true) &&
               voice['locale']?.toString().startsWith('es') == true
            ).toList();
          }
          
          if (preferredVoices.isNotEmpty) {
            await _flutterTts.setVoice(preferredVoices.first);
            debugPrint('Usando voz animada femenina: ${preferredVoices.first['name']}');
          } else {
            // Buscar cualquier voz en español
            final spanishVoices = voices.where((voice) => 
              voice['locale']?.toString().startsWith('es') == true
            ).toList();
            
            if (spanishVoices.isNotEmpty) {
              await _flutterTts.setVoice(spanishVoices.first);
              debugPrint('Usando voz en español: ${spanishVoices.first['name']}');
            }
          }
        }
      } else {
        // En web, configurar voz femenina española expresiva
        try {
          await _flutterTts.setVoice({
            "name": "Microsoft Helena - Spanish (Spain)",
            "locale": "es-ES"
          });
          debugPrint('Usando Helena (voz femenina española)');
        } catch (e) {
          try {
            await _flutterTts.setVoice({
              "name": "Google español",
              "locale": "es-ES"
            });
            debugPrint('Usando Google español (femenina)');
          } catch (e2) {
            await _flutterTts.setVoice({
              "name": "es-ES",
              "locale": "es-ES"
            });
            debugPrint('Usando voz española por defecto');
          }
        }
      }
      
      await _flutterTts.awaitSpeakCompletion(true);
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
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
    await initialize();
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $text, Error: $e');
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