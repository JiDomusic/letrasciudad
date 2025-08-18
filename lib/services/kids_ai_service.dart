import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../config/ai_config.dart';

/// Servicio de IA especializado para niños argentinos
/// Con filtros de seguridad y contenido educativo
class KidsAIService {
  late final GenerativeModel _model;
  final ProfanityFilter _profanityFilter = ProfanityFilter();

  KidsAIService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AIConfig.googleAIApiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.low),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      generationConfig: GenerationConfig(
        temperature: 0.3, // Más conservador para niños
        topK: 20,
        topP: 0.8,
        maxOutputTokens: 200, // Respuestas cortas
      ),
    );
  }

  /// Obtiene información educativa sobre una letra específica
  Future<String> getLetterInfo(String letter) async {
    if (!AIConfig.argentineAlphabet.contains(letter.toUpperCase())) {
      return 'Lo siento, esa no es una letra válida del alfabeto argentino.';
    }
    
    // Si no está configurada la API, usar modo demo
    if (!AIConfig.isConfigured && AIConfig.enableDemoMode) {
      return _getFallbackResponse(letter);
    }

    final prompt = _createLetterPrompt(letter.toUpperCase());
    
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return _getFallbackResponse(letter);
      }
      
      // Aplicar filtros de seguridad
      final filteredText = _applySafetyFilters(response.text!);
      return filteredText;
      
    } catch (e) {
      print('Error en IA: $e');
      return _getFallbackResponse(letter);
    }
  }

  /// Genera palabras argentinas que empiecen con la letra
  Future<List<String>> getArgentineWords(String letter) async {
    final prompt = '''
Eres un asistente educativo para niños argentinos de 4-8 años.
Lista 8 palabras argentinas que empiecen con la letra "${letter.toUpperCase()}".
Las palabras deben ser:
- Apropiadas para niños
- Familiares en Argentina (incluyendo comidas, animales, objetos cotidianos)
- Fáciles de pronunciar
- Sin contenido inapropiado

Formato: solo las palabras separadas por comas, sin explicaciones.
Ejemplo: CASA, COCHE, CAMA, CANTO
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        final words = response.text!
            .split(',')
            .map((word) => word.trim().toUpperCase())
            .where((word) => word.isNotEmpty && word.startsWith(letter.toUpperCase()))
            .take(8)
            .toList();
        
        return words.isNotEmpty ? words : _getFallbackWords(letter);
      }
      
    } catch (e) {
      print('Error obteniendo palabras: $e');
    }
    
    return _getFallbackWords(letter);
  }

  /// Cuenta una historia corta con la letra
  Future<String> tellLetterStory(String letter) async {
    final prompt = '''
Eres un cuentacuentos para niños argentinos de 4-8 años.
Cuenta una historia MUY CORTA (máximo 3 oraciones) sobre la letra "${letter.toUpperCase()}".
La historia debe:
- Ser apropiada para niños pequeños
- Incluir palabras argentinas con esa letra
- Ser alegre y educativa
- Usar vocabulario simple

Ejemplo para "M": "Marta la mariposa vive en Mendoza. Le gusta comer miel y mirar las montañas. ¡Qué feliz es Marta volando por el cielo!"
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        final story = _applySafetyFilters(response.text!);
        return story;
      }
      
    } catch (e) {
      print('Error en historia: $e');
    }
    
    return _getFallbackStory(letter);
  }

  /// Crea el prompt principal para información de letras
  String _createLetterPrompt(String letter) {
    return '''
Eres un asistente educativo especializado en enseñar el alfabeto a niños argentinos de 4-8 años.
Explica la letra "${letter}" de manera simple y divertida.

Incluye:
1. Cómo se pronuncia en Argentina
2. 3 palabras argentinas comunes que empiecen con esta letra
3. Un dato curioso o divertido sobre la letra
4. Una frase motivadora para el niño

Usa un lenguaje simple, alegre y apropiado para niños argentinos.
Máximo 100 palabras.
''';
  }

  /// Aplica filtros de seguridad adicionales
  String _applySafetyFilters(String text) {
    // Filtro de profanidad
    String filteredText = _profanityFilter.censor(text);
    
    // Filtros adicionales específicos
    final inappropriateWords = [
      'violencia', 'pelea', 'guerra', 'muerte', 'miedo', 'triste',
      'malo', 'odio', 'arma', 'pistola', 'sangre'
    ];
    
    for (String word in inappropriateWords) {
      filteredText = filteredText.replaceAll(
        RegExp(word, caseSensitive: false), 
        '***'
      );
    }
    
    // Limitar longitud para niños
    if (filteredText.length > 300) {
      filteredText = filteredText.substring(0, 297) + '...';
    }
    
    return filteredText;
  }

  /// Respuestas de respaldo si falla la IA
  String _getFallbackResponse(String letter) {
    final fallbacks = {
      'A': '¡La letra A es súper divertida! Suena como "ah". Podemos decir: AUTO, ÁRBOL, AGUA. ¡La A está en muchas palabras que usamos todos los días!',
      'B': '¡La letra B hace "beh"! Como en BARCO, BEBÉ, BICICLETA. ¡Es una letra muy bonita y está en muchas cosas que nos gustan!',
      'C': '¡La letra C puede sonar como "ce" o "ka"! Como en CASA, COCHE, COMIDA. ¡La C nos ayuda a escribir muchas palabras lindas!',
      'Ñ': '¡La letra Ñ es especial del español! Suena como "eñe". Como en NIÑO, BAÑO, SUEÑO. ¡Es única y muy importante en Argentina!',
    };
    
    return fallbacks[letter] ?? '¡La letra $letter es genial! Vamos a aprender juntos sobre esta letra tan especial.';
  }

  /// Palabras de respaldo
  List<String> _getFallbackWords(String letter) {
    final fallbackWords = {
      'A': ['AUTO', 'ÁRBOL', 'AGUA', 'AVIÓN', 'AZUL', 'AMIGO'],
      'B': ['BARCO', 'BEBÉ', 'BICICLETA', 'BANANA', 'BONITO', 'BAÑO'],
      'C': ['CASA', 'COCHE', 'COMIDA', 'CIELO', 'CAMA', 'CANTO'],
      'D': ['DULCE', 'DIENTE', 'DADO', 'DINOSAURIO', 'DOMINGO', 'DIBUJO'],
      'E': ['ELEFANTE', 'ESCUELA', 'ESTRELLA', 'EMPANADA', 'EDIFICIO', 'ESPEJO'],
      'F': ['FAMILIA', 'FLOR', 'FUEGO', 'FÚTBOL', 'FOCA', 'FRUTA'],
      'G': ['GATO', 'GLOBO', 'GUITARRA', 'GRANDE', 'GALLETA', 'GIRASOL'],
      'H': ['HELADO', 'HORMIGA', 'HOSPITAL', 'HERMANO', 'HUEVO', 'HORA'],
      'I': ['IGLESIA', 'ISLA', 'IMÁN', 'INSECTO', 'IDEA', 'INVIERNO'],
      'J': ['JARDÍN', 'JIRAFA', 'JUEGO', 'JABÓN', 'JUGUETE', 'JOYA'],
      'K': ['KIWI', 'KARATE', 'KOALA', 'KAYAK', 'KIOSCO', 'KILÓMETRO'],
      'L': ['LUNA', 'LIBRO', 'LEÓN', 'LECHE', 'LIMÓN', 'LÁPIZ'],
      'M': ['MAMÁ', 'MESA', 'MONO', 'MANZANA', 'MÚSICA', 'MARIPOSA'],
      'N': ['NUBE', 'NARIZ', 'NARANJA', 'NOCHE', 'NIETO', 'NIDO'],
      'Ñ': ['NIÑO', 'BAÑO', 'SUEÑO', 'AÑO', 'SOÑAR', 'PEQUEÑO'],
      'O': ['OSO', 'OJO', 'OVEJA', 'OREJA', 'OCÉANO', 'OFICINA'],
      'P': ['PAPÁ', 'PERRO', 'PAN', 'PELOTA', 'PÁJARO', 'PIZZA'],
      'Q': ['QUESO', 'QUIOSCO', 'QUERER', 'QUITAR', 'QUINCHO', 'QUIETO'],
      'R': ['ROJO', 'RATÓN', 'RISA', 'RADIO', 'REGALO', 'RÍO'],
      'S': ['SOL', 'SAPO', 'SILLA', 'SONRISA', 'SOPA', 'SEMANA'],
      'T': ['TELEVISIÓN', 'TREN', 'TAZA', 'TIGRE', 'TARDE', 'TANGO'],
      'U': ['UVA', 'UNICORNIO', 'UNIVERSO', 'ÚLTIMO', 'UNIÓN', 'USAR'],
      'V': ['VACA', 'VASO', 'VIOLÍN', 'VELERO', 'VENTANA', 'VERDE'],
      'W': ['WIFI', 'WEB', 'WEBCAM', 'WALKIE', 'WHISKY', 'WALTER'],
      'X': ['XILÓFONO', 'EXAMEN', 'ÉXITO', 'TAXI', 'TEXTO', 'SEXTO'],
      'Y': ['YATE', 'YOGUR', 'YERBA', 'YEMA', 'YERNO', 'YOGA'],
      'Z': ['ZAPATO', 'ZOOLÓGICO', 'ZANAHORIA', 'ZONA', 'ZORRO', 'ZÓCALO'],
    };
    
    return fallbackWords[letter] ?? ['PALABRA'];
  }

  /// Historias de respaldo
  String _getFallbackStory(String letter) {
    return '¡Había una vez la letra $letter que vivía en Argentina! Le gustaba jugar con las palabras y hacer sonidos divertidos. ¡Era muy feliz ayudando a los niños a aprender!';
  }

  /// Verifica si la API está configurada
  bool get isConfigured => AIConfig.isConfigured;
}