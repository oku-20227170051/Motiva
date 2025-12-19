import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String userId;
  final int? age;
  final String? gender; // 'Erkek', 'Kadın', 'Belirtmek İstemiyorum'
  final String? bio;
  final String? photoUrl;
  final DateTime updatedAt;

  UserProfileModel({
    required this.userId,
    this.age,
    this.gender,
    this.bio,
    this.photoUrl,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // Firestore'dan veri okuma
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      userId: doc.id,
      age: data['age'],
      gender: data['gender'],
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'age': age,
      'gender': gender,
      'bio': bio,
      'photoUrl': photoUrl,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // copyWith metodu
  UserProfileModel copyWith({
    String? userId,
    int? age,
    String? gender,
    String? bio,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
