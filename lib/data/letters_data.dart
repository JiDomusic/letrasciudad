import 'package:flutter/material.dart';
import '../models/letter.dart';

class LettersData {
  static final List<Letter> _letters = [
    const Letter(
      character: 'A',
      name: 'a',
      phoneme: 'ah',
      syllables: ['a'],
      exampleWords: ['aguja', 'abuela', 'ancla', 'árbol', 'anillo', 'alfombra', 'almohada', 'avión'],
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
      exampleWords: ['banana', 'barco', 'bebe', 'bola'],
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
      exampleWords: ['casa', 'cereza', 'ciudad', 'corazón'],
      imagePath: 'assets/letters/c_house.png',
      audioPath: 'assets/audio/letters/c.mp3',
      primaryColor: Colors.orange,
    ),
    Letter(
      character: 'D',
      name: 'de',
      phoneme: 'deh',
      syllables: ['da', 'de', 'di', 'do', 'du'],
      exampleWords: ['dedo', 'dinosaurio', 'dulce', 'dado'],
      imagePath: 'assets/letters/d_house.png',
      audioPath: 'assets/audio/letters/d.mp3',
      primaryColor: Colors.green,
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
    ),
    Letter(
      character: 'H',
      name: 'hache',
      phoneme: 'silent',
      syllables: ['ha', 'he', 'hi', 'ho', 'hu'],
      exampleWords: ['helado', 'hospital', 'huevo', 'hermano'],
      imagePath: 'assets/letters/h_house.png',
      audioPath: 'assets/audio/letters/h.mp3',
      primaryColor: Colors.brown,
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
    ),
    Letter(
      character: 'M',
      name: 'eme',
      phoneme: 'meh',
      syllables: ['ma', 'me', 'mi', 'mo', 'mu'],
      exampleWords: ['mamá', 'mesa', 'miel', 'mono'],
      imagePath: 'assets/letters/m_house.png',
      audioPath: 'assets/audio/letters/m.mp3',
      primaryColor: Colors.deepOrange,
    ),
    Letter(
      character: 'N',
      name: 'ene',
      phoneme: 'neh',
      syllables: ['na', 'ne', 'ni', 'no', 'nu'],
      exampleWords: ['nube', 'niño', 'naranja', 'noche'],
      imagePath: 'assets/letters/n_house.png',
      audioPath: 'assets/audio/letters/n.mp3',
      primaryColor: Colors.amber,
    ),
    Letter(
      character: 'Ñ',
      name: 'eñe',
      phoneme: 'nyeh',
      syllables: ['ña', 'ñe', 'ñi', 'ño', 'ñu'],
      exampleWords: ['niña', 'ñandú', 'sueño', 'pequeño'],
      imagePath: 'assets/letters/nn_house.png',
      audioPath: 'assets/audio/letters/nn.mp3',
      primaryColor: Colors.deepPurple,
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
    ),
    Letter(
      character: 'P',
      name: 'pe',
      phoneme: 'peh',
      syllables: ['pa', 'pe', 'pi', 'po', 'pu'],
      exampleWords: ['papá', 'pelota', 'pino', 'pollo'],
      imagePath: 'assets/letters/p_house.png',
      audioPath: 'assets/audio/letters/p.mp3',
      primaryColor: Colors.lightGreen,
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
    ),
    Letter(
      character: 'S',
      name: 'ese',
      phoneme: 'seh',
      syllables: ['sa', 'se', 'si', 'so', 'su'],
      exampleWords: ['sol', 'serpiente', 'silla', 'suma'],
      imagePath: 'assets/letters/s_house.png',
      audioPath: 'assets/audio/letters/s.mp3',
      primaryColor: Colors.yellow,
    ),
    Letter(
      character: 'T',
      name: 'te',
      phoneme: 'teh',
      syllables: ['ta', 'te', 'ti', 'to', 'tu'],
      exampleWords: ['tigre', 'teléfono', 'tortuga', 'tren'],
      imagePath: 'assets/letters/t_house.png',
      audioPath: 'assets/audio/letters/t.mp3',
      primaryColor: Colors.green,
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
    ),
    Letter(
      character: 'Z',
      name: 'zeta',
      phoneme: 'seth',
      syllables: ['za', 'ze', 'zi', 'zo', 'zu'],
      exampleWords: ['zapato', 'zebra', 'zorro', 'zona'],
      imagePath: 'assets/letters/z_house.png',
      audioPath: 'assets/audio/letters/z.mp3',
      primaryColor: Colors.pink,
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