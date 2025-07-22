import 'package:flutter/material.dart';

class SyllableGrid extends StatefulWidget {
  final List<String> syllables;
  final Function(String) onSyllableTap;

  const SyllableGrid({
    super.key,
    required this.syllables,
    required this.onSyllableTap,
  });

  @override
  State<SyllableGrid> createState() => _SyllableGridState();
}

class _SyllableGridState extends State<SyllableGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  String? _selectedSyllable;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.syllables.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _scaleAnimations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 0.95)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.text_fields,
                  size: 24,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 8),
                Text(
                  'Sílabas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.syllables.length > 4 ? 3 : 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.syllables.length,
              itemBuilder: (context, index) {
                final syllable = widget.syllables[index];
                final isSelected = _selectedSyllable == syllable;
                
                return AnimatedBuilder(
                  animation: _scaleAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimations[index].value,
                      child: GestureDetector(
                        onTapDown: (_) {
                          _controllers[index].forward();
                          setState(() {
                            _selectedSyllable = syllable;
                          });
                        },
                        onTapUp: (_) {
                          _controllers[index].reverse();
                          widget.onSyllableTap(syllable);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _selectedSyllable = null;
                              });
                            }
                          });
                        },
                        onTapCancel: () {
                          _controllers[index].reverse();
                          setState(() {
                            _selectedSyllable = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                  ? [
                                      const Color(0xFF6366F1),
                                      const Color(0xFF8B5CF6),
                                    ]
                                  : [
                                      Colors.blue[400]!,
                                      Colors.blue[600]!,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? Colors.purple : Colors.blue)
                                    .withOpacity(0.3),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                syllable.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    width: 30,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}