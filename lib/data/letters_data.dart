import 'package:flutter/material.dart';
import '../models/letter.dart';

class LettersData {
  static final List<Letter> _letters = [
    const Letter(
      character: 'A',
      name: 'a',
      phoneme: 'ah',
      syllables: ['a'],
      exampleWords: ['auto', 'abuela', 'ancla', 'árbol', 'anillo', 'alfombra', 'almohada', 'avión'],
      imagePath: 'assets/letters/a_house.png',
      audioPath: 'assets/audio/letters/a.mp3',
      primaryColor: Colors.red,
      isUnlocked: true,
      activities: [
        Activity(
          id: 'object_selection_A',
          name: 'Selección de objetos con A',
          description: 'Encuentra objetos que empiezan con A',
          type: ActivityType.wordReading,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Toca los objetos que empiecen con la letra A',
        ),
        Activity(
          id: 'letter_tracing_A',
          name: 'Trazado de la letra A',
          description: 'Aprende a trazar la letra A',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra A con tu dedo siguiendo la guía',
        ),
        Activity(
          id: 'find_letter_A',
          name: 'Encuentra la letra A',
          description: 'Busca y encuentra todas las letras A',
          type: ActivityType.wordReading,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Encuentra todas las letras A en la pantalla',
        ),
      ],
    ),
    Letter(
      character: 'B',
      name: 'be',
      phoneme: 'beh',
      syllables: ['ba', 'be', 'bi', 'bo', 'bu'],
      exampleWords: ['banana', 'barco', 'bebé', 'bola'],
      imagePath: 'assets/letters/b_house.png',
      audioPath: 'assets/audio/letters/b.mp3',
      primaryColor: Colors.blue,
      activities: [
        Activity(
          id: 'b_syllables',
          name: 'Sílabas con B',
          description: 'Aprende las sílabas ba, be, bi, bo, bu',
          type: ActivityType.syllables,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Escucha y repite cada sílaba',
        ),
        Activity(
          id: 'letter_tracing_B',
          name: 'Trazado de la letra B',
          description: 'Aprende a trazar la letra B',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra B con tu dedo siguiendo la guía',
        ),
        Activity(
          id: 'b_word_formation',
          name: 'Forma palabras con B',
          description: 'Arrastra las sílabas para formar palabras',
          type: ActivityType.dragDrop,
          difficulty: DifficultyLevel.intermediate,
          instruction: 'Arrastra las sílabas en el orden correcto',
          data: {
            'words': [
              {
                'availableSyllables': ['ba', 'na', 'na'],
                'targetWord': 'banana',
                'imageUrl': 'assets/images/banana.png',
                'audioUrl': 'assets/audio/words/banana.mp3',
              },
              {
                'availableSyllables': ['bar', 'co'],
                'targetWord': 'barco',
                'imageUrl': 'assets/images/barco.png',
                'audioUrl': 'assets/audio/words/barco.mp3',
              },
            ]
          },
        ),
      ],
    ),
    Letter(
      character: 'C',
      name: 'ce',
      phoneme: 'seh',
      syllables: ['ca', 'ce', 'ci', 'co', 'cu'],
      exampleWords: ['cielo', 'cereza', 'ciudad', 'corazón'],
      imagePath: 'assets/letters/c_house.png',
      audioPath: 'assets/audio/letters/c.mp3',
      primaryColor: Colors.orange,
      activities: [
        Activity(
          id: 'letter_tracing_C',
          name: 'Trazado de la letra C',
          description: 'Aprende a trazar la letra C',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra C con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'D',
      name: 'de',
      phoneme: 'deh',
      syllables: ['da', 'de', 'di', 'do', 'du'],
      exampleWords: ['dedo', 'dinosaurio', 'dulce', 'cuchillo'],
      imagePath: 'assets/letters/d_house.png',
      audioPath: 'assets/audio/letters/d.mp3',
      primaryColor: Colors.green,
      activities: [
        Activity(
          id: 'letter_tracing_D',
          name: 'Trazado de la letra D',
          description: 'Aprende a trazar la letra D',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra D con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'E',
      name: 'e',
      phoneme: 'eh',
      syllables: ['e'],
      exampleWords: ['elefante', 'estrella', 'escuela', 'espejo'],
      imagePath: 'assets/letters/e_house.png',
      audioPath: 'assets/audio/letters/e.mp3',
      primaryColor: Colors.purple,
      activities: [
        Activity(
          id: 'letter_tracing_E',
          name: 'Trazado de la letra E',
          description: 'Aprende a trazar la letra E',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra E con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'F',
      name: 'efe',
      phoneme: 'feh',
      syllables: ['fa', 'fe', 'fi', 'fo', 'fu'],
      exampleWords: ['flor', 'fuego', 'familia', 'foto'],
      imagePath: 'assets/letters/f_house.png',
      audioPath: 'assets/audio/letters/f.mp3',
      primaryColor: Colors.pink,
      activities: [
        Activity(
          id: 'letter_tracing_F',
          name: 'Trazado de la letra F',
          description: 'Aprende a trazar la letra F',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra F con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'G',
      name: 'ge',
      phoneme: 'heh',
      syllables: ['ga', 'ge', 'gi', 'go', 'gu'],
      exampleWords: ['gato', 'globo', 'guitarra', 'goma'],
      imagePath: 'assets/letters/g_house.png',
      audioPath: 'assets/audio/letters/g.mp3',
      primaryColor: Colors.teal,
      activities: [
        Activity(
          id: 'letter_tracing_G',
          name: 'Trazado de la letra G',
          description: 'Aprende a trazar la letra G',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra G con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'H',
      name: 'hache',
      phoneme: 'silent',
      syllables: ['ha', 'he', 'hi', 'ho', 'hu'],
      exampleWords: ['hielo', 'hospital', 'huevo', 'hermano'],
      imagePath: 'assets/letters/h_house.png',
      audioPath: 'assets/audio/letters/h.mp3',
      primaryColor: Colors.brown,
      activities: [
        Activity(
          id: 'letter_tracing_H',
          name: 'Trazado de la letra H',
          description: 'Aprende a trazar la letra H',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra H con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'I',
      name: 'i',
      phoneme: 'ee',
      syllables: ['i'],
      exampleWords: ['iglesia', 'isla', 'imán', 'indio'],
      imagePath: 'assets/letters/i_house.png',
      audioPath: 'assets/audio/letters/i.mp3',
      primaryColor: Colors.indigo,
      activities: [
        Activity(
          id: 'word_recognition_i',
          name: 'Reconocimiento de palabras con i',
          description: 'Identifica objetos que empiecen con i',
          type: ActivityType.wordReading,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Toca los objetos que empiecen con la letra i',
        ),
        Activity(
          id: 'letter_tracing_i',
          name: 'Trazado de la letra i',
          description: 'Aprende a trazar la letra i (línea vertical + punto)',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra i: primero la línea vertical, luego el punto arriba',
        ),
        Activity(
          id: 'find_letter_i',
          name: 'Encuentra la letra i',
          description: 'Busca y encuentra todas las letras i',
          type: ActivityType.wordReading,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Encuentra todas las letras i en la pantalla',
        ),
      ],
    ),
    Letter(
      character: 'J',
      name: 'jota',
      phoneme: 'hota',
      syllables: ['ja', 'je', 'ji', 'jo', 'ju'],
      exampleWords: ['jirafa', 'juego', 'jardín', 'joven'],
      imagePath: 'assets/letters/j_house.png',
      audioPath: 'assets/audio/letters/j.mp3',
      primaryColor: Colors.lime,
      activities: [
        Activity(
          id: 'letter_tracing_J',
          name: 'Trazado de la letra J',
          description: 'Aprende a trazar la letra J',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra J con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'K',
      name: 'ka',
      phoneme: 'kah',
      syllables: ['ka', 'ke', 'ki', 'ko', 'ku'],
      exampleWords: ['kilo', 'karate', 'kiwi', 'koala'],
      imagePath: 'assets/letters/k_house.png',
      audioPath: 'assets/audio/letters/k.mp3',
      primaryColor: Colors.cyan,
      activities: [
        Activity(
          id: 'letter_tracing_K',
          name: 'Trazado de la letra K',
          description: 'Aprende a trazar la letra K',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra K con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'L',
      name: 'ele',
      phoneme: 'leh',
      syllables: ['la', 'le', 'li', 'lo', 'lu'],
      exampleWords: ['luna', 'león', 'libro', 'lápiz'],
      imagePath: 'assets/letters/l_house.png',
      audioPath: 'assets/audio/letters/l.mp3',
      primaryColor: Colors.lightBlue,
      activities: [
        Activity(
          id: 'letter_tracing_L',
          name: 'Trazado de la letra L',
          description: 'Aprende a trazar la letra L',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra L con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'M',
      name: 'eme',
      phoneme: 'meh',
      syllables: ['ma', 'me', 'mi', 'mo', 'mu'],
      exampleWords: ['mamá', 'mesa', 'miel', 'montaña'],
      imagePath: 'assets/letters/m_house.png',
      audioPath: 'assets/audio/letters/m.mp3',
      primaryColor: Colors.deepOrange,
      activities: [
        Activity(
          id: 'letter_tracing_M',
          name: 'Trazado de la letra M',
          description: 'Aprende a trazar la letra M',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra M con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'N',
      name: 'ene',
      phoneme: 'neh',
      syllables: ['na', 'ne', 'ni', 'no', 'nu'],
      exampleWords: ['niño', 'naranja', 'noche', 'nube'],
      imagePath: 'assets/letters/n_house.png',
      audioPath: 'assets/audio/letters/n.mp3',
      primaryColor: Colors.amber,
      activities: [
        Activity(
          id: 'letter_tracing_N',
          name: 'Trazado de la letra N',
          description: 'Aprende a trazar la letra N',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra N con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'Ñ',
      name: 'eñe',
      phoneme: 'nyeh',
      syllables: ['ña', 'ñe', 'ñi', 'ño', 'ñu'],
      exampleWords: ['ñoquis', 'sueño', 'pequeño', 'niño'],
      imagePath: 'assets/letters/nn_house.png',
      audioPath: 'assets/audio/letters/nn.mp3',
      primaryColor: Colors.deepPurple,
      activities: [
        Activity(
          id: 'letter_tracing_Ñ',
          name: 'Trazado de la letra Ñ',
          description: 'Aprende a trazar la letra Ñ',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra Ñ con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'O',
      name: 'o',
      phoneme: 'oh',
      syllables: ['o'],
      exampleWords: ['oso', 'ojo', 'oveja', 'oro'],
      imagePath: 'assets/letters/o_house.png',
      audioPath: 'assets/audio/letters/o.mp3',
      primaryColor: Colors.redAccent,
      activities: [
        Activity(
          id: 'letter_tracing_O',
          name: 'Trazado de la letra O',
          description: 'Aprende a trazar la letra O',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra O con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'P',
      name: 'pe',
      phoneme: 'peh',
      syllables: ['pa', 'pe', 'pi', 'po', 'pu'],
      exampleWords: ['papa', 'pelota', 'pino', 'pollo'],
      imagePath: 'assets/letters/p_house.png',
      audioPath: 'assets/audio/letters/p.mp3',
      primaryColor: Colors.lightGreen,
      activities: [
        Activity(
          id: 'letter_tracing_P',
          name: 'Trazado de la letra P',
          description: 'Aprende a trazar la letra P',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra P con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'Q',
      name: 'cu',
      phoneme: 'kuh',
      syllables: ['que', 'qui'],
      exampleWords: ['queso', 'quinoa', 'querer', 'quinto'],
      imagePath: 'assets/letters/q_house.png',
      audioPath: 'assets/audio/letters/q.mp3',
      primaryColor: Colors.blueGrey,
      activities: [
        Activity(
          id: 'letter_tracing_Q',
          name: 'Trazado de la letra Q',
          description: 'Aprende a trazar la letra Q',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra Q con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'R',
      name: 'erre',
      phoneme: 'reh',
      syllables: ['ra', 're', 'ri', 'ro', 'ru'],
      exampleWords: ['ratón', 'regalo', 'río', 'rosa'],
      imagePath: 'assets/letters/r_house.png',
      audioPath: 'assets/audio/letters/r.mp3',
      primaryColor: Colors.red,
      activities: [
        Activity(
          id: 'letter_tracing_R',
          name: 'Trazado de la letra R',
          description: 'Aprende a trazar la letra R',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra R con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'S',
      name: 'ese',
      phoneme: 'seh',
      syllables: ['sa', 'se', 'si', 'so', 'su'],
      exampleWords: ['sol', 'serpiente', 'sillón', 'suma'],
      imagePath: 'assets/letters/s_house.png',
      audioPath: 'assets/audio/letters/s.mp3',
      primaryColor: Colors.yellow,
      activities: [
        Activity(
          id: 'letter_tracing_S',
          name: 'Trazado de la letra S',
          description: 'Aprende a trazar la letra S',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra S con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'T',
      name: 'te',
      phoneme: 'teh',
      syllables: ['ta', 'te', 'ti', 'to', 'tu'],
      exampleWords: ['torta', 'teléfono', 'tortuga', 'tren'],
      imagePath: 'assets/letters/t_house.png',
      audioPath: 'assets/audio/letters/t.mp3',
      primaryColor: Colors.green,
      activities: [
        Activity(
          id: 'letter_tracing_T',
          name: 'Trazado de la letra T',
          description: 'Aprende a trazar la letra T',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra T con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'U',
      name: 'u',
      phoneme: 'oo',
      syllables: ['u'],
      exampleWords: ['uva', 'universo', 'unicornio', 'uno'],
      imagePath: 'assets/letters/u_house.png',
      audioPath: 'assets/audio/letters/u.mp3',
      primaryColor: Colors.purple,
      activities: [
        Activity(
          id: 'letter_tracing_U',
          name: 'Trazado de la letra U',
          description: 'Aprende a trazar la letra U',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra U con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'V',
      name: 've',
      phoneme: 'veh',
      syllables: ['va', 've', 'vi', 'vo', 'vu'],
      exampleWords: ['vaca', 'ventana', 'violín', 'volcán'],
      imagePath: 'assets/letters/v_house.png',
      audioPath: 'assets/audio/letters/v.mp3',
      primaryColor: Colors.teal,
      activities: [
        Activity(
          id: 'letter_tracing_V',
          name: 'Trazado de la letra V',
          description: 'Aprende a trazar la letra V',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra V con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'W',
      name: 'doble ve',
      phoneme: 'weh',
      syllables: ['wa', 'we', 'wi', 'wo', 'wu'],
      exampleWords: ['wafle', 'whisky', 'wifi', 'web'],
      imagePath: 'assets/letters/w_house.png',
      audioPath: 'assets/audio/letters/w.mp3',
      primaryColor: Colors.indigo,
      activities: [
        Activity(
          id: 'letter_tracing_W',
          name: 'Trazado de la letra W',
          description: 'Aprende a trazar la letra W',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra W con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'X',
      name: 'equis',
      phoneme: 'eks',
      syllables: ['xa', 'xe', 'xi', 'xo', 'xu'],
      exampleWords: ['xilófono', 'examen', 'México', 'oxígeno'],
      imagePath: 'assets/letters/x_house.png',
      audioPath: 'assets/audio/letters/x.mp3',
      primaryColor: Colors.brown,
      activities: [
        Activity(
          id: 'letter_tracing_X',
          name: 'Trazado de la letra X',
          description: 'Aprende a trazar la letra X',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra X con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'Y',
      name: 'ye',
      phoneme: 'yeh',
      syllables: ['ya', 'ye', 'yi', 'yo', 'yu'],
      exampleWords: ['yo', 'yate', 'yema', 'yuca'],
      imagePath: 'assets/letters/y_house.png',
      audioPath: 'assets/audio/letters/y.mp3',
      primaryColor: Colors.orange,
      activities: [
        Activity(
          id: 'letter_tracing_Y',
          name: 'Trazado de la letra Y',
          description: 'Aprende a trazar la letra Y',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra Y con tu dedo siguiendo la guía',
        ),
      ],
    ),
    Letter(
      character: 'Z',
      name: 'zeta',
      phoneme: 'seth',
      syllables: ['za', 'ze', 'zi', 'zo', 'zu'],
      exampleWords: ['zapato', 'cebra', 'zorro', 'zona'],
      imagePath: 'assets/letters/z_house.png',
      audioPath: 'assets/audio/letters/z.mp3',
      primaryColor: Colors.pink,
      activities: [
        Activity(
          id: 'letter_tracing_Z',
          name: 'Trazado de la letra Z',
          description: 'Aprende a trazar la letra Z',
          type: ActivityType.pronunciation,
          difficulty: DifficultyLevel.beginner,
          instruction: 'Traza la letra Z con tu dedo siguiendo la guía',
        ),
      ],
    ),
  ];

  static List<Letter> get allLetters => List<Letter>.from(_letters);

  static Letter? getLetterByCharacter(String character) {
    try {
      return _letters.firstWhere(
        (letter) => letter.character.toLowerCase() == character.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<Letter> getUnlockedLetters() {
    return _letters.where((letter) => letter.isUnlocked).toList();
  }

  static List<Letter> getLettersWithStars(int minStars) {
    return _letters.where((letter) => letter.stars >= minStars).toList();
  }

  static int getTotalProgress() {
    int completedActivities = 0;
    int totalActivities = 0;
    
    for (final letter in _letters) {
      for (final activity in letter.activities) {
        totalActivities++;
        if (activity.isCompleted) {
          completedActivities++;
        }
      }
    }
    
    return totalActivities > 0 ? (completedActivities * 100 / totalActivities).round() : 0;
  }

  static List<String> get spanishAlphabet => _letters.map((l) => l.character).toList();
}