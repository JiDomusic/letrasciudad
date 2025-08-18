import 'package:flutter/material.dart';
import '../services/kids_ai_service.dart';
import '../services/audio_service.dart';

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
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _sendWelcomeMessage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _sendWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: '¡Hola! Soy tu amigo virtual 🤖\n¿Quieres aprender sobre la letra ${widget.currentLetter}?',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickActionButton(
                '📖 Info de la letra',
                () => _sendMessage('Cuéntame sobre la letra ${widget.currentLetter}'),
              ),
              _buildQuickActionButton(
                '📝 Palabras',
                () => _sendMessage('Dame palabras con ${widget.currentLetter}'),
              ),
              _buildQuickActionButton(
                '📚 Historia',
                () => _sendMessage('Cuéntame una historia con ${widget.currentLetter}'),
              ),
            ],
          ),
        ],
      ),
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
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromAI,
    required this.timestamp,
  });
}