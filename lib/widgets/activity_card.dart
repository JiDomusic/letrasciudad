import 'package:flutter/material.dart';
import '../models/letter.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getActivityColor(activity.type),
                      _getActivityColor(activity.type).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (activity.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(activity.difficulty)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getDifficultyColor(activity.difficulty)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _getDifficultyText(activity.difficulty),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getDifficultyColor(activity.difficulty),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (activity.isCompleted)
                          Text(
                            '${activity.score}/${activity.maxScore}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          )
                        else
                          Text(
                            'Sin completar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    if (activity.progressPercentage > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(
                          value: activity.progressPercentage,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getActivityColor(activity.type),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.pronunciation:
        return Icons.record_voice_over;
      case ActivityType.syllables:
        return Icons.text_fields;
      case ActivityType.wordFormation:
        return Icons.build;
      case ActivityType.wordReading:
        return Icons.menu_book;
      case ActivityType.dragDrop:
        return Icons.touch_app;
      case ActivityType.memory:
        return Icons.psychology;
      case ActivityType.writing:
        return Icons.edit;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.pronunciation:
        return Colors.blue;
      case ActivityType.syllables:
        return Colors.green;
      case ActivityType.wordFormation:
        return Colors.orange;
      case ActivityType.wordReading:
        return Colors.purple;
      case ActivityType.dragDrop:
        return Colors.red;
      case ActivityType.memory:
        return Colors.teal;
      case ActivityType.writing:
        return Colors.brown;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Principiante';
      case DifficultyLevel.intermediate:
        return 'Intermedio';
      case DifficultyLevel.advanced:
        return 'Avanzado';
    }
  }
}