import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String type; // password_reset, support, suggestion
  final String subject;
  final String message;
  final String status; // pending, in_progress, resolved, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminResponse;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.subject,
    required this.message,
    this.status = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.adminResponse,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Firestore'dan veri okuma
  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      type: data['type'] ?? 'support',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      adminResponse: data['adminResponse'],
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': type,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'adminResponse': adminResponse,
    };
  }

  // Talep türü gösterimi
  String get typeDisplay {
    switch (type) {
      case 'password_reset':
        return 'Şifre Sıfırlama';
      case 'support':
        return 'Genel Destek';
      case 'suggestion':
        return 'Öneri';
      default:
        return 'Diğer';
    }
  }

  // Durum gösterimi
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'in_progress':
        return 'İşlemde';
      case 'resolved':
        return 'Çözüldü';
      case 'rejected':
        return 'Reddedildi';
      default:
        return 'Bilinmiyor';
    }
  }

  // copyWith metodu
  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? type,
    String? subject,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}
