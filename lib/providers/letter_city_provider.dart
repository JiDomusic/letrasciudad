import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/letter.dart';
import '../data/letters_data.dart';

class LetterCityProvider extends ChangeNotifier {
  List<Letter> _letters = [];
  Letter? _selectedLetter;
  Activity? _currentActivity;
  bool _isARActive = false;
  bool _isCameraPermissionGranted = false;
  int _totalScore = 0;
  String _playerName = '';

  List<Letter> get letters => _letters;
  Letter? get selectedLetter => _selectedLetter;
  Activity? get currentActivity => _currentActivity;
  bool get isARActive => _isARActive;
  bool get isCameraPermissionGranted => _isCameraPermissionGranted;
  int get totalScore => _totalScore;
  String get playerName => _playerName;

  int get totalStars => _letters.fold(0, (sum, letter) => sum + letter.stars);
  
  double get overallProgress {
    if (_letters.isEmpty) return 0.0;
    
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
    
    return totalActivities > 0 ? completedActivities / totalActivities : 0.0;
  }

  List<Letter> get unlockedLetters => 
      _letters.where((letter) => letter.isUnlocked).toList();

  List<Letter> get lockedLetters => 
      _letters.where((letter) => !letter.isUnlocked).toList();

  LetterCityProvider() {
    _initializeLetters();
    _enableDemoMode();
  }

  void _initializeLetters() {
    _letters = LettersData.allLetters;
    notifyListeners();
  }

  void _enableDemoMode() {
    // Modo demo: desbloquear todas las letras automáticamente
    _letters = _letters.map((letter) => letter.copyWith(isUnlocked: true)).toList();
    _playerName = ''; // Start with empty name to trigger name input dialog
    debugPrint('Demo Mode: Cargadas ${_letters.length} letras');
    for (var letter in _letters) {
      debugPrint('Letra: ${letter.character} - Desbloqueada: ${letter.isUnlocked}');
    }
    notifyListeners();
  }

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }

  void setCameraPermission(bool granted) {
    _isCameraPermissionGranted = granted;
    notifyListeners();
  }

  void toggleAR() {
    _isARActive = !_isARActive;
    notifyListeners();
  }

  void selectLetter(String character) {
    final letter = _letters.firstWhere(
      (l) => l.character.toLowerCase() == character.toLowerCase(),
      orElse: () => _letters.first,
    );
    
    if (letter.isUnlocked) {
      _selectedLetter = letter;
      _currentActivity = null;
      notifyListeners();
      
      HapticFeedback.lightImpact();
    }
  }

  void selectLetterByIndex(int index) {
    if (index >= 0 && index < _letters.length) {
      final letter = _letters[index];
      if (letter.isUnlocked) {
        _selectedLetter = letter;
        _currentActivity = null;
        notifyListeners();
        
        HapticFeedback.lightImpact();
      }
    }
  }

  void startActivity(String activityId) {
    if (_selectedLetter == null) return;

    final activity = _selectedLetter!.activities.firstWhere(
      (a) => a.id == activityId,
      orElse: () => _selectedLetter!.activities.first,
    );

    _currentActivity = activity;
    notifyListeners();
  }

  void completeActivity(String activityId, int score) {
    if (_selectedLetter == null) return;

    final letterIndex = _letters.indexWhere(
      (l) => l.character == _selectedLetter!.character
    );
    
    if (letterIndex == -1) return;

    final activityIndex = _letters[letterIndex].activities.indexWhere(
      (a) => a.id == activityId
    );
    
    if (activityIndex == -1) return;

    final updatedActivities = List<Activity>.from(_letters[letterIndex].activities);
    updatedActivities[activityIndex] = updatedActivities[activityIndex].copyWith(
      isCompleted: true,
      score: score,
    );

    // For ALL letters: automatically complete all circle-related activities when any activity is completed
    final letterChar = _letters[letterIndex].character.toLowerCase();
    // Complete all search_game and coloring_game activities for all letters (not just B, V, K)
    for (int i = 0; i < updatedActivities.length; i++) {
      final activity = updatedActivities[i];
      if (activity.id.contains('search_game') || activity.id.contains('coloring_game')) {
        updatedActivities[i] = activity.copyWith(
          isCompleted: true,
          score: activity.score > 0 ? activity.score : 100, // Use existing score or set to 100
        );
      }
    }

    _letters[letterIndex] = _letters[letterIndex].copyWith(
      activities: updatedActivities,
    );

    _calculateLetterStars(letterIndex);
    _updateTotalScore();
    _checkUnlockNextLetter(letterIndex);

    notifyListeners();
    
    HapticFeedback.mediumImpact();
  }

  void _calculateLetterStars(int letterIndex) {
    final letter = _letters[letterIndex];
    final completedActivities = letter.activities.where((a) => a.isCompleted).length;
    final totalActivities = letter.activities.length;
    
    int stars = 0;
    if (completedActivities > 0) {
      final completionRate = completedActivities / totalActivities;
      if (completionRate >= 0.33) stars = 1;
      if (completionRate >= 0.66) stars = 2;
      if (completionRate == 1.0) stars = 3;
    }

    _letters[letterIndex] = letter.copyWith(stars: stars);
  }

  void _updateTotalScore() {
    _totalScore = 0;
    for (final letter in _letters) {
      for (final activity in letter.activities) {
        _totalScore += activity.score;
      }
    }
  }

  void _checkUnlockNextLetter(int currentLetterIndex) {
    final currentLetter = _letters[currentLetterIndex];
    
    if (currentLetter.stars >= 1 && currentLetterIndex + 1 < _letters.length) {
      final nextLetter = _letters[currentLetterIndex + 1];
      if (!nextLetter.isUnlocked) {
        _letters[currentLetterIndex + 1] = nextLetter.copyWith(isUnlocked: true);
      }
    }
  }

  void resetProgress() {
    _letters = _letters.map((letter) => letter.copyWith(
      isUnlocked: letter.character == 'A',
      stars: 0,
      activities: letter.activities.map((activity) => activity.copyWith(
        isCompleted: false,
        score: 0,
      )).toList(),
    )).toList();
    
    _selectedLetter = null;
    _currentActivity = null;
    _totalScore = 0;
    
    notifyListeners();
  }

  void unlockAllLetters() {
    _letters = _letters.map((letter) => letter.copyWith(isUnlocked: true)).toList();
    notifyListeners();
  }

  Letter? getLetterByCharacter(String character) {
    try {
      return _letters.firstWhere(
        (letter) => letter.character.toLowerCase() == character.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  void clearSelection() {
    _selectedLetter = null;
    _currentActivity = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'letters': _letters.map((l) => l.toJson()).toList(),
      'totalScore': _totalScore,
      'playerName': _playerName,
      'selectedLetter': _selectedLetter?.character,
      'currentActivity': _currentActivity?.id,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _letters = (json['letters'] as List)
        .map((l) => Letter.fromJson(l))
        .toList();
    _totalScore = json['totalScore'] ?? 0;
    _playerName = json['playerName'] ?? '';
    
    if (json['selectedLetter'] != null) {
      _selectedLetter = getLetterByCharacter(json['selectedLetter']);
    }
    
    if (json['currentActivity'] != null && _selectedLetter != null) {
      _currentActivity = _selectedLetter!.activities.firstWhere(
        (a) => a.id == json['currentActivity'],
        orElse: () => _selectedLetter!.activities.first,
      );
    }
    
    notifyListeners();
  }
}