import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import 'ar_city_screen.dart';
import 'letter_details_screen.dart';
import '../widgets/letter_house_widget.dart';
import '../widgets/progress_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late Animation<double> _gridAnimation;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _gridAnimationController.forward();
    _playWelcomeMessage();
  }

  void _playWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioService.speakText('¡Hola pequeño explorador! Soy Luna, tu guía en este parque mágico de letras. ¿Estás listo para descubrir todas las aventuras que tengo preparadas?');
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF7C3AED),
              Color(0xFFDB2777),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const ProgressHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                      _buildLetterGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.park,
                  size: 50,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                Text(
                  provider.playerName.isNotEmpty 
                    ? '¡Hola, ${provider.playerName}!' 
                    : '¡Bienvenido al Parque!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pasea por el parque y descubre las letras en cada rincón mágico',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${provider.totalStars} estrellas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.isCameraPermissionGranted
                    ? () => _navigateToARCity()
                    : () => _showCameraPermissionDialog(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Vista AR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSettingsDialog(),
                icon: const Icon(Icons.settings),
                label: const Text('Configurar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7280),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLetterGrid() {
    return Consumer<LetterCityProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _gridAnimation,
          builder: (context, child) {
            debugPrint('Grid: Mostrando ${provider.letters.length} letras');
            return GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.letters.length,
              itemBuilder: (context, index) {
                final letter = provider.letters[index];
                final delay = index * 0.1;
                
                return Transform.scale(
                  scale: _gridAnimation.value,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300 + (delay * 100).round()),
                    opacity: _gridAnimation.value,
                    child: LetterHouseWidget(
                      letter: letter,
                      onTap: () => _onLetterTap(letter.character),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onLetterTap(String character) async {
    final provider = context.read<LetterCityProvider>();
    final letter = provider.getLetterByCharacter(character);
    
    if (letter == null) return;
    
    await _audioService.playClickSound();
    
    if (!letter.isUnlocked) {
      await _audioService.speakText('Esta letra aún no está disponible');
      return;
    }
    
    provider.selectLetter(character);
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LetterDetailsScreen(letter: letter),
        ),
      );
    }
  }

  void _navigateToARCity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ARCityScreen(),
      ),
    );
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de Cámara'),
        content: const Text(
          'Para usar la realidad aumentada necesitamos acceso a tu cámara.',
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Cambiar nombre'),
              onTap: () => _showNameDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Configurar audio'),
              onTap: () => _showAudioSettings(),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reiniciar progreso'),
              onTap: () => _showResetDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Modo Demo Activo'),
              subtitle: const Text('Todas las letras están desbloqueadas'),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showNameDialog() {
    final controller = TextEditingController();
    final provider = context.read<LetterCityProvider>();
    controller.text = provider.playerName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cuál es tu nombre?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe tu nombre aquí',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setPlayerName(controller.text.trim());
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close settings dialog too
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAudioSettings() {
    Navigator.of(context).pop(); // Close settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Audio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Volumen: ${(_audioService.volume * 100).round()}%'),
            Slider(
              value: _audioService.volume,
              onChanged: (value) => _audioService.setVolume(value),
            ),
            Text('Velocidad: ${(_audioService.speechRate * 100).round()}%'),
            Slider(
              value: _audioService.speechRate,
              onChanged: (value) => _audioService.setSpeechRate(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Reiniciar Progreso?'),
        content: const Text(
          'Se perderá todo tu progreso actual. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LetterCityProvider>().resetProgress();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

}