import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../widgets/ar_overlay_widget.dart';
import '../widgets/letter_selector_widget.dart';

class ARCityScreen extends StatefulWidget {
  const ARCityScreen({super.key});

  @override
  State<ARCityScreen> createState() => _ARCityScreenState();
}

class _ARCityScreenState extends State<ARCityScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showInstructions = true;
  final AudioService _audioService = AudioService();
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _playWelcomeMessage();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraError('No hay cámaras disponibles');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showCameraError('Error al inicializar la cámara: $e');
    }
  }

  void _showCameraError(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de Cámara'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _audioService.speakText('¡Bienvenido a mi parque encantado! Soy Luna y he preparado kioscos especiales con cada letra. Mueve tu teléfono para pasear por todo el parque');
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(),
          if (_isCameraInitialized) _buildAROverlay(),
          _buildTopBar(),
          if (_showInstructions) _buildInstructionsOverlay(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando cámara...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildAROverlay() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return AROverlayWidget(
          letters: provider.unlockedLetters,
          onLetterTap: (letter) => _onLetterTap(letter.character),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Parque AR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => _showHelp(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Realidad Aumentada!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mueve tu dispositivo para explorar la ciudad de letras en 3D. Toca las casas para acceder a las actividades.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  child: const Text('¡Explorar!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Consumer<LetterCityProvider>(
            builder: (context, provider, child) {
              return LetterSelectorWidget(
                letters: provider.unlockedLetters,
                onLetterSelected: (letter) => _onLetterTap(letter.character),
                selectedLetter: provider.selectedLetter,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onLetterTap(String character) async {
    final provider = context.read<LetterCityProvider>();
    provider.selectLetter(character);
    
    final letter = provider.getLetterByCharacter(character);
    if (letter != null) {
      await _audioService.playLetterSound(character);
      await _audioService.speakText('¡Genial! Has visitado el kiosco de la letra ${letter.name}. ¿Qué quieres hacer aquí?');
      
      if (mounted) {
        _showLetterOptions(letter);
      }
    }
  }

  void _showLetterOptions(dynamic letter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Letra ${letter.character}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _audioService.playLetterSound(letter.character);
                      },
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Escuchar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        // Navegar a detalles de letra
                      },
                      icon: const Icon(Icons.school),
                      label: const Text('Actividades'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Parque AR'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏛️ Kioscos de Letras',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Cada kiosco del parque tiene una letra especial. Están dispuestos en círculos como una plaza.'),
              SizedBox(height: 12),
              Text(
                '🚶 Paseo Virtual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Mueve tu teléfono para caminar por todo el parque y descubrir cada rincón.'),
              SizedBox(height: 12),
              Text(
                '👆 Exploración',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Toca cualquier kiosco para visitar esa letra y jugar con Luna.'),
              SizedBox(height: 12),
              Text(
                '👧 Guía Luna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Luna te acompañará con su voz dulce y te enseñará cada letra de forma divertida.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}