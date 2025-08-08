import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final AudioService _audioService = AudioService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasSpokenWelcome = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    
    _animationController.forward();
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_hasSpokenWelcome) {
      _hasSpokenWelcome = true;
      await _audioService.speakText('¡Hola! Soy Luna, tu guía mágica. Antes de comenzar esta increíble aventura, me encantaría conocer tu nombre. ¿Cómo te llamas?');
    }
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Guardar el nombre en el provider
      context.read<LetterCityProvider>().setPlayerName(name);
      
      // Mensaje personalizado de bienvenida
      _audioService.speakText('¡Hola $name! Qué nombre tan bonito. Ahora sí, ¡vamos a explorar el maravilloso mundo de las letras juntos!');
      
      // Ir a la pantalla principal después de un breve delay
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    } else {
      _audioService.speakText('Por favor, escribe tu nombre para que pueda conocerte mejor.');
    }
  }

  void _skipName() {
    // Usar nombre por defecto
    context.read<LetterCityProvider>().setPlayerName('Pequeño Explorador');
    _audioService.speakText('¡Está bien! Te llamaré Pequeño Explorador. ¡Vamos a divertirnos!');
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFF98FB98), // Pale green
              Color(0xFFFFE4B5), // Moccasin
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: EdgeInsets.all(isWeb ? 48 : 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 600 : double.infinity,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Luna la guía
                      Container(
                        width: isWeb ? 120 : 100,
                        height: isWeb ? 120 : 100,
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 3),
                        ),
                        child: Icon(
                          Icons.face,
                          size: isWeb ? 60 : 50,
                          color: Colors.orange[600],
                        ),
                      ),
                      SizedBox(height: isWeb ? 24 : 20),
                      
                      // Título
                      Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: isWeb ? 36 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: isWeb ? 16 : 12),
                      
                      // Mensaje
                      Text(
                        'Soy Luna, tu guía mágica.\n¿Cómo te llamas?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWeb ? 20 : 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isWeb ? 32 : 24),
                      
                      // Campo de texto para el nombre
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWeb ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu nombre aquí',
                          hintStyle: TextStyle(
                            fontSize: isWeb ? 20 : 16,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.blue[500]!, width: 3),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isWeb ? 24 : 20,
                            vertical: isWeb ? 20 : 16,
                          ),
                        ),
                        onSubmitted: (_) => _submitName(),
                      ),
                      SizedBox(height: isWeb ? 32 : 24),
                      
                      // Botones
                      Row(
                        children: [
                          // Botón saltar
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _skipName,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!, width: 2),
                                padding: EdgeInsets.symmetric(vertical: isWeb ? 16 : 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Saltar',
                                style: TextStyle(
                                  fontSize: isWeb ? 18 : 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isWeb ? 16 : 12),
                          
                          // Botón continuar
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _submitName,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[500],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: isWeb ? 16 : 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                '¡Comenzar!',
                                style: TextStyle(
                                  fontSize: isWeb ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isWeb ? 20 : 16),
                      
                      // Mensaje adicional
                      Text(
                        'Tu nombre me ayudará a crear una experiencia más personal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}