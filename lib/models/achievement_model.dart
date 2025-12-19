import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName; // Icon adı (Flutter Icons kullanılacak)
  final int pointsRequired; // Gerekli puan
  final bool isUnlocked; // Kullanıcı tarafından açıldı mı?
  final DateTime? unlockedAt; // Açılma tarihi
  final String category; // Kategori: streak, study, habit vb.

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.pointsRequired,
    this.isUnlocked = false,
    this.unlockedAt,
    this.category = 'general',
  });

  // Firestore'dan veri okuma
  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'emoji_events',
      pointsRequired: data['pointsRequired'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
      category: data['category'] ?? 'general',
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'pointsRequired': pointsRequired,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'category': category,
    };
  }

  // Başarıyı aç
  AchievementModel unlock() {
    return copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  // Varsayılan başarılar listesi
  static List<AchievementModel> getDefaultAchievements() {
    return [
      AchievementModel(
        id: 'first_habit',
        title: 'İlk Adım',
        description: 'İlk alışkanlığını oluşturdun!',
        iconName: 'flag',
        pointsRequired: 0,
        category: 'habit',
      ),
      AchievementModel(
        id: 'streak_7',
        title: '7 Gün Streak',
        description: '7 gün üst üste alışkanlık tamamladın!',
        iconName: 'local_fire_department',
        pointsRequired: 70,
        category: 'streak',
      ),
      AchievementModel(
        id: 'streak_30',
        title: '30 Gün Streak',
        description: '30 gün üst üste alışkanlık tamamladın!',
        iconName: 'whatshot',
        pointsRequired: 300,
        category: 'streak',
      ),
      AchievementModel(
        id: 'study_10h',
        title: 'Çalışkan',
        description: 'Toplam 10 saat çalıştın!',
        iconName: 'school',
        pointsRequired: 100,
        category: 'study',
      ),
      AchievementModel(
        id: 'study_50h',
        title: 'Süper Çalışkan',
        description: 'Toplam 50 saat çalıştın!',
        iconName: 'workspace_premium',
        pointsRequired: 500,
        category: 'study',
      ),
      AchievementModel(
        id: 'points_100',
        title: 'Yükselen Yıldız',
        description: '100 puan kazandın!',
        iconName: 'star',
        pointsRequired: 100,
        category: 'points',
      ),
      AchievementModel(
        id: 'points_500',
        title: 'Süper Yıldız',
        description: '500 puan kazandın!',
        iconName: 'stars',
        pointsRequired: 500,
        category: 'points',
      ),
    ];
  }

  // copyWith metodu
  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? pointsRequired,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? category,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
    );
  }
}
