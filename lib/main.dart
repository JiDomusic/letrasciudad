import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/letter_city_provider.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar manejo de errores global
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };
  
  // Inicializar AudioService con manejo de errores
  try {
    await AudioService().initialize();
    debugPrint('✅ AudioService inicializado correctamente');
  } catch (e) {
    debugPrint('⚠️ Advertencia: AudioService falló al inicializar: $e');
    debugPrint('📱 La aplicación continuará sin funcionalidad de audio');
    // La app continúa sin audio en lugar de crashear
  }
  
  runApp(const LetterCityApp());
}

class LetterCityApp extends StatelessWidget {
  const LetterCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        try {
          return LetterCityProvider();
        } catch (e) {
          debugPrint('❌ Error creando LetterCityProvider: $e');
          rethrow;
        }
      },
      child: MaterialApp(
        title: 'Parque de Letras AR',
        debugShowCheckedModeBanner: false,
        
        // Configurar builder para manejo de errores
        builder: (context, child) {
          // Configurar widget de error personalizado
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.red[50],
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Ups! Algo salió mal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Por favor reinicia la aplicación',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Error: ${errorDetails.exception}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          };
          return child!;
        },
        
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          
          // Fuentes más confiables con fallbacks
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 18), // Más grande para niños
            bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
            bodySmall: TextStyle(fontFamily: 'Roboto', fontSize: 14),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18, // Botones más grandes para niños
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // Tema específico para niños
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        home: const SplashScreen(),
      ),
    );
  }
}
