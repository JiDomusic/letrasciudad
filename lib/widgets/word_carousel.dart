import 'package:flutter/material.dart';

class WordCarousel extends StatefulWidget {
  final List<String> words;
  final Function(String) onWordTap;

  const WordCarousel({
    super.key,
    required this.words,
    required this.onWordTap,
  });

  @override
  State<WordCarousel> createState() => _WordCarouselState();
}

class _WordCarouselState extends State<WordCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 24,
                  color: Color(0xFF10B981),
                ),
                SizedBox(width: 8),
                Text(
                  'Palabras de Ejemplo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.words.length,
                itemBuilder: (context, index) {
                  final word = widget.words[index];
                  final isActive = index == _currentPage;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: isActive ? 0 : 10,
                    ),
                    child: GestureDetector(
                      onTap: () => widget.onWordTap(word),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isActive
                                ? [
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
                                  ]
                                : [
                                    Colors.grey[300]!,
                                    Colors.grey[400]!,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isActive ? Colors.green : Colors.grey)
                                  .withOpacity(0.3),
                              blurRadius: isActive ? 12 : 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              word,
                              style: TextStyle(
                                fontSize: isActive ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Toca para escuchar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
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
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.words.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF10B981)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}