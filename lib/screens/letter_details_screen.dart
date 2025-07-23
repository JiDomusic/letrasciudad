import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/letter.dart';
import '../providers/letter_city_provider.dart';
import '../services/audio_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/syllable_grid.dart';
import '../widgets/word_carousel.dart';

class LetterDetailsScreen extends StatefulWidget {
  final Letter letter;

  const LetterDetailsScreen({
    super.key,
    required this.letter,
  });

  @override
  State<LetterDetailsScreen> createState() => _LetterDetailsScreenState();
}

class _LetterDetailsScreenState extends State<LetterDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _playIntroduction();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _playIntroduction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioService.speakLetterIntroduction(
      widget.letter.character,
      widget.letter.phoneme,
      widget.letter.exampleWords,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.letter.primaryColor.withValues(alpha: 0.8),
              widget.letter.primaryColor,
              widget.letter.primaryColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildSyllablesTab(),
                    _buildActivitiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          widget.letter.character,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Letra ${widget.letter.name.toUpperCase()}',
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                              isRepeatingAnimation: false,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              3,
                              (index) => Icon(
                                index < widget.letter.stars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber[300],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => _audioService.playLetterSound(widget.letter.character),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Sílabas'),
          Tab(text: 'Actividades'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildPhonemeCard(),
          const SizedBox(height: 16),
          WordCarousel(
            words: widget.letter.exampleWords,
            onWordTap: (word) => _audioService.playWordSound(word),
          ),
          const SizedBox(height: 16),
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildSyllablesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SyllableGrid(
            syllables: widget.letter.syllables,
            onSyllableTap: (syllable) => _audioService.playSyllableSound(syllable),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _playAllSyllables(),
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('Escuchar todas las sílabas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: widget.letter.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (widget.letter.activities.isEmpty)
            _buildNoActivitiesCard()
          else
            ...widget.letter.activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(
                activity: activity,
                onTap: () => _startActivity(activity),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPhonemeCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.record_voice_over,
              size: 48,
              color: Color(0xFF4F46E5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pronunciación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La letra ${widget.letter.character} se pronuncia:',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.letter.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.letter.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '"${widget.letter.phoneme}"',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.letter.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final completedActivities = widget.letter.activities.where((a) => a.isCompleted).length;
    final totalActivities = widget.letter.activities.length;
    final progress = totalActivities > 0 ? completedActivities / totalActivities : 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.trending_up,
              size: 48,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu Progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(widget.letter.primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              '$completedActivities de $totalActivities actividades completadas',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            if (widget.letter.stars > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Estrellas ganadas: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    ...List.generate(
                      widget.letter.stars,
                      (index) => Icon(
                        Icons.star,
                        color: Colors.amber[600],
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActivitiesCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Color(0xFFF59E0B),
            ),
            SizedBox(height: 16),
            Text(
              'Actividades en Desarrollo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Las actividades para esta letra estarán disponibles pronto. ¡Sigue explorando otras letras!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _playAllSyllables() async {
    await _audioService.speakSyllableLesson(
      widget.letter.character,
      widget.letter.syllables,
    );
  }

  void _startActivity(Activity activity) {
    final provider = context.read<LetterCityProvider>();
    provider.startActivity(activity.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando: ${activity.name}'),
        backgroundColor: widget.letter.primaryColor,
        action: SnackBarAction(
          label: 'Completar',
          textColor: Colors.white,
          onPressed: () {
            provider.completeActivity(activity.id, 100);
            _audioService.playSuccessSound();
            _audioService.speakEncouragement();
          },
        ),
      ),
    );
  }
}