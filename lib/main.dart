import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/letter_city_provider.dart';
import 'services/audio_service.dart';
import 'config/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración específica para web
  if (kIsWeb) {
    // Configurar orientación preferida para web
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    // Configuración para móvil
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
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
        
        // Sistema de routing optimizado para web
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        
        // Configurar builder para manejo de errores y responsive design
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
        
        theme: _buildResponsiveTheme(),
      ),
    );
  }

  ThemeData _buildResponsiveTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      
      // Fuentes optimizadas con fallbacks para web
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        // Títulos grandes para pantallas grandes
        displayLarge: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.bold,
          fontSize: 57,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.bold,
          fontSize: 45,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        
        // Títulos medianos
        headlineLarge: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        
        // Títulos pequeños
        titleLarge: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w500,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Roboto', 
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        
        // Texto del cuerpo - más grande para niños
        bodyLarge: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 20,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 18,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 16,
          height: 1.4,
        ),
        
        // Etiquetas
        labelLarge: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Roboto', 
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Botones optimizados para touch
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(120, 48), // Tamaño mínimo para touch
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
      
      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Botones con borde
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(width: 2),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Cards con sombras suaves
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // AppBar optimizada
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        toolbarHeight: 64, // Más alto para mejor touch
      ),
      
      // FAB optimizado
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        shape: CircleBorder(),
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Input Decorations
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
        ),
      ),
      
      // Divisores
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 16,
      ),
      
      // ListTiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        minVerticalPadding: 12,
      ),
      
      // Tooltips
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      
      // Configuración visual
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      
      // Configuración específica para plataforma
      platform: kIsWeb ? TargetPlatform.android : null, // Consistencia en web
    );
  }
}
