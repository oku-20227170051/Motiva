import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final DateTime date;
  final int completedHabits; // Gün içinde tamamlanan alışkanlık sayısı
  final int studyMinutes; // Çalışma dakikası
  final int pointsEarned; // Kazanılan puan
  final Map<String, dynamic>? additionalData; // Ek veriler

  ProgressModel({
    required this.id,
    required this.userId,
    required this.date,
    this.completedHabits = 0,
    this.studyMinutes = 0,
    this.pointsEarned = 0,
    this.additionalData,
  });

  // Firestore'dan veri okuma
  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      completedHabits: data['completedHabits'] ?? 0,
      studyMinutes: data['studyMinutes'] ?? 0,
      pointsEarned: data['pointsEarned'] ?? 0,
      additionalData: data['additionalData'] as Map<String, dynamic>?,
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'completedHabits': completedHabits,
      'studyMinutes': studyMinutes,
      'pointsEarned': pointsEarned,
      'additionalData': additionalData,
    };
  }

  // Çalışma saati (saat cinsinden)
  double get studyHours {
    return studyMinutes / 60.0;
  }

  // İlerleme puanı hesapla
  static int calculatePoints({
    required int completedHabits,
    required int studyMinutes,
  }) {
    // Her tamamlanan alışkanlık için 10 puan
    // Her 30 dakika çalışma için 5 puan
    int habitPoints = completedHabits * 10;
    int studyPoints = (studyMinutes ~/ 30) * 5;
    return habitPoints + studyPoints;
  }

  // copyWith metodu
  ProgressModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? completedHabits,
    int? studyMinutes,
    int? pointsEarned,
    Map<String, dynamic>? additionalData,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      completedHabits: completedHabits ?? this.completedHabits,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
