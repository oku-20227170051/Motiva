import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipModel {
  final String userId;      // Arkadaş ekleyen
  final String friendId;    // Eklenen arkadaş
  final DateTime createdAt;

  FriendshipModel({
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  // Firestore'dan veri okuma
  factory FriendshipModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FriendshipModel(
      userId: data['userId'] ?? '',
      friendId: data['friendId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'friendId': friendId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
