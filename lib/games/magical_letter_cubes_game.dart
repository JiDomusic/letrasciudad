import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter.dart';
import '../services/audio_service.dart';
import '../providers/letter_city_provider.dart';

class MagicalLetterCubesGame extends StatefulWidget {
  final Letter letter;
  final AudioService audioService;

  const MagicalLetterCubesGame({
    super.key,
    required this.letter,
    required this.audioService,
  });

  @override
  State<MagicalLetterCubesGame> createState() => _MagicalLetterCubesGameState();
}

class _MagicalLetterCubesGameState extends State<MagicalLetterCubesGame> {
  late List<Map<String, dynamic>> _letterCubes;
  
  @override
  void initState() {
    super.initState();
    _generateLetterCubes();
  }

  void _generateLetterCubes() {
    final target = widget.letter.character.toUpperCase();
    final distractors = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
        .where((letter) => letter != target)
        .take(11)
        .toList();

    _letterCubes = [
      // 3 letras correctas
      {'letter': target, 'isTarget': true, 'found': false},
      {'letter': target, 'isTarget': true, 'found': false},
      {'letter': target, 'isTarget': true, 'found': false},
      // 9 letras distractoras
      ...distractors.map((letter) => {'letter': letter, 'isTarget': false, 'found': false}),
    ];
    _letterCubes.shuffle();
  }

  void _handleCubeTap(Map<String, dynamic> cubeData) {
    if (cubeData['found'] == true) return;

    setState(() {
      cubeData['found'] = true;
    });

    if (cubeData['isTarget'] as bool) {
      widget.audioService.speakText('¡Correcto! Encontraste la ${widget.letter.character}');
      _showCelebrationStars();
      context.read<LetterCityProvider>().completeActivity('magical_cubes_${widget.letter.character}', 10);
    } else {
      widget.audioService.speakText('Esa no es la letra ${widget.letter.character}');
    }
  }

  void _showCelebrationStars() {
    // Implementar celebración con estrellas
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
            Colors.pink[50]!,
            Colors.orange[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Título mágico
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink[300]!,
                  Colors.orange[300]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ENCUENTRA TODOS LOS CUBOS MÁGICOS CON ${widget.letter.character.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Indicador de progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              int foundCount = _letterCubes.where((cube) => cube['isTarget'] == true && cube['found'] == true).length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < foundCount ? Colors.green : Colors.white,
                  border: Border.all(
                    color: Colors.orange[400]!,
                    width: 3,
                  ),
                ),
                child: index < foundCount 
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              );
            }),
          ),
          
          const SizedBox(height: 30),
          
          // Grid de cubos mágicos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _letterCubes.length,
              itemBuilder: (context, index) {
                final cubeData = _letterCubes[index];
                return _buildMagicalCube(cubeData);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicalCube(Map<String, dynamic> cubeData) {
    final letter = cubeData['letter'] as String;
    final isTarget = cubeData['isTarget'] as bool;
    final isFound = cubeData['found'] as bool;

    return GestureDetector(
      onTap: () => _handleCubeTap(cubeData),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFound 
                ? (isTarget ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isFound ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isFound 
                  ? (isTarget 
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4))
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isFound && isTarget
                  ? [Colors.green[200]!, Colors.green[400]!]
                  : isFound
                      ? [Colors.red[200]!, Colors.red[400]!]
                      : [
                          Colors.pink[200]!,
                          Colors.pink[400]!,
                          Colors.orange[400]!,
                          Colors.orange[600]!,
                        ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Sombra interior para efecto 3D
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 3,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Brillo superior para efecto 3D
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                height: 15,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Letra central
              Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      Shadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 2,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
              // Checkmark cuando se encuentra correctamente
              if (isFound && isTarget)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              // X cuando es incorrecto
              if (isFound && !isTarget)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}