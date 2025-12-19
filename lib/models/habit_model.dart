import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startDate; // Başlangıç tarihi
  final DateTime endDate; // Bitiş tarihi
  final int targetDays; // Hedef gün sayısı (geriye dönük uyumluluk için)
  final int currentStreak; // Mevcut ardışık gün sayısı
  final int longestStreak; // En uzun ardışık gün sayısı
  final List<DateTime> completedDates; // Tamamlanan günler
  final DateTime createdAt;
  final bool isActive;
  final int colorIndex; // Takvimde gösterilecek renk indexi (0-9)

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    DateTime? startDate,
    DateTime? endDate,
    this.targetDays = 30,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    this.isActive = true,
    this.colorIndex = 0,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 30)),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Firestore'dan veri okuma
  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),
      targetDays: data['targetDays'] ?? 30,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      completedDates: (data['completedDates'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      colorIndex: data['colorIndex'] ?? 0,
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'targetDays': targetDays,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedDates':
          completedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'colorIndex': colorIndex,
    };
  }

  // Bugün tamamlandı mı kontrol et
  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  // Belirli bir tarihte tamamlandı mı kontrol et
  bool isCompletedOnDate(DateTime date) {
    return completedDates.any((completedDate) =>
        completedDate.year == date.year &&
        completedDate.month == date.month &&
        completedDate.day == date.day);
  }

  // Alışkanlık bu tarihte aktif mi (tarih aralığında mı)
  bool isActiveOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    
    return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
           (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  // Toplam gün sayısı (tarih aralığı)
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Alışkanlığı bugün için tamamla
  HabitModel completeToday() {
    if (isCompletedToday()) return this;

    final newCompletedDates = [...completedDates, DateTime.now()];
    final newStreak = _calculateStreak(newCompletedDates);

    return copyWith(
      completedDates: newCompletedDates,
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
    );
  }

  // Streak hesaplama
  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a)); // Yeniden eskiye sırala
    int streak = 1;
    DateTime lastDate = dates[0];

    for (int i = 1; i < dates.length; i++) {
      final diff = lastDate.difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
        lastDate = dates[i];
      } else {
        break;
      }
    }

    return streak;
  }

  // İlerleme yüzdesi (tamamlanan gün sayısı / toplam gün sayısı)
  double get progressPercentage {
    if (totalDays == 0) return 0;
    final completedInRange = completedDates.where((date) => isActiveOnDate(date)).length;
    return (completedInRange / totalDays * 100).clamp(0, 100);
  }

  // copyWith metodu
  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? targetDays,
    int? currentStreak,
    int? longestStreak,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    bool? isActive,
    int? colorIndex,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetDays: targetDays ?? this.targetDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
