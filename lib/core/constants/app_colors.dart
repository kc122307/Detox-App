import 'package:flutter/material.dart';

class AppColors {
  // Deep dark backgrounds
  static const Color background = Color(0xFF0F1017);
  static const Color surface = Color(0xFF181A26);
  static const Color surfaceElevated = Color(0xFF222536);
  static const Color surfaceBorder = Color(0xFF2E334D);

  // Brand Accents
  static const Color primary = Color(0xFF8B5CF6); // Vibrant Violet
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  
  static const Color secondary = Color(0xFF38BDF8); // Electric Sky / Cyan
  static const Color secondaryLight = Color(0xFF7DD3FC);
  static const Color secondaryDark = Color(0xFF0284C7);

  static const Color accent = Color(0xFFEC4899); // Electric Pink / Magenta
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successBg = Color(0xFF064E3B);
  
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color warningBg = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444); // Bright Red
  static const Color errorBg = Color(0xFF7F1D1D);

  static const Color restricted = Color(0xFFDC2626);
  static const Color unlocked = Color(0xFF059669);

  // Difficulty Colors
  static const Color difficultyBeginner = Color(0xFF10B981); // Green
  static const Color difficultyEasy = Color(0xFF06B6D4);     // Cyan
  static const Color difficultyMedium = Color(0xFFF59E0B);   // Yellow/Orange
  static const Color difficultyHard = Color(0xFFF97316);     // Orange/Red
  static const Color difficultyExpert = Color(0xFFEF4444);   // Red
  static const Color difficultyMaster = Color(0xFFA855F7);   // Purple

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textCode = Color(0xFFE2E8F0);

  // Editor Colors
  static const Color editorBackground = Color(0xFF121420);
  static const Color editorGutter = Color(0xFF1A1C2C);
  static const Color editorLineNumber = Color(0xFF475569);
  static const Color editorCurrentLine = Color(0xFF1E2135);
  static const Color editorSelection = Color(0xFF334155);

  // Syntax Highlighting Tokens
  static const Color syntaxKeyword = Color(0xFFFF7B72); // Pink/Red
  static const Color syntaxFunction = Color(0xFFD2A8FF); // Light Purple
  static const Color syntaxString = Color(0xFFA5D6FF); // Soft Blue
  static const Color syntaxNumber = Color(0xFF79C0FF); // Light Cyan
  static const Color syntaxComment = Color(0xFF8B949E); // Dim Gray
  static const Color syntaxType = Color(0xFFFFA657); // Orange
  static const Color syntaxOperator = Color(0xFFFF7B72);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient unlockGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient restrictionGradient = LinearGradient(
    colors: [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x338B5CF6), Color(0x1138BDF8), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

