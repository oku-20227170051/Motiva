import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final double progress; // 0-100 arası ilerleme yüzdesi
  final DateTime createdAt;
  final String? category; // TYT, AYT, YDT vb.

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
    this.progress = 0.0,
    DateTime? createdAt,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore'dan veri okuma
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      progress: (data['progress'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: data['category'],
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'targetDate': Timestamp.fromDate(targetDate),
      'isCompleted': isCompleted,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
    };
  }

  // Hedef tarihe kalan gün sayısı
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  // Hedef tarihi geçti mi?
  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  // İlerleme güncelle
  GoalModel updateProgress(double newProgress) {
    return copyWith(
      progress: newProgress.clamp(0, 100),
      isCompleted: newProgress >= 100,
    );
  }

  // Hedefi tamamla
  GoalModel complete() {
    return copyWith(
      isCompleted: true,
      progress: 100,
    );
  }

  // copyWith metodu
  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    double? progress,
    DateTime? createdAt,
    String? category,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
