import 'package:flutter/material.dart';
import '../models/letter.dart';

class LetterHouseWidget extends StatefulWidget {
  final Letter letter;
  final VoidCallback onTap;

  const LetterHouseWidget({
    super.key,
    required this.letter,
    required this.onTap,
  });

  @override
  State<LetterHouseWidget> createState() => _LetterHouseWidgetState();
}

class _LetterHouseWidgetState extends State<LetterHouseWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.letter.isUnlocked && widget.letter.stars < 3) {
      _shimmerController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _bounceController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _bounceController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _bounceController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.letter.isUnlocked
                              ? [
                                  widget.letter.primaryColor.withOpacity(0.8),
                                  widget.letter.primaryColor,
                                ]
                              : [
                                  Colors.grey[300]!,
                                  Colors.grey[400]!,
                                ],
                        ),
                      ),
                    ),
                    if (widget.letter.isUnlocked && widget.letter.stars < 3)
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: _shimmerAnimation.value * 100,
                            child: Container(
                              width: 50,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (!widget.letter.isUnlocked)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.letter.stars > 0)
                                Row(
                                  children: List.generate(
                                    3,
                                    (index) => Icon(
                                      index < widget.letter.stars
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber[300],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              if (widget.letter.isUnlocked && widget.letter.stars == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'NUEVO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            widget.letter.character,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: widget.letter.isUnlocked
                                  ? Colors.white
                                  : Colors.white70,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                widget.letter.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.letter.isUnlocked
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                height: 4,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: widget.letter.activities.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: widget.letter.activities
                                                  .where((a) => a.isCompleted)
                                                  .length /
                                              widget.letter.activities.length,
                                          backgroundColor: Colors.transparent,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
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