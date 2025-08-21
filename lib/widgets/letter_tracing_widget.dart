import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/audio_service.dart';

/// Widget de trazado interactivo para las 27 letras del alfabeto argentino
class LetterTracingWidget extends StatefulWidget {
  final String letter;
  final VoidCallback? onTracingComplete;
  final AudioService audioService;
  final String? playerName;
  final bool isSpecialLetter;

  const LetterTracingWidget({
    super.key,
    required this.letter,
    this.onTracingComplete,
    required this.audioService,
    this.playerName,
    this.isSpecialLetter = false,
  });

  @override
  State<LetterTracingWidget> createState() => _LetterTracingWidgetState();
}

class _LetterTracingWidgetState extends State<LetterTracingWidget>
    with TickerProviderStateMixin {
  final List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  bool _isCompleted = false;
  double _completionPercentage = 0.0;
  bool _hasGiven75Feedback = false;
  
  // Variables para feedback inmediato y continuo
  DateTime _lastFeedbackTime = DateTime.now();
  bool _wasTracingWell = true;
  int _consecutiveGoodPoints = 0;
  int _consecutiveBadPoints = 0;
  double _accuracyScore = 0.0;
  List<bool> _strokeAccuracy = [];
  
  // Variables para demostración "Ver cómo"
  bool _isShowingDemo = false;
  late AnimationController _demoController;
  late Animation<double> _demoAnimation;
  
  late AnimationController _celebrationController;
  late AnimationController _hintController;
  late AnimationController _progressController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _hintAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _hintController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _demoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _hintAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _demoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _demoController, curve: Curves.easeInOut),
    );
    
    // Reproducir instrucción al iniciar
    _playInstructions();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _hintController.dispose();
    _progressController.dispose();
    _demoController.dispose();
    super.dispose();
  }

  void _playInstructions() async {
    // Asegurar que AudioService esté inicializado
    await widget.audioService.initialize();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      print('🎤 Reproduciendo instrucciones para letra ${widget.letter}');
      final playerName = widget.playerName ?? '';
      final greeting = playerName.isNotEmpty ? '$playerName, ' : '';
      
      if (widget.isSpecialLetter) {
        widget.audioService.speakText(
          _getSpecialLetterInstruction(widget.letter, greeting)
        );
      } else {
        widget.audioService.speakText(
          '¡Hola $greeting vamos a trazar la letra ${widget.letter}! Usa tu dedo para seguir las líneas grises.'
        );
      }
    });
  }
  
  String _getSpecialLetterInstruction(String letter, String greeting) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return '¡Hola $greeting! Vamos a trazar la ñ, una letra muy especial del español. Primero la N y luego su sombrerito. ¡Tú puedes!';
      case 'V':
        return '¡Hola $greeting! Vamos a hacer una V de victoria. Traza las dos líneas que se juntan abajo. ¡Como un valle entre montañas!';
      case 'B':
        return '¡Hola $greeting! La B tiene una línea recta y dos pancitas redondas. ¡Vamos a hacerla bonita!';
      case 'W':
        return '¡Hola $greeting! La W es como dos V juntas. ¡Es una letra muy especial! Sigue las líneas con calma.';
      case 'X':
        return '¡Hola $greeting! La X son dos líneas que se cruzan, como un abrazo. ¡Vamos a hacerla juntos!';
      case 'Y':
        return '¡Hola $greeting! La Y es como un árbol con dos ramas que se unen. ¡Qué bonita va a quedar!';
      case 'K':
        return '¡Hola $greeting! La K tiene una línea recta y dos líneas que la tocan. Es especial, ¡pero tú eres muy inteligente!';
      default:
        return '¡Hola $greeting vamos a trazar la letra ${letter}! Esta es una letra especial. ¡Tú puedes hacerlo!';
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      _currentStroke.add(details.localPosition);
      _updateCompletionPercentage();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;
    
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _userStrokes.add([..._currentStroke]);
        _currentStroke.clear();
        
        // IMPORTANTE: Actualizar porcentajes ANTES de verificar completación
        _updateCompletionPercentage();
        
        // Verificar si el trazado está completo con estándares muy permisivos
        final requiredCompletion = _getRequiredCompletionForLetter(widget.letter);
        final requiredAccuracy = _getRequiredAccuracyForLetter(widget.letter);
        
        print('🎯 Verificando completación: ${_completionPercentage.toStringAsFixed(2)} >= ${requiredCompletion.toStringAsFixed(2)}, ${_accuracyScore.toStringAsFixed(2)} >= ${requiredAccuracy.toStringAsFixed(2)}');
        
        if (_completionPercentage >= requiredCompletion && _accuracyScore >= requiredAccuracy) {
          print('✅ ¡Completación exitosa! Llamando _completeTracing()');
          _completeTracing();
        }
      }
    });
  }

  void _updateCompletionPercentage() {
    // Sistema simplificado que reconoce mejor los trazos de niños
    if (_userStrokes.isEmpty && _currentStroke.isEmpty) {
      _completionPercentage = 0.0;
      _accuracyScore = 0.0;
      return;
    }
    
    // Calcular qué tanto del path correcto está cubierto (MUY tolerante)
    final pathCoverage = _calculateSimplePathCoverage();
    
    // Sistema generoso: si el niño está trazando, dar crédito inmediato
    _completionPercentage = math.min(1.0, pathCoverage);
    _accuracyScore = math.min(1.0, pathCoverage * 0.8); // Siempre dar buena puntuación si está cerca
    
    // Feedback inmediato y alentador
    if (_completionPercentage >= 0.5 && !_hasGiven75Feedback) {
      _hasGiven75Feedback = true;
      print('🎤 Feedback 50% para ${widget.letter} - Precisión: $_accuracyScore');
      final playerName = widget.playerName ?? '';
      final personalGreeting = playerName.isNotEmpty ? '$playerName, ' : '';
      
      if (widget.isSpecialLetter) {
        if (_accuracyScore > 0.3) {
          widget.audioService.speakText(_getSpecialLetterProgressFeedback(widget.letter, personalGreeting, true));
        } else {
          widget.audioService.speakText(_getSpecialLetterProgressFeedback(widget.letter, personalGreeting, false));
        }
      } else {
        final encouragingMessages = [
          '${personalGreeting}vas muy bien con la ${widget.letter}',
          '${personalGreeting}qué buen trazo llevas',
          '${personalGreeting}sigue así, lo estás haciendo genial',
          '${personalGreeting}perfecto, continúa así'
        ];
        final randomMessage = encouragingMessages[DateTime.now().millisecondsSinceEpoch % encouragingMessages.length];
        widget.audioService.speakText(randomMessage);
      }
    }
    
    // FEEDBACK CONTINUO mientras traza
    if (_currentStroke.isNotEmpty && _currentStroke.length % 15 == 0) {
      _provideContinuousFeedback();
    }
  }
  
  String _getSpecialLetterProgressFeedback(String letter, String greeting, bool isGood) {
    if (isGood) {
      switch (letter.toUpperCase()) {
        case 'Ñ':
          return '¡$greeting ya casi tienes tu ñ! Se ve preciosa con su sombrerito. ¡Sigue así!';
        case 'V':
          return '¡$greeting tu V de victoria está casi lista! ¡Qué bien la estás haciendo!';
        case 'B':
          return '¡$greeting tu B bella está casi perfecta! Las pancitas se ven geniales.';
        case 'W':
          return '¡$greeting qué bien vas con la W! Es difícil pero tú eres muy inteligente.';
        case 'X':
          return '¡$greeting tu X está casi lista! Como un abrazo gigante. ¡Sigue así!';
        case 'Y':
          return '¡$greeting tu Y parece un árbol hermoso! Ya casi terminas.';
        case 'K':
          return '¡$greeting qué inteligente eres! La K es difícil pero ya casi la tienes.';
        default:
          return '¡$greeting ya casi terminas tu ${letter} especial! ¡Sigue así!';
      }
    } else {
      switch (letter.toUpperCase()) {
        case 'Ñ':
          return '¡Bien $greeting! Sigue la forma de la ñ. Primero la N, luego su sombrerito.';
        case 'V':
          return '¡Bien $greeting! La V son dos líneas que se juntan. ¡Tú puedes!';
        case 'B':
          return '¡Bien $greeting! La B tiene una línea recta y dos pancitas. ¡Sigue intentando!';
        case 'W':
          return '¡Bien $greeting! La W es como dos V juntas. Despacio, tú puedes.';
        case 'X':
          return '¡Bien $greeting! La X son dos líneas que se cruzan. ¡Sigue intentando!';
        case 'Y':
          return '¡Bien $greeting! La Y es como un árbol. Dos ramas que se unen.';
        case 'K':
          return '¡Bien $greeting! La K es especial, pero tú eres muy inteligente. ¡Sigue!';
        default:
          return '¡Bien $greeting! Sigue la forma de la ${letter}. ¡Tú puedes!';
      }
    }
  }

  // NUEVO: Feedback continuo e inmediato durante el trazado
  void _provideContinuousFeedback() {
    final now = DateTime.now();
    final timeSinceLastFeedback = now.difference(_lastFeedbackTime).inMilliseconds;
    
    // Solo dar feedback cada 4 segundos para no saturar
    if (timeSinceLastFeedback < 4000) return;
    
    // Verificar si el último punto del trazo actual está cerca del path correcto
    if (_currentStroke.isNotEmpty) {
      final lastPoint = _currentStroke.last;
      final letterPath = _getLetterPath(widget.letter);
      final isPointCorrect = _isPointNearPath(lastPoint, letterPath);
      
      if (isPointCorrect) {
        _consecutiveGoodPoints++;
        _consecutiveBadPoints = 0;
        
        // Felicitar después de POCOS puntos buenos (más frecuente)
        if (_consecutiveGoodPoints >= 5 && !_wasTracingWell) {
          _wasTracingWell = true;
          _lastFeedbackTime = now;
          final playerName = widget.playerName ?? '';
          final personalGreeting = playerName.isNotEmpty ? '$playerName, ' : '';
          
          List<String> encouragements;
          if (widget.isSpecialLetter) {
            encouragements = _getSpecialLetterEncouragement(widget.letter, personalGreeting);
          } else {
            encouragements = [
              '¡Perfecto $personalGreeting! Ahora sí sigues bien la letra ${widget.letter}',
              '¡Excelente $personalGreeting! Así se traza la ${widget.letter}',
              '¡Muy bien $personalGreeting! Sigues la forma correcta de la ${widget.letter}',
              '¡Genial $personalGreeting! Tu ${widget.letter} se ve perfecta'
            ];
          }
          final message = encouragements[DateTime.now().millisecond % encouragements.length];
          widget.audioService.speakText(message);
          print('🎤 Feedback positivo inmediato: $message');
        }
      } else {
        _consecutiveBadPoints++;
        _consecutiveGoodPoints = 0;
        
        // Ayudar después de MUCHOS puntos malos (menos frecuente pero más tolerante)
        if (_consecutiveBadPoints >= 20 && _wasTracingWell) {
          _wasTracingWell = false;
          _lastFeedbackTime = now;
          final playerName = widget.playerName ?? '';
          final personalName = playerName.isNotEmpty ? '$playerName, ' : '';
          
          List<String> corrections;
          if (widget.isSpecialLetter) {
            corrections = _getSpecialLetterCorrection(widget.letter, personalName);
          } else {
            corrections = [
              '${personalName}sigue la línea gris para trazar bien la ${widget.letter}',
              '${personalName}vuelve a la forma de la letra ${widget.letter}, no hagas garabatos',
              '${personalName}mira las líneas grises y sigue la forma de la ${widget.letter}',
              '${personalName}despacio, sigue el camino de la letra ${widget.letter}'
            ];
          }
          final message = corrections[DateTime.now().millisecond % corrections.length];
          widget.audioService.speakText(message);
          print('🎤 Feedback correctivo inmediato: $message');
        }
      }
    }
  }
  
  List<String> _getSpecialLetterEncouragement(String letter, String greeting) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return [
          '¡Perfecto $greeting! Tu ñ se ve preciosa con su sombrerito',
          '¡Excelente $greeting! La ñ es muy especial y tú la haces perfecta',
          '¡Muy bien $greeting! Esa ñ parece de un libro de cuentos'
        ];
      case 'V':
        return [
          '¡Perfecto $greeting! Tu V de victoria está increíble',
          '¡Excelente $greeting! Esa V parece las alas de un pájaro',
          '¡Muy bien $greeting! Tu V es perfecta como un valle'
        ];
      case 'B':
        return [
          '¡Perfecto $greeting! Tu B tiene las pancitas perfectas',
          '¡Excelente $greeting! Esa B está bella y brillante',
          '¡Muy bien $greeting! Tu B parece de un cuento de hadas'
        ];
      case 'W':
        return [
          '¡Perfecto $greeting! Tu W doble se ve increíble',
          '¡Excelente $greeting! Esa W parece montañas y valles',
          '¡Muy bien $greeting! Tu W es como ondas del mar'
        ];
      case 'X':
        return [
          '¡Perfecto $greeting! Tu X es como un abrazo gigante',
          '¡Excelente $greeting! Esa X se ve como estrella',
          '¡Muy bien $greeting! Tu X cruza perfectamente'
        ];
      case 'Y':
        return [
          '¡Perfecto $greeting! Tu Y parece un árbol hermoso',
          '¡Excelente $greeting! Esa Y tiene brazos que se abrazan',
          '¡Muy bien $greeting! Tu Y es como un gran bostézo'
        ];
      case 'K':
        return [
          '¡Perfecto $greeting! Tu K es muy inteligente',
          '¡Excelente $greeting! Esa K se ve como un bailarín',
          '¡Muy bien $greeting! Tu K es única y especial'
        ];
      default:
        return [
          '¡Perfecto $greeting! Tu ${letter} especial se ve increíble',
          '¡Excelente $greeting! Esa ${letter} está perfecta',
          '¡Muy bien $greeting! Tu ${letter} es preciosa'
        ];
    }
  }
  
  List<String> _getSpecialLetterCorrection(String letter, String name) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return [
          '${name}recuerda, primero la N y luego su sombrerito arriba',
          '${name}la ñ es especial, sigue las líneas grises despacio',
          '${name}mira bien la forma de la ñ, tú puedes hacerla'
        ];
      case 'V':
        return [
          '${name}la V son dos líneas que se juntan abajo, como un valle',
          '${name}sigue las líneas grises para hacer tu V perfecta',
          '${name}despacio, la V es como las alas de un pájaro'
        ];
      case 'B':
        return [
          '${name}la B tiene una línea recta y dos pancitas redondas',
          '${name}sigue la forma de la B, primero la línea, luego las curvas',
          '${name}la B es bonita, sigue las líneas grises con calma'
        ];
      case 'W':
        return [
          '${name}la W es como dos V juntas, sigue el camino',
          '${name}despacio con la W, es especial pero tú puedes',
          '${name}la W tiene cuatro líneas, síguelas una por una'
        ];
      case 'X':
        return [
          '${name}la X son dos líneas que se cruzan, como un abrazo',
          '${name}sigue las líneas grises para hacer tu X perfecta',
          '${name}la X es especial, dos líneas que se encuentran'
        ];
      case 'Y':
        return [
          '${name}la Y es como un árbol, dos ramas que se unen',
          '${name}sigue la forma de la Y, como brazos que se abrazan',
          '${name}despacio con la Y, primero las ramas, luego el tronco'
        ];
      case 'K':
        return [
          '${name}la K es especial, una línea recta y dos que la tocan',
          '${name}sé que puedes con la K, eres muy inteligente',
          '${name}sigue las líneas grises, la K es única como tú'
        ];
      default:
        return [
          '${name}sigue las líneas grises para la ${letter}',
          '${name}despacio, la ${letter} es especial como tú',
          '${name}tú puedes con la ${letter}, eres increíble'
        ];
    }
  }

  int _getRequiredPointsForLetter(String letter) {
    // Puntos requeridos ajustados para mayor interacción y aprendizaje real
    const letterComplexity = {
      'A': 60, 'B': 85, 'C': 50, 'D': 65, 'E': 70, 'F': 65, 'G': 70,
      'H': 70, 'I': 35, 'J': 45, 'K': 80, 'L': 45, 'M': 95, 'N': 65,
      'Ñ': 75, 'O': 55, 'P': 65, 'Q': 70, 'R': 80, 'S': 65, 'T': 50,
      'U': 55, 'V': 65, 'W': 85, 'X': 65, 'Y': 70, 'Z': 65,
    };
    return letterComplexity[letter.toUpperCase()] ?? 40;
  }

  void _completeTracing() {
    // Usar la misma validación simple que para el progreso - coherente y funcional
    final finalAccuracy = _accuracyScore; // Ya calculado con sistema simple
    
    print('🎉 _completeTracing llamado: finalAccuracy = ${finalAccuracy.toStringAsFixed(3)}');
    
    if (finalAccuracy >= 0.15) { // Muy tolerante para evitar frustración
      print('🎊 ¡FELICITACIÓN ACTIVADA! Marcando como completado...');
      setState(() {
        _isCompleted = true;
      });
      
      _celebrationController.forward();
      _hintController.stop();
      
      final playerName = widget.playerName ?? '';
      final congratsName = playerName.isNotEmpty ? '$playerName, ' : '';
      
      if (widget.isSpecialLetter) {
        widget.audioService.speakText(_getSpecialLetterCompletionMessage(widget.letter, congratsName, finalAccuracy));
      } else {
        if (finalAccuracy >= 0.3) {
          widget.audioService.speakText('¡Perfecto $congratsName! Trazaste la letra ${widget.letter} de manera excelente. ¡Eres un experto!');
        } else {
          widget.audioService.speakText('¡Muy bien $congratsName! Trazaste la letra ${widget.letter} correctamente. ¡Buen trabajo!');
        }
      }
      
      widget.onTracingComplete?.call();
      
      // Celebración con confetti virtual
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.isSpecialLetter) {
          widget.audioService.speakText(_getSpecialLetterFinalEncouragement(widget.letter));
        } else {
          widget.audioService.speakText('¡Eres increíble! ¿Quieres intentar otra vez?');
        }
      });
    } else {
      // No completar si no cumple con los estándares
      final playerName = widget.playerName ?? '';
      final encouragementName = playerName.isNotEmpty ? '$playerName, ' : '';
      
      if (widget.isSpecialLetter) {
        widget.audioService.speakText(_getSpecialLetterRetryMessage(widget.letter, encouragementName));
      } else {
        widget.audioService.speakText('${encouragementName}casi lo tienes. Intenta seguir mejor la forma de la letra ${widget.letter}.');
      }
    }
  }

  // Validación final más completa
  double _performFinalValidation() {
    final pathCoverage = _calculatePathCoverage();
    final sequenceCorrectness = _validateTracingSequence();
    final shapeAccuracy = _validateOverallShape();
    final strokeQuality = _evaluateStrokeQuality();
    
    return math.max(0.5, (pathCoverage * 0.6) + (sequenceCorrectness * 0.15) + (shapeAccuracy * 0.15) + (strokeQuality * 0.1)); // Mínimo 50% siempre
  }

  // Calcular cobertura del path correcto
  double _calculatePathCoverage() {
    final letterPath = _getLetterPath(widget.letter);
    final pathMetric = letterPath.computeMetrics().first;
    final pathLength = pathMetric.length;
    
    int coveredSegments = 0;
    const segmentCount = 20; // Dividir el path en menos segmentos para ser más fácil
    
    for (int i = 0; i < segmentCount; i++) {
      final segmentPosition = (i / segmentCount) * pathLength;
      final tangent = pathMetric.getTangentForOffset(segmentPosition);
      
      if (tangent?.position != null) {
        bool segmentCovered = false;
        
        // Verificar si algún trazo del usuario pasa cerca de este segmento (MUY tolerante)
        for (final stroke in _userStrokes) {
          for (final point in stroke) {
            if ((point - tangent!.position).distance < 80.0) {
              segmentCovered = true;
              break;
            }
          }
          if (segmentCovered) break;
        }
        
        // También verificar trazo actual
        for (final point in _currentStroke) {
          if ((point - tangent!.position).distance < 80.0) {
            segmentCovered = true;
            break;
          }
        }
        
        if (segmentCovered) coveredSegments++;
      }
    }
    
    return coveredSegments / segmentCount;
  }

  // Nueva función simple y tolerante para calcular cobertura
  double _calculateSimplePathCoverage() {
    if (_userStrokes.isEmpty && _currentStroke.isEmpty) return 0.0;
    
    final letterPath = _getLetterPath(widget.letter);
    final pathMetric = letterPath.computeMetrics().first;
    final pathLength = pathMetric.length;
    
    // Dividir en solo 10 segmentos para ser muy generoso
    const segmentCount = 10;
    int coveredSegments = 0;
    
    // Tolerancia equilibrada - debe seguir la forma pero ser accesible para niños
    const tolerance = 80.0; // Tolerante pero educativo
    
    for (int i = 0; i < segmentCount; i++) {
      final segmentPosition = (i / segmentCount) * pathLength;
      final tangent = pathMetric.getTangentForOffset(segmentPosition);
      
      if (tangent?.position != null) {
        bool segmentCovered = false;
        
        // Verificar todos los trazos del usuario
        for (final stroke in _userStrokes) {
          for (final point in stroke) {
            if ((point - tangent!.position).distance < tolerance) {
              segmentCovered = true;
              break;
            }
          }
          if (segmentCovered) break;
        }
        
        // También verificar trazo actual
        if (!segmentCovered) {
          for (final point in _currentStroke) {
            if ((point - tangent!.position).distance < tolerance) {
              segmentCovered = true;
              break;
            }
          }
        }
        
        if (segmentCovered) coveredSegments++;
      }
    }
    
    // Dar crédito extra si el niño está activamente trazando
    double bonus = (_currentStroke.isNotEmpty) ? 0.15 : 0.0;
    
    // Bonificación por esfuerzo: si ha hecho varios trazos, dar crédito adicional
    double effortBonus = math.min(0.1, _userStrokes.length * 0.02);
    
    double finalCoverage = math.min(1.0, (coveredSegments / segmentCount) + bonus + effortBonus);
    
    print('📊 PathCoverage: ${coveredSegments}/${segmentCount} = ${(coveredSegments/segmentCount).toStringAsFixed(2)}, bonus: ${bonus.toStringAsFixed(2)}, effort: ${effortBonus.toStringAsFixed(2)}, final: ${finalCoverage.toStringAsFixed(2)}');
    
    return finalCoverage;
  }

  // Validar secuencia de trazado
  double _validateTracingSequence() {
    if (_userStrokes.isEmpty) return 0.0;
    
    final startPoints = _getStartPointsForLetter(widget.letter, Size(300, 300));
    double sequenceScore = 0.0;
    
    // Verificar si el primer trazo comienza cerca de un punto de inicio válido
    if (_userStrokes.isNotEmpty) {
      final firstStroke = _userStrokes.first;
      if (firstStroke.isNotEmpty) {
        final firstPoint = firstStroke.first;
        
        double minDistance = double.infinity;
        for (final startPoint in startPoints) {
          final distance = (firstPoint - startPoint).distance;
          if (distance < minDistance) minDistance = distance;
        }
        
        if (minDistance < 120.0) {
          sequenceScore += 0.7; // 70% de la puntuación por empezar cerca
        }
      }
    }
    
    // Verificar continuidad del trazado (que no haya saltos grandes)
    double continuityScore = 1.0;
    for (int i = 1; i < _userStrokes.length; i++) {
      if (_userStrokes[i-1].isNotEmpty && _userStrokes[i].isNotEmpty) {
        final lastPointPrevious = _userStrokes[i-1].last;
        final firstPointCurrent = _userStrokes[i].first;
        final gap = (firstPointCurrent - lastPointPrevious).distance;
        
        if (gap > 150.0) { // Penalizar solo saltos MUY grandes
          continuityScore -= 0.1;
        }
      }
    }
    
    sequenceScore += continuityScore * 0.5; // 50% por continuidad
    return math.max(0.0, math.min(1.0, sequenceScore));
  }

  // Validar forma general
  double _validateOverallShape() {
    if (_userStrokes.isEmpty) return 0.0;
    
    // Calcular bounding box del trazado del usuario
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    
    for (final stroke in _userStrokes) {
      for (final point in stroke) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }
    
    final userWidth = maxX - minX;
    final userHeight = maxY - minY;
    final userAspectRatio = userHeight > 0 ? userWidth / userHeight : 1.0;
    
    // Aspect ratio esperado para cada letra
    final expectedAspectRatio = _getExpectedAspectRatio(widget.letter);
    final aspectRatioScore = 1.0 - math.min(1.0, (userAspectRatio - expectedAspectRatio).abs() / expectedAspectRatio);
    
    return aspectRatioScore;
  }

  // Evaluar calidad de los trazos
  double _evaluateStrokeQuality() {
    if (_userStrokes.isEmpty) return 0.0;
    
    double totalQuality = 0.0;
    int strokeCount = 0;
    
    for (final stroke in _userStrokes) {
      if (stroke.length < 3) continue; // Ignorar trazos muy cortos
      
      // Evaluar suavidad del trazo
      double smoothness = 0.0;
      for (int i = 2; i < stroke.length; i++) {
        final p1 = stroke[i-2];
        final p2 = stroke[i-1];
        final p3 = stroke[i];
        
        // Calcular ángulo entre vectores consecutivos
        final v1 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
        final v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);
        
        final dot = v1.dx * v2.dx + v1.dy * v2.dy;
        final mag1 = math.sqrt(v1.dx * v1.dx + v1.dy * v1.dy);
        final mag2 = math.sqrt(v2.dx * v2.dx + v2.dy * v2.dy);
        
        if (mag1 > 0 && mag2 > 0) {
          final cosAngle = dot / (mag1 * mag2);
          smoothness += (cosAngle + 1) / 2; // Normalizar a 0-1
        }
      }
      
      if (stroke.length > 2) {
        smoothness /= (stroke.length - 2);
        totalQuality += smoothness;
        strokeCount++;
      }
    }
    
    return strokeCount > 0 ? totalQuality / strokeCount : 0.0;
  }

  // Obtener aspect ratio esperado para cada letra
  double _getExpectedAspectRatio(String letter) {
    const aspectRatios = {
      'A': 0.8, 'B': 0.6, 'C': 0.8, 'D': 0.6, 'E': 0.6, 'F': 0.6, 'G': 0.8,
      'H': 0.6, 'I': 0.3, 'J': 0.5, 'K': 0.7, 'L': 0.5, 'M': 0.9, 'N': 0.7,
      'Ñ': 0.7, 'O': 0.9, 'P': 0.6, 'Q': 0.9, 'R': 0.7, 'S': 0.7, 'T': 0.8,
      'U': 0.7, 'V': 0.8, 'W': 1.2, 'X': 0.8, 'Y': 0.8, 'Z': 0.8,
    };
    return aspectRatios[letter.toUpperCase()] ?? 0.8;
  }

  // Obtener requisitos de completación específicos por letra
  double _getRequiredCompletionForLetter(String letter) {
    // Requisitos más bajos temporalmente para resolver el problema de felicitación
    const complexLetters = {'K', 'Ñ', 'B', 'R', 'P', 'Q', 'A', 'M', 'W', 'X', 'Y'};
    const simpleLetters = {'I', 'L', 'T', 'C', 'O', 'U', 'V', 'Z'};
    
    if (complexLetters.contains(letter.toUpperCase())) {
      return 0.40; // 40% para letras complejas - más fácil para que funcione
    } else if (simpleLetters.contains(letter.toUpperCase())) {
      return 0.50; // 50% para letras simples
    } else {
      return 0.45; // 45% para letras intermedias
    }
  }

  // Obtener requisitos de precisión específicos por letra
  double _getRequiredAccuracyForLetter(String letter) {
    // Requisitos muy bajos temporalmente para resolver problema de felicitación
    const complexLetters = {'K', 'Ñ', 'B', 'R', 'P', 'Q', 'A', 'M', 'W', 'X', 'Y'};
    const simpleLetters = {'I', 'L', 'T', 'C', 'O', 'U', 'V', 'Z'};
    
    if (complexLetters.contains(letter.toUpperCase())) {
      return 0.10; // 10% precisión para letras complejas - muy fácil
    } else if (simpleLetters.contains(letter.toUpperCase())) {
      return 0.15; // 15% precisión para letras simples
    } else {
      return 0.12; // 12% precisión para letras intermedias
    }
  }

  // Helper method to get start points for validation
  List<Offset> _getStartPointsForLetter(String letter, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = math.min(size.width, size.height) / 300;
    
    switch (letter.toUpperCase()) {
      case 'A':
        return [
          Offset(centerX - 50 * scale, centerY + 75 * scale), // Línea izquierda
          Offset(centerX - 25 * scale, centerY), // Barra horizontal
        ];
      case 'B':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Curva superior
          Offset(centerX - 40 * scale, centerY), // Curva inferior
        ];
      case 'C':
        return [Offset(centerX + 50 * scale, centerY - 25 * scale)]; // Inicio del arco
      case 'D':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Curva
        ];
      case 'E':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX - 40 * scale, centerY), // Línea media
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea inferior
        ];
      case 'F':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX - 40 * scale, centerY), // Línea media
        ];
      case 'G':
        return [
          Offset(centerX + 50 * scale, centerY - 25 * scale), // Inicio del arco
          Offset(centerX + 50 * scale, centerY), // Línea horizontal
        ];
      case 'H':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea izquierda
          Offset(centerX + 40 * scale, centerY - 75 * scale), // Línea derecha
          Offset(centerX - 40 * scale, centerY), // Barra horizontal
        ];
      case 'I':
        return [
          Offset(centerX - 30 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 30 * scale, centerY + 75 * scale), // Línea inferior
        ];
      case 'J':
        return [
          Offset(centerX - 20 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX + 5 * scale, centerY - 75 * scale), // Línea vertical y curva
        ];
      case 'K':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY), // Diagonal superior
          Offset(centerX - 40 * scale, centerY), // Diagonal inferior
        ];
      case 'L':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea
      case 'M':
        return [Offset(centerX - 50 * scale, centerY + 75 * scale)]; // Una sola línea continua
      case 'N':
        return [Offset(centerX - 40 * scale, centerY + 75 * scale)]; // Una sola línea continua
      case 'Ñ':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // N
          Offset(centerX - 20 * scale, centerY - 95 * scale), // Tilde
        ];
      case 'O':
        return [Offset(centerX, centerY - 50 * scale)]; // Inicio del círculo
      case 'P':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Parte superior
        ];
      case 'Q':
        return [
          Offset(centerX, centerY - 50 * scale), // Círculo
          Offset(centerX + 25 * scale, centerY + 25 * scale), // Cola
        ];
      case 'R':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Parte superior
          Offset(centerX - 10 * scale, centerY), // Diagonal
        ];
      case 'S':
        return [Offset(centerX + 40 * scale, centerY - 50 * scale)]; // Inicio de la S
      case 'T':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea horizontal
          Offset(centerX, centerY - 75 * scale), // Línea vertical
        ];
      case 'U':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'V':
        return [Offset(centerX - 50 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'W':
        return [Offset(centerX - 60 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'X':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Primera diagonal
          Offset(centerX + 40 * scale, centerY - 75 * scale), // Segunda diagonal
        ];
      case 'Y':
        return [
          Offset(centerX - 50 * scale, centerY - 75 * scale), // Línea izquierda
          Offset(centerX + 50 * scale, centerY - 75 * scale), // Línea derecha
          Offset(centerX, centerY), // Línea vertical
        ];
      case 'Z':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea continua
      default:
        return [Offset(centerX, centerY - 50 * scale)];
    }
  }

  void _resetTracing() {
    setState(() {
      _userStrokes.clear();
      _currentStroke.clear();
      _isCompleted = false;
      _completionPercentage = 0.0;
      _hasGiven75Feedback = false;
      _accuracyScore = 0.0;
      _strokeAccuracy.clear();
      
      // Reset para feedback continuo
      _lastFeedbackTime = DateTime.now();
      _wasTracingWell = true;
      _consecutiveGoodPoints = 0;
      _consecutiveBadPoints = 0;
    });
    
    _celebrationController.reset();
    _progressController.reset();
    _hintController.repeat(reverse: true);
    
    widget.audioService.speakText('¡Perfecto! Vamos a intentar de nuevo.');
  }

  void _showDemo() {
    setState(() {
      _isShowingDemo = true;
    });
    
    _demoController.reset();
    _demoController.forward();
    
    final playerName = widget.playerName ?? '';
    final personalGreeting = playerName.isNotEmpty ? '$playerName, ' : '';
    widget.audioService.speakText('${personalGreeting}mira cómo se traza la letra ${widget.letter}. Observa bien el movimiento.');
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isShowingDemo = false;
        });
        if (widget.isSpecialLetter) {
        widget.audioService.speakText('Ahora inténtalo tú. ¡Las letras especiales son tu especialidad!');
      } else {
        widget.audioService.speakText('Ahora inténtalo tú. ¡Puedes hacerlo!');
      }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isPhone),
          Expanded(
            child: _buildTracingArea(isPhone),
          ),
          _buildControls(isPhone),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isPhone) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 16 : 20),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_celebrationAnimation.value * 0.3),
                    child: Container(
                      width: isPhone ? 60 : 80,
                      height: isPhone ? 60 : 80,
                      decoration: BoxDecoration(
                        color: _isCompleted ? Colors.green : Colors.blue[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isCompleted ? Colors.green : Colors.blue[600]!)
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.letter.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPhone ? 28 : 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? '¡COMPLETADO!' : 'Trazando letra ${widget.letter.toUpperCase()}',
                      style: TextStyle(
                        fontSize: isPhone ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: _isCompleted ? Colors.green : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _completionPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isCompleted ? Colors.green : Colors.blue[600]!,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_completionPercentage * 100).toInt()}% completado',
                      style: TextStyle(
                        fontSize: isPhone ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTracingArea(bool isPhone) {
    return Container(
      margin: EdgeInsets.all(isPhone ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _LetterTracingPainter(
              letter: widget.letter.toUpperCase(),
              userStrokes: _userStrokes,
              currentStroke: _currentStroke,
              isCompleted: _isCompleted,
              hintAnimation: _hintAnimation,
              isShowingDemo: _isShowingDemo,
              demoAnimation: _demoAnimation,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isPhone) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 16 : 20),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Ver cómo',
            color: Colors.blue,
            onPressed: _showDemo,
            isPhone: isPhone,
          ),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reintentar',
            color: Colors.orange,
            onPressed: _resetTracing,
            isPhone: isPhone,
          ),
          _buildControlButton(
            icon: Icons.volume_up,
            label: 'Escuchar',
            color: Colors.purple,
            onPressed: () => widget.audioService.speakText(
              'La letra ${widget.letter} se pronuncia ${_getLetterPronunciation(widget.letter)}'
            ),
            isPhone: isPhone,
          ),
          if (_isCompleted)
            _buildControlButton(
              icon: Icons.star,
              label: '¡Genial!',
              color: Colors.green,
              onPressed: () {},
              isPhone: isPhone,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isPhone,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isPhone ? 20 : 24),
      label: Text(
        label,
        style: TextStyle(fontSize: isPhone ? 14 : 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 16 : 20,
          vertical: isPhone ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  String _getLetterPronunciation(String letter) {
    const pronunciations = {
      'A': 'ah', 'B': 'beh', 'C': 'ce', 'D': 'de', 'E': 'eh', 'F': 'efe', 'G': 'ge',
      'H': 'ache', 'I': 'i', 'J': 'jota', 'K': 'ka', 'L': 'ele', 'M': 'eme', 'N': 'ene',
      'Ñ': 'eñe', 'O': 'o', 'P': 'pe', 'Q': 'cu', 'R': 'erre', 'S': 'ese', 'T': 'te',
      'U': 'u', 'V': 've corta', 'W': 'doble ve', 'X': 'equis', 'Y': 'ye', 'Z': 'zeta',
    };
    return pronunciations[letter.toUpperCase()] ?? letter.toLowerCase();
  }
  
  String _getSpecialLetterCompletionMessage(String letter, String name, double accuracy) {
    if (accuracy >= 0.15) {
      switch (letter.toUpperCase()) {
        case 'Ñ':
          return '¡Increíble $name! Tu ñ es perfecta con su sombrerito. ¡Dominas las letras especiales del español!';
        case 'V':
          return '¡Fantástico $name! Tu V de victoria es perfecta. ¡Eres un verdadero ganador!';
        case 'B':
          return '¡Bravo $name! Tu B bella quedó preciosa con sus pancitas perfectas. ¡Eres un artista!';
        case 'W':
          return '¡Wow $name! Dominaste la W, una de las letras más difíciles. ¡Eres súper inteligente!';
        case 'X':
          return '¡Excelente $name! Tu X es como un abrazo perfecto. ¡Qué bien cruzaste las líneas!';
        case 'Y':
          return '¡Sí $name! Tu Y parece un árbol hermoso con brazos abiertos. ¡Magnífico!';
        case 'K':
          return '¡Qué genial $name! La K es muy difícil pero tú la hiciste ver fácil. ¡Eres brilliantísimo!';
        default:
          return '¡Perfecto $name! Dominaste la letra ${letter}. ¡Eres increíble!';
      }
    } else {
      switch (letter.toUpperCase()) {
        case 'Ñ':
          return '¡Muy bien $name! Tu ñ se ve bonita. ¡Qué especial es esta letra!';
        case 'V':
          return '¡Genial $name! Tu V de victoria está muy bien. ¡Sigue practicando!';
        case 'B':
          return '¡Bien hecho $name! Tu B se ve linda. ¡Las pancitas están muy bien!';
        case 'W':
          return '¡Buen trabajo $name! La W es difícil pero tú lo lograste. ¡Eres valiente!';
        case 'X':
          return '¡Bien $name! Tu X se ve bonita. ¡Las líneas se cruzan muy bien!';
        case 'Y':
          return '¡Genial $name! Tu Y está muy bien. ¡Parece un árbol feliz!';
        case 'K':
          return '¡Bien hecho $name! La K es complicada pero tú la hiciste. ¡Eres muy inteligente!';
        default:
          return '¡Muy bien $name! Tu ${letter} está bonita. ¡Buen trabajo!';
      }
    }
  }
  
  String _getSpecialLetterFinalEncouragement(String letter) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return '¡Eres increíble! Dominas la ñ, la letra más especial del español. ¿Quieres intentar otra letra?';
      case 'V':
        return '¡Eres un campeón! Tu V de victoria te queda perfecta. ¿Vamos por otra aventura?';
      case 'B':
        return '¡Eres brilliantísimo! Tu B bella te salió preciosa. ¿Quieres seguir explorando?';
      case 'W':
        return '¡Eres extraordinario! La W es difícil pero tú la dominaste. ¿Listo para más diversión?';
      case 'X':
        return '¡Eres excelente! Tu X es como un abrazo perfecto. ¿Vamos a jugar más?';
      case 'Y':
        return '¡Eres genial! Tu Y parece un árbol de la felicidad. ¿Quieres otra aventura?';
      case 'K':
        return '¡Eres un genio! La K es muy especial y tú la haces ver fácil. ¿Vamos por otra?';
      default:
        return '¡Eres increíble! Dominaste la ${letter}. ¿Quieres intentar otra vez?';
    }
  }
  
  String _getSpecialLetterRetryMessage(String letter, String name) {
    switch (letter.toUpperCase()) {
      case 'Ñ':
        return '${name}casi tienes la ñ. Es especial como tú. ¡Vamos a intentarlo otra vez!';
      case 'V':
        return '${name}tu V de victoria está casi lista. ¡Tú puedes hacerlo perfecto!';
      case 'B':
        return '${name}tu B bella está muy cerca. ¡Sigue intentando, eres increíble!';
      case 'W':
        return '${name}la W es difícil pero tú eres muy inteligente. ¡Vamos otra vez!';
      case 'X':
        return '${name}tu X está casi perfecta. ¡Como un abrazo, intentemos otra vez!';
      case 'Y':
        return '${name}tu Y está muy bien. ¡Vamos a hacerla aún más hermosa!';
      case 'K':
        return '${name}la K es especial y tú eres súper inteligente. ¡Intentemos una vez más!';
      default:
        return '${name}casi tienes la ${letter}. ¡Eres increíble, vamos otra vez!';
    }
  }

  // Validar si el trazo sigue la forma correcta de la letra
  bool _validateStrokeAccuracy(List<Offset> stroke) {
    if (stroke.length < 2) return false;
    
    final letterPath = _getLetterPath(widget.letter);
    int validPoints = 0;
    
    for (final point in stroke) {
      if (_isPointNearPath(point, letterPath)) {
        validPoints++;
      }
    }
    
    final accuracy = validPoints / stroke.length;
    _strokeAccuracy.add(accuracy > 0.3); // 30% de precisión mínima - mucho más fácil
    return accuracy > 0.3;
  }

  // Calcular precisión general del trazado
  double _calculateOverallAccuracy() {
    if (_strokeAccuracy.isEmpty) return 0.0;
    
    final accurateStrokes = _strokeAccuracy.where((isAccurate) => isAccurate).length;
    return accurateStrokes / _strokeAccuracy.length;
  }

  // Obtener puntos válidos (cerca del trazo correcto)
  double _getValidTracingPoints() {
    double validPoints = 0;
    final letterPath = _getLetterPath(widget.letter);
    
    // Validar trazos completados
    for (final stroke in _userStrokes) {
      for (final point in stroke) {
        if (_isPointNearPath(point, letterPath)) {
          validPoints++;
        }
      }
    }
    
    // Validar trazo actual
    for (final point in _currentStroke) {
      if (_isPointNearPath(point, letterPath)) {
        validPoints++;
      }
    }
    
    return validPoints;
  }

  // Generar el path correcto para cada letra
  Path _getLetterPath(String letter) {
    // Esta función genera el trazo correcto para cada letra
    // En una implementación completa, esto tendría las coordenadas exactas
    final path = Path();
    
    switch (letter.toUpperCase()) {
      case 'A':
        // Trazo izquierdo diagonal, trazo derecho diagonal, barra horizontal
        path.moveTo(100, 200);
        path.lineTo(150, 50);
        path.lineTo(200, 200);
        path.moveTo(125, 125);
        path.lineTo(175, 125);
        break;
      case 'B':
        // Línea vertical, curva superior, curva inferior
        path.moveTo(100, 50);
        path.lineTo(100, 200);
        path.moveTo(100, 50);
        path.quadraticBezierTo(150, 50, 150, 100);
        path.quadraticBezierTo(150, 125, 100, 125);
        path.moveTo(100, 125);
        path.quadraticBezierTo(160, 125, 160, 175);
        path.quadraticBezierTo(160, 200, 100, 200);
        break;
      case 'V':
        // Línea diagonal izquierda y derecha
        path.moveTo(100, 50);
        path.lineTo(150, 200);
        path.lineTo(200, 50);
        break;
      case 'W':
        // Doble V
        path.moveTo(80, 50);
        path.lineTo(110, 200);
        path.lineTo(140, 100);
        path.lineTo(170, 200);
        path.lineTo(200, 50);
        break;
      case 'K':
        // Línea vertical, diagonal superior, diagonal inferior
        path.moveTo(100, 50);
        path.lineTo(100, 200);
        path.moveTo(100, 125);
        path.lineTo(180, 50);
        path.moveTo(100, 125);
        path.lineTo(180, 200);
        break;
      case 'Y':
        // Dos diagonales que se unen y una vertical
        path.moveTo(100, 50);
        path.lineTo(150, 125);
        path.moveTo(200, 50);
        path.lineTo(150, 125);
        path.lineTo(150, 200);
        break;
      case 'Ñ':
        // N con tilde
        path.moveTo(100, 200);
        path.lineTo(100, 50);
        path.lineTo(180, 200);
        path.lineTo(180, 50);
        // Tilde
        path.moveTo(120, 30);
        path.quadraticBezierTo(140, 20, 160, 30);
        break;
      default:
        // Path genérico circular para otras letras
        path.addOval(const Rect.fromLTWH(100, 100, 100, 100));
    }
    
    return path;
  }

  // Verificar si un punto está cerca del trazo correcto
  bool _isPointNearPath(Offset point, Path letterPath) {
    const tolerance = 60.0; // Tolerancia más amplia en píxeles para hacer más fácil
    
    // Usar PathMetric para calcular distancia al path
    final pathMetric = letterPath.computeMetrics().first;
    final pathLength = pathMetric.length;
    
    double minDistance = double.infinity;
    
    // Verificar distancia a múltiples puntos del path
    for (double i = 0; i < pathLength; i += 5) {
      final tangent = pathMetric.getTangentForOffset(i);
      if (tangent?.position != null) {
        final distance = (point - tangent!.position).distance;
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }
    
    return minDistance <= tolerance;
  }
}

/// Pintor personalizado para el trazado de letras
class _LetterTracingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> userStrokes;
  final List<Offset> currentStroke;
  final bool isCompleted;
  final Animation<double> hintAnimation;
  final bool isShowingDemo;
  final Animation<double> demoAnimation;

  _LetterTracingPainter({
    required this.letter,
    required this.userStrokes,
    required this.currentStroke,
    required this.isCompleted,
    required this.hintAnimation,
    required this.isShowingDemo,
    required this.demoAnimation,
  }) : super(repaint: Listenable.merge([hintAnimation, demoAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar guía de la letra (fondo)
    _drawLetterGuide(canvas, size);
    
    // Dibujar demostración si está activa
    if (isShowingDemo) {
      _drawDemoAnimation(canvas, size);
    } else {
      // Dibujar trazos del usuario solo si no está en modo demo
      _drawUserStrokes(canvas, size);
    }
    
    // Dibujar animación de pista si no está completado y no está en demo
    if (!isCompleted && !isShowingDemo) {
      _drawHintAnimation(canvas, size);
    }
    
    // Dibujar efectos de celebración si está completado
    if (isCompleted) {
      _drawCelebrationEffects(canvas, size);
    }
  }

  void _drawLetterGuide(Canvas canvas, Size size) {
    // Dibujar el path correcto de la letra como guía
    final letterPath = _getLetterPathForSize(size);
    
    // Dibujar la guía con líneas sólidas - cambiar color cuando está completado
    final guidePaint = Paint()
      ..color = isCompleted ? Colors.green[600]! : Colors.grey[400]!
      ..strokeWidth = isCompleted ? 4.0 : 3.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(letterPath, guidePaint);
    
    // Dibujar puntos de inicio como referencia
    final startPoints = _getLetterStartPoints(size);
    final startPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0;
    
    for (int i = 0; i < startPoints.length; i++) {
      canvas.drawCircle(startPoints[i], 8.0, startPaint);
      
      // Añadir número de orden
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        startPoints[i] - Offset(textPainter.width / 2, textPainter.height / 2)
      );
    }
  }

  // Obtener el path de la letra ajustado al tamaño del canvas
  Path _getLetterPathForSize(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = math.min(size.width, size.height) / 300; // Escalar apropiadamente
    
    switch (letter.toUpperCase()) {
      case 'A':
        path.moveTo(centerX - 50 * scale, centerY + 75 * scale);
        path.lineTo(centerX, centerY - 75 * scale);
        path.lineTo(centerX + 50 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 25 * scale, centerY);
        path.lineTo(centerX + 25 * scale, centerY);
        break;
      case 'B':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.quadraticBezierTo(centerX + 20 * scale, centerY - 75 * scale, 
                               centerX + 20 * scale, centerY - 25 * scale);
        path.quadraticBezierTo(centerX + 20 * scale, centerY, 
                               centerX - 40 * scale, centerY);
        path.moveTo(centerX - 40 * scale, centerY);
        path.quadraticBezierTo(centerX + 30 * scale, centerY, 
                               centerX + 30 * scale, centerY + 37 * scale);
        path.quadraticBezierTo(centerX + 30 * scale, centerY + 75 * scale, 
                               centerX - 40 * scale, centerY + 75 * scale);
        break;
      case 'C':
        path.addArc(
          Rect.fromCenter(center: Offset(centerX, centerY), width: 100 * scale, height: 100 * scale),
          math.pi * 0.2, math.pi * 1.6
        );
        break;
      case 'D':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY - 75 * scale, 
                               centerX + 40 * scale, centerY);
        path.quadraticBezierTo(centerX + 40 * scale, centerY + 75 * scale, 
                               centerX - 40 * scale, centerY + 75 * scale);
        break;
      case 'E':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY - 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY);
        path.lineTo(centerX + 20 * scale, centerY);
        path.moveTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY + 75 * scale);
        break;
      case 'F':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY - 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY);
        path.lineTo(centerX + 20 * scale, centerY);
        break;
      case 'G':
        path.addArc(
          Rect.fromCenter(center: Offset(centerX, centerY), width: 100 * scale, height: 100 * scale),
          math.pi * 0.2, math.pi * 1.6
        );
        path.moveTo(centerX + 50 * scale, centerY);
        path.lineTo(centerX + 20 * scale, centerY);
        path.lineTo(centerX + 20 * scale, centerY + 25 * scale);
        break;
      case 'H':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX + 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY);
        path.lineTo(centerX + 40 * scale, centerY);
        break;
      case 'I':
        path.moveTo(centerX - 30 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY - 75 * scale);
        path.moveTo(centerX, centerY - 75 * scale);
        path.lineTo(centerX, centerY + 75 * scale);
        path.moveTo(centerX - 30 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY + 75 * scale);
        break;
      case 'J':
        path.moveTo(centerX - 20 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY - 75 * scale);
        path.moveTo(centerX + 5 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 5 * scale, centerY + 50 * scale);
        path.quadraticBezierTo(centerX + 5 * scale, centerY + 75 * scale, 
                               centerX - 20 * scale, centerY + 75 * scale);
        path.quadraticBezierTo(centerX - 45 * scale, centerY + 75 * scale, 
                               centerX - 45 * scale, centerY + 50 * scale);
        break;
      case 'K':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        path.moveTo(centerX - 40 * scale, centerY);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        break;
      case 'L':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 30 * scale, centerY + 75 * scale);
        break;
      case 'M':
        path.moveTo(centerX - 50 * scale, centerY + 75 * scale);
        path.lineTo(centerX - 50 * scale, centerY - 75 * scale);
        path.lineTo(centerX, centerY);
        path.lineTo(centerX + 50 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 50 * scale, centerY + 75 * scale);
        break;
      case 'N':
        path.moveTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        break;
      case 'Ñ':
        path.moveTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        // Tilde
        path.moveTo(centerX - 20 * scale, centerY - 95 * scale);
        path.quadraticBezierTo(centerX, centerY - 105 * scale, 
                               centerX + 20 * scale, centerY - 95 * scale);
        break;
      case 'O':
        path.addOval(Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 100 * scale,
          height: 100 * scale,
        ));
        break;
      case 'P':
        path.moveTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 20 * scale, centerY - 75 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY - 75 * scale, 
                               centerX + 40 * scale, centerY - 25 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY, 
                               centerX - 40 * scale, centerY);
        break;
      case 'Q':
        path.addOval(Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 100 * scale,
          height: 100 * scale,
        ));
        path.moveTo(centerX + 25 * scale, centerY + 25 * scale);
        path.lineTo(centerX + 45 * scale, centerY + 75 * scale);
        break;
      case 'R':
        path.moveTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 20 * scale, centerY - 75 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY - 75 * scale, 
                               centerX + 40 * scale, centerY - 25 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY, 
                               centerX - 40 * scale, centerY);
        path.moveTo(centerX - 10 * scale, centerY);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        break;
      case 'S':
        path.moveTo(centerX + 40 * scale, centerY - 50 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY - 75 * scale, 
                               centerX, centerY - 75 * scale);
        path.quadraticBezierTo(centerX - 40 * scale, centerY - 75 * scale, 
                               centerX - 40 * scale, centerY - 25 * scale);
        path.quadraticBezierTo(centerX - 40 * scale, centerY, 
                               centerX, centerY);
        path.quadraticBezierTo(centerX + 40 * scale, centerY, 
                               centerX + 40 * scale, centerY + 25 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY + 75 * scale, 
                               centerX, centerY + 75 * scale);
        path.quadraticBezierTo(centerX - 40 * scale, centerY + 75 * scale, 
                               centerX - 40 * scale, centerY + 50 * scale);
        break;
      case 'T':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        path.moveTo(centerX, centerY - 75 * scale);
        path.lineTo(centerX, centerY + 75 * scale);
        break;
      case 'U':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 50 * scale);
        path.quadraticBezierTo(centerX - 40 * scale, centerY + 75 * scale, 
                               centerX, centerY + 75 * scale);
        path.quadraticBezierTo(centerX + 40 * scale, centerY + 75 * scale, 
                               centerX + 40 * scale, centerY + 50 * scale);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        break;
      case 'V':
        path.moveTo(centerX - 50 * scale, centerY - 75 * scale);
        path.lineTo(centerX, centerY + 75 * scale);
        path.lineTo(centerX + 50 * scale, centerY - 75 * scale);
        break;
      case 'W':
        path.moveTo(centerX - 60 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 30 * scale, centerY + 75 * scale);
        path.lineTo(centerX, centerY - 25 * scale);
        path.lineTo(centerX + 30 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 60 * scale, centerY - 75 * scale);
        break;
      case 'X':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        path.moveTo(centerX + 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        break;
      case 'Y':
        path.moveTo(centerX - 50 * scale, centerY - 75 * scale);
        path.lineTo(centerX, centerY);
        path.moveTo(centerX + 50 * scale, centerY - 75 * scale);
        path.lineTo(centerX, centerY);
        path.lineTo(centerX, centerY + 75 * scale);
        break;
      case 'Z':
        path.moveTo(centerX - 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY - 75 * scale);
        path.lineTo(centerX - 40 * scale, centerY + 75 * scale);
        path.lineTo(centerX + 40 * scale, centerY + 75 * scale);
        break;
      default:
        // Círculo genérico para letras no definidas
        path.addOval(Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 100 * scale,
          height: 100 * scale,
        ));
    }
    
    return path;
  }

  // Obtener puntos de inicio para cada letra
  List<Offset> _getLetterStartPoints(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = math.min(size.width, size.height) / 300;
    
    switch (letter.toUpperCase()) {
      case 'A':
        return [
          Offset(centerX - 50 * scale, centerY + 75 * scale), // Línea izquierda
          Offset(centerX - 25 * scale, centerY), // Barra horizontal
        ];
      case 'B':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Curva superior
          Offset(centerX - 40 * scale, centerY), // Curva inferior
        ];
      case 'C':
        return [Offset(centerX + 50 * scale, centerY - 25 * scale)]; // Inicio del arco
      case 'D':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Curva
        ];
      case 'E':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX - 40 * scale, centerY), // Línea media
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea inferior
        ];
      case 'F':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX - 40 * scale, centerY), // Línea media
        ];
      case 'G':
        return [
          Offset(centerX + 50 * scale, centerY - 25 * scale), // Inicio del arco
          Offset(centerX + 50 * scale, centerY), // Línea horizontal
        ];
      case 'H':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea izquierda
          Offset(centerX + 40 * scale, centerY - 75 * scale), // Línea derecha
          Offset(centerX - 40 * scale, centerY), // Barra horizontal
        ];
      case 'I':
        return [
          Offset(centerX - 30 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 30 * scale, centerY + 75 * scale), // Línea inferior
        ];
      case 'J':
        return [
          Offset(centerX - 20 * scale, centerY - 75 * scale), // Línea superior
          Offset(centerX + 5 * scale, centerY - 75 * scale), // Línea vertical y curva
        ];
      case 'K':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY), // Diagonal superior
          Offset(centerX - 40 * scale, centerY), // Diagonal inferior
        ];
      case 'L':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea
      case 'M':
        return [Offset(centerX - 50 * scale, centerY + 75 * scale)]; // Una sola línea continua
      case 'N':
        return [Offset(centerX - 40 * scale, centerY + 75 * scale)]; // Una sola línea continua
      case 'Ñ':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // N
          Offset(centerX - 20 * scale, centerY - 95 * scale), // Tilde
        ];
      case 'O':
        return [Offset(centerX, centerY - 50 * scale)]; // Inicio del círculo
      case 'P':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Parte superior
        ];
      case 'Q':
        return [
          Offset(centerX, centerY - 50 * scale), // Círculo
          Offset(centerX + 25 * scale, centerY + 25 * scale), // Cola
        ];
      case 'R':
        return [
          Offset(centerX - 40 * scale, centerY + 75 * scale), // Línea vertical
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Parte superior
          Offset(centerX - 10 * scale, centerY), // Diagonal
        ];
      case 'S':
        return [Offset(centerX + 40 * scale, centerY - 50 * scale)]; // Inicio de la S
      case 'T':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Línea horizontal
          Offset(centerX, centerY - 75 * scale), // Línea vertical
        ];
      case 'U':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'V':
        return [Offset(centerX - 50 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'W':
        return [Offset(centerX - 60 * scale, centerY - 75 * scale)]; // Una sola línea continua
      case 'X':
        return [
          Offset(centerX - 40 * scale, centerY - 75 * scale), // Primera diagonal
          Offset(centerX + 40 * scale, centerY - 75 * scale), // Segunda diagonal
        ];
      case 'Y':
        return [
          Offset(centerX - 50 * scale, centerY - 75 * scale), // Línea izquierda
          Offset(centerX + 50 * scale, centerY - 75 * scale), // Línea derecha
          Offset(centerX, centerY), // Línea vertical
        ];
      case 'Z':
        return [Offset(centerX - 40 * scale, centerY - 75 * scale)]; // Una sola línea continua
      default:
        return [Offset(centerX, centerY - 50 * scale)];
    }
  }

  void _drawUserStrokes(Canvas canvas, Size size) {
    final baseColor = isCompleted ? Colors.green[700]! : Colors.blue[700]!;
    
    // Dibujar trazos completados con efecto de lápiz
    for (final stroke in userStrokes) {
      if (stroke.length > 1) {
        _drawPencilStroke(canvas, stroke, baseColor, false);
      }
    }

    // Dibujar trazo actual con efecto de lápiz
    if (currentStroke.length > 1) {
      _drawPencilStroke(canvas, currentStroke, baseColor, true);
    }
  }

  void _drawPencilStroke(Canvas canvas, List<Offset> stroke, Color baseColor, bool isCurrent) {
    if (stroke.length < 2) return;

    // Crear múltiples capas para simular textura de lápiz
    for (int layer = 0; layer < 3; layer++) {
      final layerAlpha = layer == 0 ? 0.8 : (layer == 1 ? 0.4 : 0.2);
      final layerWidth = layer == 0 ? 6.0 : (layer == 1 ? 8.0 : 10.0);
      
      final strokePaint = Paint()
        ..color = baseColor.withValues(alpha: layerAlpha)
        ..strokeWidth = layerWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      // Crear path suavizado con interpolación
      final path = _createSmoothPath(stroke);
      canvas.drawPath(path, strokePaint);
      
      // Añadir puntos granulados para textura de lápiz
      if (layer == 0) {
        _addPencilTexture(canvas, stroke, baseColor);
      }
    }
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    
    path.moveTo(points.first.dx, points.first.dy);
    
    // Usar interpolación cuadrática para suavizar el trazo
    for (int i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, controlPoint.dx, controlPoint.dy);
    }
    
    if (points.length > 1) {
      path.lineTo(points.last.dx, points.last.dy);
    }
    
    return path;
  }

  void _addPencilTexture(Canvas canvas, List<Offset> stroke, Color baseColor) {
    final texturePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Añadir puntos aleatorios alrededor del trazo para simular textura de lápiz
    for (int i = 0; i < stroke.length; i += 2) {
      final point = stroke[i];
      
      // Crear pequeños puntos alrededor del trazo principal
      for (int j = 0; j < 3; j++) {
        final randomOffset = Offset(
          point.dx + (math.Random().nextDouble() - 0.5) * 4,
          point.dy + (math.Random().nextDouble() - 0.5) * 4,
        );
        canvas.drawCircle(randomOffset, 0.5, texturePaint);
      }
    }
  }

  void _drawDemoAnimation(Canvas canvas, Size size) {
    final letterPath = _getLetterPathForSize(size);
    final pathMetric = letterPath.computeMetrics().first;
    final pathLength = pathMetric.length;
    
    // Dibujar el path hasta el punto actual de la animación
    final currentLength = pathLength * demoAnimation.value;
    
    // Crear path parcial
    final partialPath = pathMetric.extractPath(0, currentLength);
    
    // Pintura para la demostración
    final demoPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(partialPath, demoPaint);
    
    // Dibujar punto animado al final del trazo
    if (currentLength > 0) {
      final tangent = pathMetric.getTangentForOffset(currentLength);
      if (tangent?.position != null) {
        final pointPaint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0;
        canvas.drawCircle(tangent!.position, 6, pointPaint);
      }
    }
  }

  void _drawHintAnimation(Canvas canvas, Size size) {
    final hintPaint = Paint()
      ..color = Colors.orange.withValues(alpha: hintAnimation.value)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Dibujar puntos parpadeantes como guía
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 4, hintPaint);
  }

  void _drawCelebrationEffects(Canvas canvas, Size size) {
    final celebrationPaint = Paint()
      ..color = Colors.yellow[600]!
      ..strokeWidth = 3.0;

    // Dibujar estrellas de celebración
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi) / 5;
      final x = size.width / 2 + math.cos(angle) * (size.width * 0.3);
      final y = size.height / 2 + math.sin(angle) * (size.height * 0.3);
      
      _drawStar(canvas, Offset(x, y), 10, celebrationPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi) / 5;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}