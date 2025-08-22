import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/letter_park_3d_screen.dart';
import '../screens/alphabet_main_screen.dart';
import '../screens/house_preview_screen.dart';
import '../screens/interactive_letter_games_screen.dart';
import '../screens/letter_details_screen.dart';
import '../models/letter.dart';
import '../services/audio_service.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String letterPark3D = '/letter-park-3d';
  static const String alphabetMain = '/alphabet-main';
  static const String housePreview = '/house-preview';
  static const String letterGames = '/letter-games';
  static const String letterDetails = '/letter-details';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      home: (context) => const HomeScreen(),
      letterPark3D: (context) => const LetterPark3DScreen(),
      alphabetMain: (context) => AlphabetMainScreen(audioService: AudioService()),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case housePreview:
        if (args is Letter) {
          return _createRoute(
            HousePreviewScreen(letterData: args),
            settings,
          );
        }
        break;

      case letterGames:
        if (args is Letter) {
          return _createRoute(
            InteractiveLetterGamesScreen(letter: args),
            settings,
          );
        }
        break;

      case letterDetails:
        if (args is Letter) {
          return _createRoute(
            LetterDetailsScreen(letter: args),
            settings,
          );
        }
        break;
    }

    // Fallback para rutas no definidas
    return _createRoute(
      const Scaffold(
        body: Center(
          child: Text('Página no encontrada'),
        ),
      ),
      settings,
    );
  }

  static PageRoute _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Transición suave para web y móvil
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Métodos de navegación optimizados para web
  static Future<void> navigateToHome(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(home);
  }

  static Future<void> navigateToLetterPark3D(BuildContext context) {
    return Navigator.of(context).pushNamed(letterPark3D);
  }

  static Future<void> navigateToAlphabetMain(BuildContext context) {
    return Navigator.of(context).pushNamed(alphabetMain);
  }

  static Future<void> navigateToHousePreview(BuildContext context, Letter letter) {
    return Navigator.of(context).pushNamed(housePreview, arguments: letter);
  }

  static Future<void> navigateToLetterGames(BuildContext context, Letter letter) {
    return Navigator.of(context).pushNamed(letterGames, arguments: letter);
  }

  static Future<void> navigateToLetterDetails(BuildContext context, Letter letter) {
    return Navigator.of(context).pushNamed(letterDetails, arguments: letter);
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}