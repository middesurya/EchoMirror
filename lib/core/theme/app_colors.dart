import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Violet
  static const Color tertiary = Color(0xFFEC4899); // Pink

  // Emotion colors
  static const Color happy = Color(0xFFFBBF24); // Amber
  static const Color sad = Color(0xFF3B82F6); // Blue
  static const Color angry = Color(0xFFEF4444); // Red
  static const Color anxious = Color(0xFFA855F7); // Purple
  static const Color calm = Color(0xFF10B981); // Emerald
  static const Color neutral = Color(0xFF6B7280); // Gray

  // Genre colors
  static const Color cyberpunk = Color(0xFF00FFFF); // Cyan
  static const Color fantasy = Color(0xFFD4AF37); // Gold
  static const Color horror = Color(0xFF8B0000); // Dark red
  static const Color solarpunk = Color(0xFF7CB342); // Light green

  // UI colors
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emotionGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getGenreGradient(String genre) {
    switch (genre.toLowerCase()) {
      case 'cyberpunk':
        return const LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'fantasy':
        return const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'horror':
        return const LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF1A0000), Color(0xFF330000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'solarpunk':
        return const LinearGradient(
          colors: [Color(0xFF134E5E), Color(0xFF71B280)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return primaryGradient;
    }
  }
}
