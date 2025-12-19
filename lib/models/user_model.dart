import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String username; // Benzersiz kullanıcı adı (küçük harf)
  final DateTime createdAt;
  final int totalPoints;
  final int level;
  final bool isAdmin; // Admin kullanıcı mı?

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.createdAt,
    this.totalPoints = 0,
    this.level = 1,
    this.isAdmin = false,
  });

  // Firestore'dan veri okuma
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? 'user_${doc.id.substring(0, 8)}', // Varsayılan username
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalPoints: data['totalPoints'] ?? 0,
      level: data['level'] ?? 1,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'username': username.toLowerCase(), // Küçük harfe çevir
      'createdAt': Timestamp.fromDate(createdAt),
      'totalPoints': totalPoints,
      'level': level,
      'isAdmin': isAdmin,
    };
  }

  // JSON'dan model oluşturma
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  // Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
      'totalPoints': totalPoints,
      'level': level,
    };
  }

  // copyWith metodu - değişiklik yapmak için
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? username,
    DateTime? createdAt,
    int? totalPoints,
    int? level,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
