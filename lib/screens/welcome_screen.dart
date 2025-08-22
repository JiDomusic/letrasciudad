import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../config/app_routes.dart';
import '../config/responsive_config.dart';

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
      
      // Mensaje personalizado de bienvenida - evitar interpolación directa
      _audioService.speakText('¡Hola! Qué nombre tan bonito. Ahora sí, vamos a explorar el maravilloso mundo de las letras juntos.');
      
      // Ir a la pantalla principal después de un breve delay
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          AppRoutes.navigateToHome(context);
        }
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
      if (context.mounted) {
        AppRoutes.navigateToHome(context);
      }
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
    final responsivePadding = context.responsivePadding;
    
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.maxContentWidth,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: responsivePadding,
                    padding: EdgeInsets.all(context.responsiveSpacing(4)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Luna la guía
                      Container(
                        width: context.responsiveIconSize(100),
                        height: context.responsiveIconSize(100),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 3),
                        ),
                        child: Icon(
                          Icons.face,
                          size: context.responsiveIconSize(50),
                          color: Colors.orange[600],
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing(2.5)),
                      
                      // Título
                      Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(28),
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing(1.5)),
                      
                      // Mensaje
                      Text(
                        'Soy Luna, tu guía mágica.\n¿Cómo te llamas?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(16),
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing(3)),
                      
                      // Campo de texto para el nombre
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        maxLength: 15,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu nombre aquí',
                          hintStyle: TextStyle(
                            fontSize: context.responsiveFontSize(16),
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
                            horizontal: context.responsiveSpacing(2.5),
                            vertical: context.responsiveSpacing(2),
                          ),
                          counterText: '', // Ocultar contador en móvil
                        ),
                        onSubmitted: (_) => _submitName(),
                      ),
                      SizedBox(height: context.responsiveSpacing(3)),
                      
                      // Botones
                      Row(
                        children: [
                          // Botón saltar
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _skipName,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!, width: 2),
                                padding: EdgeInsets.symmetric(vertical: context.responsiveSpacing(1.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Saltar',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(16),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.responsiveSpacing(1.5)),
                          
                          // Botón continuar
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _submitName,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[500],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: context.responsiveSpacing(1.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                '¡Comenzar!',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: context.responsiveSpacing(2)),
                      
                      // Mensaje adicional
                      Text(
                        'Tu nombre me ayudará a crear una experiencia más personal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12),
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
      ),
    );
  }
}