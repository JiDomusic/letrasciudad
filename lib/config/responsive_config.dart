import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  tv,
}

enum ScreenSize {
  extraSmall, // < 600px
  small,      // 600px - 840px 
  medium,     // 840px - 1200px
  large,      // 1200px - 1600px
  extraLarge, // > 1600px
}

class ResponsiveConfig {
  // Breakpoints optimizados para educación infantil
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 840;
  static const double desktopMaxWidth = 1200;
  static const double largeDesktopMaxWidth = 1600;

  // Obtener tipo de dispositivo
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileMaxWidth) return DeviceType.mobile;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    if (width > largeDesktopMaxWidth) return DeviceType.tv;
    return DeviceType.desktop;
  }

  // Obtener tamaño de pantalla
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileMaxWidth) return ScreenSize.extraSmall;
    if (width < tabletMaxWidth) return ScreenSize.small;
    if (width < desktopMaxWidth) return ScreenSize.medium;
    if (width < largeDesktopMaxWidth) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }

  // Verificar si es móvil
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  // Verificar si es tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  // Verificar si es desktop
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.tv;
  }

  // Verificar si es TV o pantalla muy grande
  static bool isTV(BuildContext context) {
    return getDeviceType(context) == DeviceType.tv;
  }

  // Obtener padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
      case DeviceType.tv:
        return const EdgeInsets.all(48);
    }
  }

  // Obtener espaciado responsivo
  static double getResponsiveSpacing(BuildContext context, {double factor = 1.0}) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 8.0 * factor;
      case DeviceType.tablet:
        return 12.0 * factor;
      case DeviceType.desktop:
        return 16.0 * factor;
      case DeviceType.tv:
        return 24.0 * factor;
    }
  }

  // Obtener tamaño de fuente responsivo
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.15;
      case DeviceType.desktop:
        return baseFontSize * 1.3;
      case DeviceType.tv:
        return baseFontSize * 1.6;
    }
  }

  // Obtener tamaño de icono responsivo
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return baseIconSize;
      case DeviceType.tablet:
        return baseIconSize * 1.2;
      case DeviceType.desktop:
        return baseIconSize * 1.4;
      case DeviceType.tv:
        return baseIconSize * 1.8;
    }
  }

  // Obtener número de columnas para grids
  static int getResponsiveColumns(BuildContext context, {int minColumns = 1, int maxColumns = 6}) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileMaxWidth) return minColumns;
    if (width < tabletMaxWidth) return (minColumns + 1).clamp(minColumns, maxColumns);
    if (width < desktopMaxWidth) return (minColumns + 2).clamp(minColumns, maxColumns);
    if (width < largeDesktopMaxWidth) return (minColumns + 3).clamp(minColumns, maxColumns);
    return maxColumns;
  }

  // Obtener máximo ancho para contenido centrado
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 1080;
      case DeviceType.tv:
        return 1440;
    }
  }

  // Obtener altura mínima para toques en móvil
  static double getMinTouchTarget(BuildContext context) {
    return isMobile(context) ? 48.0 : 40.0;
  }

  // Configuración de animaciones según el dispositivo
  static Duration getAnimationDuration(BuildContext context) {
    return isDesktop(context) 
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300);
  }

  // Widget responsivo genérico
  static Widget responsive(
    BuildContext context, {
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? tv,
    Widget? fallback,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? tv ?? fallback ?? const SizedBox.shrink();
      case DeviceType.tablet:
        return tablet ?? desktop ?? mobile ?? tv ?? fallback ?? const SizedBox.shrink();
      case DeviceType.desktop:
        return desktop ?? tablet ?? tv ?? mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceType.tv:
        return tv ?? desktop ?? tablet ?? mobile ?? fallback ?? const SizedBox.shrink();
    }
  }
}

// Extension para facilitar el uso
extension ResponsiveExtension on BuildContext {
  DeviceType get deviceType => ResponsiveConfig.getDeviceType(this);
  ScreenSize get screenSize => ResponsiveConfig.getScreenSize(this);
  bool get isMobile => ResponsiveConfig.isMobile(this);
  bool get isTablet => ResponsiveConfig.isTablet(this);
  bool get isDesktop => ResponsiveConfig.isDesktop(this);
  bool get isTV => ResponsiveConfig.isTV(this);
  
  EdgeInsets get responsivePadding => ResponsiveConfig.getResponsivePadding(this);
  double responsiveSpacing([double factor = 1.0]) => ResponsiveConfig.getResponsiveSpacing(this, factor: factor);
  double responsiveFontSize(double baseFontSize) => ResponsiveConfig.getResponsiveFontSize(this, baseFontSize);
  double responsiveIconSize(double baseIconSize) => ResponsiveConfig.getResponsiveIconSize(this, baseIconSize);
  int responsiveColumns({int minColumns = 1, int maxColumns = 6}) => ResponsiveConfig.getResponsiveColumns(this, minColumns: minColumns, maxColumns: maxColumns);
  double get maxContentWidth => ResponsiveConfig.getMaxContentWidth(this);
  double get minTouchTarget => ResponsiveConfig.getMinTouchTarget(this);
  Duration get animationDuration => ResponsiveConfig.getAnimationDuration(this);
}