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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
        
        // Tamaños responsivos más precisos
        final containerHeight = isSmallScreen ? 65.0 : (isMediumScreen ? 75.0 : 85.0);
        final itemWidth = isSmallScreen ? 45.0 : (isMediumScreen ? 55.0 : 65.0);
        final itemHeight = isSmallScreen ? 45.0 : (isMediumScreen ? 55.0 : 65.0);
        final fontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
        final selectedFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
        final horizontalPadding = isSmallScreen ? 6.0 : 8.0;
        final itemSpacing = isSmallScreen ? 3.0 : 4.0;

        return Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: isSmallScreen ? 0.8 : 1,
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: letters.length,
            itemBuilder: (context, index) {
          try {
            final letter = letters[index];
            final isSelected = selectedLetter?.character == letter.character;
            
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: itemSpacing),
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
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: isSmallScreen ? 1.5 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: isSmallScreen ? 6 : 8,
                          offset: Offset(0, isSmallScreen ? 3 : 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
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
                          // Indicador de estrellas responsivo
                          if (letter.stars > 0)
                            Positioned(
                              top: isSmallScreen ? 1 : 2,
                              right: isSmallScreen ? 1 : 2,
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: isSmallScreen ? 10 : 14,
                                  maxWidth: isSmallScreen ? 12 : 16,
                                  minHeight: isSmallScreen ? 10 : 14,
                                  maxHeight: isSmallScreen ? 12 : 16,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${letter.stars}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 7 : 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          // Indicador de selección responsivo
                          if (isSelected)
                            Positioned(
                              bottom: isSmallScreen ? 1 : 2,
                              left: isSmallScreen ? 3 : 4,
                              right: isSmallScreen ? 3 : 4,
                              child: Container(
                                height: isSmallScreen ? 1.5 : 2,
                                constraints: BoxConstraints(
                                  minHeight: isSmallScreen ? 1.5 : 2,
                                  maxHeight: isSmallScreen ? 2 : 3,
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
              // Fallback responsivo en caso de error
              return Container(
                width: itemWidth,
                height: itemHeight,
                margin: EdgeInsets.symmetric(horizontal: itemSpacing),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                ),
                child: Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              );
          }
            },
          ),
        );
      },
    );
  }
}