import 'package:flutter/material.dart';
import '../services/kids_ai_service.dart';
import '../services/audio_service.dart';
import '../services/speech_recognition_service.dart';

/// Widget de chat IA especializado para niños
/// Con interfaz simple y segura
class KidsAIChat extends StatefulWidget {
  final String currentLetter;
  final VoidCallback? onClose;

  const KidsAIChat({
    super.key,
    required this.currentLetter,
    this.onClose,
  });

  @override
  State<KidsAIChat> createState() => _KidsAIChatState();
}

class _KidsAIChatState extends State<KidsAIChat>
    with TickerProviderStateMixin {
  final KidsAIService _aiService = KidsAIService();
  final AudioService _audioService = AudioService();
  late SpeechRecognitionService _speechService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _isListening = false;
  bool _isProcessingVoice = false;
  String _recognizedText = '';
  List<String> _recognizedWords = [];
  
  late AnimationController _animationController;
  late AnimationController _micController;
  late Animation<double> _animation;
  late Animation<double> _micAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _micController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // IA COMPLETAMENTE DESHABILITADA - Solo mensaje simple
    _showSimpleMessage();
    return;

    // CÓDIGO DESHABILITADO - NO SE EJECUTA
    /*
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _micAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeInOut),
    );
    
    _speechService = SpeechRecognitionService();
    _setupSpeechCallbacks();
    _sendWelcomeMessage();
    */
  }

  @override
  void dispose() {
    _animationController.dispose();
    _micController.dispose();
    // _speechService.dispose(); // DESHABILITADO
    super.dispose();
  }

  void _setupSpeechCallbacks() {
    _speechService.onResult = (recognizedText) {
      setState(() {
        _recognizedText = recognizedText;
        _recognizedWords = _speechService.analyzeWordsForLetter(
          recognizedText, 
          widget.currentLetter
        );
      });
    };

    _speechService.onError = (error) {
      setState(() {
        _isListening = false;
        _isProcessingVoice = false;
      });
      _micController.stop();
      _addMessage(ChatMessage(
        text: 'No pude escucharte bien. ¿Podés intentar de nuevo?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    };

    _speechService.onListeningChanged = (listening) {
      setState(() {
        _isListening = listening;
      });
      
      if (listening) {
        _micController.repeat(reverse: true);
      } else {
        _micController.stop();
        if (_recognizedWords.isNotEmpty) {
          _processVoiceResponse();
        }
      }
    };
  }

  Future<void> _startVoiceInteraction() async {
    setState(() {
      _isProcessingVoice = true;
    });

    // Respuesta rápida y simple para niños
    final gameProposal = '¡Hola! Soy tu amigo virtual. La letra ${widget.currentLetter} es muy importante para aprender.';
    _addMessage(ChatMessage(
      text: gameProposal,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    await _audioService.speakText(gameProposal);
    
    // RECONOCIMIENTO DE VOZ DESHABILITADO
    setState(() {
      _isProcessingVoice = false;
    });
    _addMessage(ChatMessage(
      text: 'Reconocimiento de voz no disponible. ¡Pero podés seguir jugando con las letras!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _processVoiceResponse() async {
    // FUNCIONALIDAD DESHABILITADA - EVITA PENSAMIENTO INFINITO
    return;
    if (_isProcessingVoice) return;
    
    setState(() {
      _isProcessingVoice = true;
    });

    // Mostrar lo que el niño dijo
    if (_recognizedText.isNotEmpty) {
      _addMessage(ChatMessage(
        text: _recognizedText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    }

    // Respuesta rápida y simple sin llamar a IA externa
    String evaluation;
    if (_recognizedWords.isNotEmpty) {
      evaluation = '¡Muy bien! Dijiste "${_recognizedWords.join(', ')}" que empieza con ${widget.currentLetter}. ¡Sos genial!';
    } else {
      evaluation = '¡Intentá de nuevo! Decime una palabra que empiece con ${widget.currentLetter}.';
    }
    
    _addMessage(ChatMessage(
      text: evaluation,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    await _audioService.speakText(evaluation);

    // Preguntar si quiere continuar - respuesta simple
    await Future.delayed(const Duration(milliseconds: 500)); // Reducido de 2 segundos
    final continuePrompt = '¿Querés decir otra palabra con ${widget.currentLetter}?';
    _addMessage(ChatMessage(
      text: continuePrompt,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    await _audioService.speakText(continuePrompt);

    setState(() {
      _isProcessingVoice = false;
      _recognizedText = '';
      _recognizedWords.clear();
    });
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _showSimpleMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: 'La letra ${widget.currentLetter} es muy importante para aprender a leer y escribir. ¡Sigue practicando!',
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _audioService.speakText(
      'La letra ${widget.currentLetter} es muy importante para aprender a leer y escribir. ¡Sigue practicando!'
    );
  }

  void _sendWelcomeMessage() {
    // FUNCIONALIDAD DESHABILITADA
    return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: '¡Hola! Soy tu amigo virtual 🤖\n¡Aprendamos la letra ${widget.currentLetter}! Tocá HABLAR y decime palabras.',
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isFromAI: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    // Leer el mensaje del niño
    _audioService.speakText('Dijiste: $message');

    try {
      String response;
      
      // Determinar tipo de respuesta basado en el mensaje
      if (message.toLowerCase().contains('palabra')) {
        final words = await _aiService.getArgentineWords(widget.currentLetter);
        response = '¡Genial! Aquí tienes palabras con ${widget.currentLetter}:\n${words.take(4).join(', ')}';
      } else if (message.toLowerCase().contains('historia') || message.toLowerCase().contains('cuento')) {
        response = await _aiService.tellLetterStory(widget.currentLetter);
      } else {
        response = await _aiService.getLetterInfo(widget.currentLetter);
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isFromAI: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Leer la respuesta de la IA
      _audioService.speakText(response);

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '¡Ups! Algo salió mal. ¡Pero seguimos aprendiendo juntos! 😊',
          isFromAI: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isExpanded ? (isPhone ? 300 : 400) : 80,
        height: _isExpanded ? (isPhone ? 400 : 500) : 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedChat() : _buildCollapsedButton(),
      ),
    );
  }

  Widget _buildCollapsedButton() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Center(
          child: Text(
            '🤖',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedChat() {
    return Column(
      children: [
        _buildChatHeader(),
        Expanded(child: _buildMessagesList()),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Text(
            '🤖',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amigo Virtual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Letra ${widget.currentLetter}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleExpansion,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingMessage();
        }
        
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: message.isFromAI ? Colors.grey[100] : Colors.blue[500],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isFromAI ? Colors.black87 : Colors.white,
                fontSize: 14,
              ),
            ),
            if (message.isFromAI)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => _audioService.speakText(message.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Escuchar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Pensando...'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '¿Qué quieres saber?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              // Botón de hablar grande y prominente
              _buildVoiceActionButton(),
              const SizedBox(height: 16),
              // Botones más pequeños y simples
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickActionButton(
                    '📝 Palabras',
                    () => _sendMessage('Dame palabras con ${widget.currentLetter}'),
                  ),
                  _buildQuickActionButton(
                    '📚 Cuento',
                    () => _sendMessage('Cuéntame una historia con ${widget.currentLetter}'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceActionButton() {
    return AnimatedBuilder(
      animation: _micAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isListening || _isProcessingVoice ? null : _startVoiceInteraction,
          child: Transform.scale(
            scale: _isListening ? _micAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Más grande para niños
              decoration: BoxDecoration(
                color: _isListening 
                  ? Colors.red[100] 
                  : _isProcessingVoice 
                    ? Colors.orange[100]
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isListening 
                    ? Colors.red[400]! 
                    : _isProcessingVoice 
                      ? Colors.orange[400]!
                      : Colors.green[400]!,
                  width: 3, // Borde más grueso
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening 
                      ? Icons.mic 
                      : _isProcessingVoice 
                        ? Icons.psychology
                        : Icons.mic,
                    size: 32, // Icono más grande
                    color: _isListening 
                      ? Colors.red[700] 
                      : _isProcessingVoice 
                        ? Colors.orange[700]
                        : Colors.green[700],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isListening 
                      ? 'Te escucho' 
                      : _isProcessingVoice 
                        ? 'Pensando...'
                        : 'HABLAR',
                    style: TextStyle(
                      fontSize: 18, // Texto más grande
                      color: _isListening 
                        ? Colors.red[800] 
                        : _isProcessingVoice 
                          ? Colors.orange[800]
                          : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Modelo para mensajes del chat
class ChatMessage {
  final String text;
  final bool isFromAI;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    this.isFromAI = false,
    this.isUser = false,
    required this.timestamp,
  });
}