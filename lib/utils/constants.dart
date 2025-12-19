import 'package:flutter/material.dart';

// Renk Paleti
class AppColors {
  // Ana Renkler
  static const Color primary = Color(0xFF6C63FF); // Mor/Mavi
  static const Color secondary = Color(0xFFFF6584); // Pembe
  static const Color accent = Color(0xFF4CAF50); // Yeşil
  
  // Arka Plan Renkleri
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF1A1A2E);
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  
  // Durum Renkleri
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF74B9FF);
  
  // Gradient Renkleri
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF4757)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF00A383)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Text Stilleri
class AppTextStyles {
  // Başlıklar
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Gövde Metinleri
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Buton Metinleri
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
}

// Boyutlar ve Padding
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}

// Sabit Değerler
class AppConstants {
  // Firestore Collection İsimleri
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String goalsCollection = 'goals';
  static const String progressCollection = 'progress';
  static const String achievementsCollection = 'achievements';
  
  // Shared Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Puan Değerleri
  static const int pointsPerHabit = 10;
  static const int pointsPerStudySession = 5; // Her 30 dakika için
  static const int pointsPerLevel = 100;
  
  // Streak Bonusları
  static const int streak7DaysBonus = 50;
  static const int streak30DaysBonus = 200;
  static const int streak100DaysBonus = 500;
  
  // Varsayılan Değerler
  static const int defaultHabitTargetDays = 30;
  static const int defaultProgressDays = 30; // Gösterilecek ilerleme gün sayısı
}

// Animasyon Süreleri
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
