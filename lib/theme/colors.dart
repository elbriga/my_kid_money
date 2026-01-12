import 'package:flutter/material.dart';

class AppColors {
  // Primary playful colors
  static const Color primary = Color(0xFF6C63FF); // Vibrant purple
  static const Color primaryLight = Color(0xFFA29BFF);
  static const Color primaryDark = Color(0xFF4A44B2);

  // Secondary colors
  static const Color secondary = Color(0xFF36D1DC); // Cyan
  static const Color secondaryLight = Color(0xFF5BDBE5);
  static const Color secondaryDark = Color(0xFF25939C);

  // Accent colors for different actions
  static const Color deposit = Color(0xFF4CAF50); // Green
  static const Color withdraw = Color(0xFFFF9800); // Orange
  static const Color history = Color(0xFFA1A6E3); // Blue
  static const Color settings = Color(0xFF9C27B0); // Purple

  // Background colors
  static const Color background = Color(0xFFF8F9FF); // Very light purple tint
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF2D2B55); // Dark blue/purple
  static const Color textSecondary = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const Color highDollar = Color(0xFF2C7F30);

  // Chart colors
  static const List<Color> chartGradient = [
    Color(0xFF6C63FF),
    Color(0xFF36D1DC),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
  ];

  // Confetti colors - expanded playful palette
  static const List<Color> confettiColors = [
    Color(0xFFFF6B6B), // Coral red
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFFD166), // Yellow
    Color(0xFF06D6A0), // Green
    Color(0xFF118AB2), // Blue
    Color(0xFFEF476F), // Pink
    Color(0xFF7209B7), // Purple
    Color(0xFFF15BB5), // Magenta
    Color(0xFFF72585), // Hot pink
    Color(0xFF3A86FF), // Bright blue
  ];

  // Gradient for buttons and cards
  static Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient backgroundGradient = LinearGradient(
    colors: [Colors.purple.shade100, background],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static Gradient secondaryGradient = LinearGradient(
    colors: [secondary, deposit],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient depositGradient = LinearGradient(
    colors: [deposit, Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient withdrawGradient = LinearGradient(
    colors: [withdraw, Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient historyGradient = LinearGradient(
    colors: [history, Color(0xFF03A9F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
