import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_city_provider.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parque de Letras',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Progreso: ${(provider.overallProgress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.totalStars}',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.score,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.totalScore}',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: provider.overallProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(provider.overallProgress),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    context,
                    'Desbloqueadas',
                    '${provider.unlockedLetters.length}/${provider.letters.length}',
                    Icons.lock_open,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'En progreso',
                    '${provider.letters.where((l) => l.isUnlocked && l.stars < 3).length}',
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'Completadas',
                    '${provider.letters.where((l) => l.stars == 3).length}',
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red[400]!;
    if (progress < 0.6) return Colors.orange[400]!;
    if (progress < 0.9) return Colors.yellow[600]!;
    return Colors.green[400]!;
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}