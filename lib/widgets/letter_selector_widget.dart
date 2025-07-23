import 'package:flutter/material.dart';
import '../models/letter.dart';

class LetterSelectorWidget extends StatelessWidget {
  final List<Letter> letters;
  final Function(Letter) onLetterSelected;
  final Letter? selectedLetter;

  const LetterSelectorWidget({
    super.key,
    required this.letters,
    required this.onLetterSelected,
    this.selectedLetter,
  });

  @override
  Widget build(BuildContext context) {
    if (letters.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Tamaños responsivos para evitar overflow
    final containerHeight = isSmallScreen ? 70.0 : 80.0;
    final itemWidth = isSmallScreen ? 50.0 : 60.0;
    final itemHeight = isSmallScreen ? 50.0 : 60.0;
    final fontSize = isSmallScreen ? 18.0 : 24.0;
    final selectedFontSize = isSmallScreen ? 22.0 : 28.0;

    return Container(
      height: containerHeight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          try {
            final letter = letters[index];
            final isSelected = selectedLetter?.character == letter.character;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onLetterSelected(letter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemWidth,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? letter.primaryColor
                        : letter.primaryColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Letra principal - centrada y con tamaño fijo
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              letter.character,
                              style: TextStyle(
                                fontSize: isSelected ? selectedFontSize : fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Indicador de estrellas - solo si hay estrellas y hay espacio
                        if (letter.stars > 0 && !isSmallScreen)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                maxWidth: 16,
                                minHeight: 14,
                                maxHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${letter.stars}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        // Indicador de selección - solo si está seleccionado
                        if (isSelected)
                          Positioned(
                            bottom: 2,
                            left: 4,
                            right: 4,
                            child: Container(
                              height: 2,
                              constraints: const BoxConstraints(
                                minHeight: 2,
                                maxHeight: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            // Fallback en caso de error con una letra específica
            return Container(
              width: itemWidth,
              height: itemHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}