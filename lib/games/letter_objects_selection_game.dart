import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/letter.dart';
import '../services/audio_service.dart';
import '../providers/letter_city_provider.dart';

class LetterObjectsSelectionGame extends StatefulWidget {
  final Letter letter;
  final AudioService audioService;

  const LetterObjectsSelectionGame({
    super.key,
    required this.letter,
    required this.audioService,
  });

  @override
  State<LetterObjectsSelectionGame> createState() => _LetterObjectsSelectionGameState();
}

class _LetterObjectsSelectionGameState extends State<LetterObjectsSelectionGame> {
  late List<Map<String, dynamic>> _currentObjects;
  late Set<String> _usedWords;
  late Set<String> _usedDistractors;

  @override
  void initState() {
    super.initState();
    _usedWords = {};
    _usedDistractors = {};
    _generateObjects();
  }

  void _generateObjects() {
    final correctObjects = _getObjectsForLetter(widget.letter.character.toUpperCase())
        .where((obj) => obj['correct'] == true && !_usedWords.contains(obj['name']))
        .take(3)
        .toList();
    
    final incorrectObjects = _getObjectsForLetter(widget.letter.character.toUpperCase())
        .where((obj) => obj['correct'] == false && !_usedDistractors.contains(obj['name']))
        .take(1)
        .toList();

    // Agregar a las palabras usadas
    for (final obj in correctObjects) {
      _usedWords.add(obj['name'] as String);
    }
    for (final obj in incorrectObjects) {
      _usedDistractors.add(obj['name'] as String);
    }

    _currentObjects = [...correctObjects, ...incorrectObjects];
    _currentObjects.shuffle();
  }

