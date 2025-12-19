import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';
import 'firestore_service.dart';

class GamificationService {
  final FirestoreService _firestoreService = FirestoreService();

  // Puan hesapla ve kullanıcıya ekle
  Future<void> awardPoints(String userId, int points) async {
    try {
      await _firestoreService.updateUserPoints(userId, points);
      
      // Puan kazandıktan sonra başarıları kontrol et
      await _checkAndUnlockAchievements(userId);
    } catch (e) {
      throw 'Puan eklenemedi: $e';
    }
  }

  // Alışkanlık tamamlama puanı
  Future<void> awardHabitCompletionPoints(String userId) async {
    const int habitPoints = 10;
    await awardPoints(userId, habitPoints);
  }

  // Çalışma puanı (her 30 dakika için 5 puan)
  Future<void> awardStudyPoints(String userId, int studyMinutes) async {
    int points = (studyMinutes ~/ 30) * 5;
    await awardPoints(userId, points);
  }

  // Streak puanı (ardışık günler için bonus)
  Future<void> awardStreakBonus(String userId, int streakDays) async {
    int bonus = 0;
    
    if (streakDays == 7) {
      bonus = 50; // 7 gün streak bonusu
    } else if (streakDays == 30) {
      bonus = 200; // 30 gün streak bonusu
    } else if (streakDays == 100) {
      bonus = 500; // 100 gün streak bonusu
    } else if (streakDays % 10 == 0 && streakDays > 0) {
      bonus = 20; // Her 10 günde bir küçük bonus
    }

    if (bonus > 0) {
      await awardPoints(userId, bonus);
    }
  }

  // Kullanıcı seviyesini hesapla
  int calculateLevel(int totalPoints) {
    // Her 100 puan = 1 seviye
    return (totalPoints ~/ 100) + 1;
  }

  // Sonraki seviye için gereken puan
  int pointsForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  // Mevcut seviyedeki ilerleme yüzdesi
  double levelProgress(int totalPoints) {
    int currentLevel = calculateLevel(totalPoints);
    int pointsInCurrentLevel = totalPoints % 100;
    return (pointsInCurrentLevel / 100) * 100;
  }

  // Başarıları kontrol et ve kilidi aç
  Future<void> _checkAndUnlockAchievements(String userId) async {
    try {
      // Kullanıcı bilgilerini al
      UserModel? user = await _firestoreService.getUser(userId);
      if (user == null) return;

      // Puan bazlı başarılar
      if (user.totalPoints >= 100) {
        await _firestoreService.unlockAchievement(userId, 'points_100');
      }
      if (user.totalPoints >= 500) {
        await _firestoreService.unlockAchievement(userId, 'points_500');
      }
    } catch (e) {
      // Hata olsa bile devam et
      print('Başarı kontrolü hatası: $e');
    }
  }

  // Streak bazlı başarıları kontrol et
  Future<void> checkStreakAchievements(String userId, int streakDays) async {
    try {
      if (streakDays >= 7) {
        await _firestoreService.unlockAchievement(userId, 'streak_7');
      }
      if (streakDays >= 30) {
        await _firestoreService.unlockAchievement(userId, 'streak_30');
      }
    } catch (e) {
      print('Streak başarı kontrolü hatası: $e');
    }
  }

  // Çalışma saati bazlı başarıları kontrol et
  Future<void> checkStudyAchievements(String userId, double totalStudyHours) async {
    try {
      if (totalStudyHours >= 10) {
        await _firestoreService.unlockAchievement(userId, 'study_10h');
      }
      if (totalStudyHours >= 50) {
        await _firestoreService.unlockAchievement(userId, 'study_50h');
      }
    } catch (e) {
      print('Çalışma başarı kontrolü hatası: $e');
    }
  }

  // İlk alışkanlık başarısı
  Future<void> unlockFirstHabitAchievement(String userId) async {
    try {
      await _firestoreService.unlockAchievement(userId, 'first_habit');
    } catch (e) {
      print('İlk alışkanlık başarısı hatası: $e');
    }
  }

  // Motivasyon mesajı oluştur
  String getMotivationalMessage(int streakDays) {
    if (streakDays == 0) {
      return 'Hadi başlayalım! İlk adımı atma zamanı! 🚀';
    } else if (streakDays < 7) {
      return 'Harika gidiyorsun! $streakDays gün streak! 💪';
    } else if (streakDays < 30) {
      return 'Muhteşem! $streakDays gün üst üste! Devam et! 🔥';
    } else if (streakDays < 100) {
      return 'İnanılmaz! $streakDays gün streak! Sen bir şampiyonsun! 🏆';
    } else {
      return 'Efsanesin! $streakDays gün! Sınırları zorluyorsun! 🌟';
    }
  }

  // Günlük hedef önerisi
  String getDailyGoalSuggestion(int completedHabits, int totalHabits) {
    if (completedHabits == 0) {
      return 'Bugün en az 1 alışkanlığını tamamla!';
    } else if (completedHabits < totalHabits) {
      return 'Harika! ${totalHabits - completedHabits} alışkanlık daha kaldı!';
    } else {
      return 'Tebrikler! Bugünün tüm alışkanlıklarını tamamladın! 🎉';
    }
  }
}
