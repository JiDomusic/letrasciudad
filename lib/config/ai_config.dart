/// Configuración para Google AI/Gemini
/// 
/// INSTRUCCIONES PARA CONFIGURAR:
/// 1. Ve a https://aistudio.google.com/app/apikey
/// 2. Crea una cuenta de Google AI Studio (gratis)
/// 3. Genera una nueva API key
/// 4. Reemplaza 'YOUR_GOOGLE_AI_API_KEY' con tu clave real
/// 5. ¡Listo! La IA funcionará automáticamente
/// 
/// NOTA DE SEGURIDAD:
/// - Esta clave es solo para desarrollo/testing
/// - Para producción, usa variables de entorno
/// - Nunca compartas tu API key públicamente

class AIConfig {
  // 🔑 REEMPLAZA ESTA LÍNEA CON TU API KEY DE GOOGLE AI
  static const String googleAIApiKey = 'YOUR_GOOGLE_AI_API_KEY';
  
  // Configuración de seguridad para niños
  static const bool enableContentFiltering = true;
  static const int maxResponseLength = 300;
  static const double conservativeTemperature = 0.3;
  
  // Letras del alfabeto argentino (27 letras)
  static const List<String> argentineAlphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];
  
  // Verificar si la API está configurada - SIEMPRE FALSO
  static bool get isConfigured => false;
  
  // Modo de demostración completamente DESHABILITADO
  static const bool enableDemoMode = false;
  
  // IA completamente deshabilitada
  static const bool aiEnabled = false;
}