  void _handleObjectTap(Map<String, dynamic> obj) {
    widget.audioService.stop(); // Detener narración anterior
    
    final wordName = obj['name'] as String;
    final isCorrect = obj['correct'] as bool;
    
    if (isCorrect) {
      widget.audioService.speakText('¡Excelente! $wordName empieza con ${widget.letter.character.toUpperCase()}');
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('object_selection_${widget.letter.character}', 15);
      
      // Generar nuevos objetos después de un acierto
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _generateObjects();
          });
        }
      });
    } else {
      final messages = [
        '¡Muy bien! Pero busca algo que empiece con ${widget.letter.character.toUpperCase()}',
        '¡Sigue intentando! ¿Qué empieza con ${widget.letter.character.toUpperCase()}?',
        '¡Casi! Busca una palabra con ${widget.letter.character.toUpperCase()}',
      ];
      widget.audioService.speakText(messages[math.Random().nextInt(messages.length)]);
      _showFailureFeedback();
    }
  }

  void _showCelebrationStars() {
    // Implementar celebración con estrellas
  }

  void _showFailureFeedback() {
    // Implementar feedback de error
  }

  bool _wordStartsWithLetter(String word, String letter) {
    final wordLower = word.toLowerCase();
    final letterLower = letter.toLowerCase();
    
    // Casos especiales del español argentino
    switch (letterLower) {
      case 'h':
        // En español, la H es muda
        return false;
      case 'll':
        return wordLower.startsWith('ll');
      case 'qu':
        return wordLower.startsWith('qu');
      default:
        return wordLower.startsWith(letterLower);
    }
  }

  List<Map<String, dynamic>> _getObjectsForLetter(String letter) {
    final objectsMap = {
      'A': [
        {'emoji': '🪡', 'name': 'Aguja', 'correct': true},
        {'emoji': '👵', 'name': 'Abuela', 'correct': true},
        {'emoji': '⚓', 'name': 'Ancla', 'correct': true},
        {'emoji': '🍎', 'name': 'Azúcar', 'correct': true},
        {'emoji': '💍', 'name': 'Anillo', 'correct': true},
        {'emoji': '🟫', 'name': 'Alfombra', 'correct': true},
        {'emoji': '🛏️', 'name': 'Almohada', 'correct': true},
        {'emoji': '✈️', 'name': 'Avión', 'correct': true},
        {'emoji': '🧄', 'name': 'Ajo', 'correct': true},
        {'emoji': '🧮', 'name': 'Ábaco', 'correct': true},
        {'emoji': '🏠', 'name': 'Armario', 'correct': true},
        {'emoji': '🐝', 'name': 'Abeja', 'correct': true},
        // Palabras distractoras
        {'emoji': '🐕', 'name': 'Perro', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🍌', 'name': 'Banana', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'B': [
        {'emoji': '🚲', 'name': 'Bicicleta', 'correct': true},
        {'emoji': '🍌', 'name': 'Banana', 'correct': true},
        {'emoji': '⚽', 'name': 'Balón', 'correct': true},
        {'emoji': '🚌', 'name': 'Bus', 'correct': true},
        {'emoji': '🍼', 'name': 'Biberón', 'correct': true},
        {'emoji': '🚢', 'name': 'Barco', 'correct': true},
        {'emoji': '🎯', 'name': 'Blanco', 'correct': true},
        {'emoji': '🥾', 'name': 'Bota', 'correct': true},
        {'emoji': '📘', 'name': 'Libro Azul', 'correct': true},
        {'emoji': '🦋', 'name': 'Mariposa', 'correct': false},
        {'emoji': '🧸', 'name': 'Oso', 'correct': false},
        {'emoji': '📖', 'name': 'Cuento', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'V': [
        {'emoji': '🐄', 'name': 'Vaca', 'correct': true},
        {'emoji': '🥃', 'name': 'Vaso', 'correct': true},
        {'emoji': '🎻', 'name': 'Violín', 'correct': true},
        {'emoji': '⛵', 'name': 'Velero', 'correct': true},
        {'emoji': '🚐', 'name': 'Van', 'correct': true},
        {'emoji': '🌋', 'name': 'Volcán', 'correct': true},
        {'emoji': '🕊️', 'name': 'Vuelo', 'correct': true},
        {'emoji': '📺', 'name': 'Video', 'correct': true},
        {'emoji': '🍇', 'name': 'Uvas', 'correct': false},
        {'emoji': '🐶', 'name': 'Perro', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'X': [
        {'emoji': '🎹', 'name': 'Xilófono', 'correct': true},
        {'emoji': '📋', 'name': 'Examen', 'correct': true},
        {'emoji': '🇲🇽', 'name': 'México', 'correct': true},
        {'emoji': '💨', 'name': 'Oxígeno', 'correct': true},
        {'emoji': '❌', 'name': 'X', 'correct': true},
        {'emoji': '🧬', 'name': 'Xerox', 'correct': true},
        {'emoji': '🔍', 'name': 'Explorar', 'correct': true},
        {'emoji': '📖', 'name': 'Texto', 'correct': true},
        {'emoji': '🐄', 'name': 'Vaca', 'correct': false},
        {'emoji': '🐶', 'name': 'Perro', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'K': [
        {'emoji': '🐨', 'name': 'Koala', 'correct': true},
        {'emoji': '🍅', 'name': 'Ketchup', 'correct': true},
        {'emoji': '⚖️', 'name': 'Kilo', 'correct': true},
        {'emoji': '👘', 'name': 'Kimono', 'correct': true},
        {'emoji': '🛶', 'name': 'Kayak', 'correct': true},
        {'emoji': '🥝', 'name': 'Kiwi', 'correct': true},
        {'emoji': '🏠', 'name': 'Kiosco', 'correct': true},
        {'emoji': '🎤', 'name': 'Karaoke', 'correct': true},
        {'emoji': '🐄', 'name': 'Vaca', 'correct': false},
        {'emoji': '🐶', 'name': 'Perro', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'W': [
        {'emoji': '📻', 'name': 'Walkman', 'correct': true},
        {'emoji': '🏐', 'name': 'Waterpolo', 'correct': true},
        {'emoji': '📶', 'name': 'Wifi', 'correct': true},
        {'emoji': '🌐', 'name': 'Web', 'correct': true},
        {'emoji': '🥃', 'name': 'Whisky', 'correct': true},
        {'emoji': '🍉', 'name': 'Watermelón', 'correct': true},
        {'emoji': '🏄', 'name': 'Windsurf', 'correct': true},
        {'emoji': '⌚', 'name': 'Watch', 'correct': true},
        {'emoji': '🐄', 'name': 'Vaca', 'correct': false},
        {'emoji': '🐶', 'name': 'Perro', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
      'Y': [
        {'emoji': '🛥️', 'name': 'Yate', 'correct': true},
        {'emoji': '🧘', 'name': 'Yoga', 'correct': true},
        {'emoji': '🥚', 'name': 'Yema', 'correct': true},
        {'emoji': '🪀', 'name': 'Yo-yo', 'correct': true},
        {'emoji': '🌿', 'name': 'Yerba', 'correct': true},
        {'emoji': '❄️', 'name': 'Yelo', 'correct': true},
        {'emoji': '🏛️', 'name': 'Yacimiento', 'correct': true},
        {'emoji': '🩹', 'name': 'Yodo', 'correct': true},
        {'emoji': '🐄', 'name': 'Vaca', 'correct': false},
        {'emoji': '🐶', 'name': 'Perro', 'correct': false},
        {'emoji': '🏠', 'name': 'Casa', 'correct': false},
        {'emoji': '🎈', 'name': 'Globo', 'correct': false},
        {'emoji': '🌸', 'name': 'Flor', 'correct': false},
        {'emoji': '🐱', 'name': 'Gato', 'correct': false},
        {'emoji': '🌙', 'name': 'Luna', 'correct': false},
      ],
    };

    return objectsMap[letter] ?? [
      {'emoji': '🎈', 'name': 'Globo', 'correct': false},
      {'emoji': '🌸', 'name': 'Flor', 'correct': false},
      {'emoji': '🐱', 'name': 'Gato', 'correct': false},
      {'emoji': '🌙', 'name': 'Luna', 'correct': false},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Título del juego
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green[400]!,
                  Colors.blue[400]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SELECCIONA LOS OBJETOS QUE EMPIECEN CON ${widget.letter.character.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Instrucciones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue[200]!,
                width: 2,
              ),
            ),
            child: Text(
              '🎯 Toca los objetos que comiencen con la letra ${widget.letter.character.toUpperCase()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 30),

          // Grid de objetos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: _currentObjects.length,
              itemBuilder: (context, index) {
                final obj = _currentObjects[index];
                return _buildObjectCard(obj);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectCard(Map<String, dynamic> obj) {
    final isCorrect = obj['correct'] as bool;

    return GestureDetector(
      onTap: () => _handleObjectTap(obj),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
              Colors.blue[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue[200]!,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Emoji grande
            Text(
              obj['emoji'] as String,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 12),
            // Nombre del objeto
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[100]!,
                    Colors.blue[200]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                obj['name'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}