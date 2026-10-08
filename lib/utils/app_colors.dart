import 'package:flutter/material.dart';

/// Design tokens and branding colors for Smart BloodLink
class AppColors {
  AppColors._();

  // Primary Branding
  static const Color primary = Color(0xFFD32F2F); // Crimson Red
  static const Color bloodRed = primary;
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color primaryDark = Color(0xFF9A0007);

  // Secondary
  static const Color secondary = Color(0xFFE53935);
  static const Color secondaryLight = Color(0xFFFF6F60);
  static const Color secondaryDark = Color(0xFFAB000D);

  // Status & Feedback
  static const Color success = Color(0xFF2E7D32); // Emerald Green
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00); // Amber Orange
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBackground = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF242424);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2D3748);

  // Accent Colors for Dashboard Metrics
  static const Color accentCyan = Color(0xFF00ACC1);
  static const Color accentPurple = Color(0xFF7E57C2);
  static const Color accentGold = Color(0xFFFFB300);

  // Card Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> pulseShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
