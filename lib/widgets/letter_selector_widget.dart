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

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final isSelected = selectedLetter?.character == letter.character;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onLetterSelected(letter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? letter.primaryColor
                      : letter.primaryColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        letter.character,
                        style: TextStyle(
                          fontSize: isSelected ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (letter.stars > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${letter.stars}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        bottom: 2,
                        left: 2,
                        right: 2,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}