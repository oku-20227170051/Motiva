import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';
import '../models/goal_model.dart';
import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../models/user_profile_model.dart';
import '../models/support_ticket_model.dart';
import '../models/friend_request_model.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER İŞLEMLERİ ====================

  // Kullanıcı oluştur
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw 'Kullanıcı oluşturulamadı: $e';
    }
  }

  // Kullanıcı bilgilerini al
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Kullanıcı bilgileri alınamadı: $e';
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw 'Kullanıcı bilgileri güncellenemedi: $e';
    }
  }

  // Kullanıcı adı müsait mi kontrol et
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final lowercaseUsername = username.toLowerCase();
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: lowercaseUsername)
          .limit(1)
          .get();
      
      return query.docs.isEmpty; // Boşsa müsait
    } catch (e) {
      print('Kullanıcı adı kontrolü hatası: $e');
      return false;
    }
  }

  // Kullanıcı adına göre kullanıcı ara
  Future<List<UserModel>> searchUsersByUsername(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final lowercaseQuery = query.toLowerCase();
      
      // Username ile başlayanları ara
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('username', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Kullanıcı arama hatası: $e');
      return [];
    }
  }

  // Kullanıcı adına göre kullanıcı getir
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final lowercaseUsername = username.toLowerCase();
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: lowercaseUsername)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Kullanıcı getirme hatası: $e');
      return null;
    }
  }

  // ==================== ARKADAŞLIK İŞLEMLERİ ====================

  // Arkadaş ekle
  Future<void> addFriend(String userId, String friendId) async {
    try {
      // İki yönlü arkadaşlık oluştur
      await _firestore.collection('friendships').add({
        'userId': userId,
        'friendId': friendId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Arkadaş ekleme hatası: $e');
      throw 'Arkadaş eklenemedi';
    }
  }

  // Arkadaşlıktan çıkar
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      // Arkadaşlık kaydını bul ve sil
      QuerySnapshot query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Arkadaşlıktan çıkarma hatası: $e');
      throw 'Arkadaşlıktan çıkarılamadı';
    }
  }

  // Arkadaş listesi getir
  Future<List<UserModel>> getFriends(String userId) async {
    try {
      // Arkadaş ID'lerini al
      QuerySnapshot friendships = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .get();

      List<String> friendIds = friendships.docs
          .map((doc) => doc['friendId'] as String)
          .toList();

      if (friendIds.isEmpty) return [];

      // Arkadaş bilgilerini al
      List<UserModel> friends = [];
      for (String friendId in friendIds) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(friendId)
            .get();
        
        if (userDoc.exists) {
          friends.add(UserModel.fromFirestore(userDoc));
        }
      }

      return friends;
    } catch (e) {
      print('Arkadaş listesi getirme hatası: $e');
      return [];
    }
  }

  // Arkadaş mı kontrol et
  Future<bool> isFriend(String userId, String friendId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Arkadaşlık kontrolü hatası: $e');
      return false;
    }
  }

  // Kullanıcının başarımlarını getir
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Başarımlar getirme hatası: $e');
      return [];
    }
  }

  // ==================== ARKADAŞLIK İSTEKLERİ ====================

  // Arkadaşlık isteği gönder
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    try {
      // Zaten istek var mı kontrol et
      QuerySnapshot existing = await _firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        throw 'Zaten bir istek gönderilmiş';
      }

      // İstek oluştur
      await _firestore.collection('friend_requests').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Bildirim oluştur
      await createNotification(
        userId: receiverId,
        title: 'Yeni Arkadaşlık İsteği',
        message: 'Sana bir arkadaşlık isteği geldi!',
        type: 'friend_request',
      );
    } catch (e) {
      print('Arkadaşlık isteği gönderme hatası: $e');
      throw e.toString();
    }
  }

  // Arkadaşlık isteğini kabul et
  Future<void> acceptFriendRequest(String requestId, String senderId, String receiverId) async {
    try {
      // İsteği güncelle
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'accepted',
      });

      // İki yönlü arkadaşlık oluştur
      await addFriend(receiverId, senderId);
      await addFriend(senderId, receiverId);

      // Bildirim oluştur
      await createNotification(
        userId: senderId,
        title: 'Arkadaşlık Kabul Edildi',
        message: 'Arkadaşlık isteğin kabul edildi!',
        type: 'friend_accept',
      );
    } catch (e) {
      print('Arkadaşlık kabul hatası: $e');
      throw 'Arkadaşlık kabul edilemedi';
    }
  }

  // Arkadaşlık isteğini reddet
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'rejected',
      });
    } catch (e) {
      print('Arkadaşlık reddetme hatası: $e');
      throw 'Arkadaşlık reddedilemedi';
    }
  }

  // Gelen arkadaşlık isteklerini getir
  Future<List<FriendRequestModel>> getFriendRequests(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Arkadaşlık istekleri getirme hatası: $e');
      return [];
    }
  }

  // Bekleyen istek var mı kontrol et
  Future<bool> hasPendingRequest(String userId, String friendId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: userId)
          .where('receiverId', isEqualTo: friendId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('İstek kontrolü hatası: $e');
      return false;
    }
  }

  // ==================== MESAJLAŞMA ====================

  // Mesaj gönder
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    try {
      final conversationId = ConversationModel.generateId(senderId, receiverId);

      // Mesajı kaydet
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Konuşmayı güncelle veya oluştur
      await _firestore.collection('conversations').doc(conversationId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {
          senderId: 0,
          receiverId: FieldValue.increment(1),
        },
      }, SetOptions(merge: true));

      // Bildirim oluştur
      await createNotification(
        userId: receiverId,
        title: 'Yeni Mesaj',
        message: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        type: 'new_message',
      );
    } catch (e) {
      print('Mesaj gönderme hatası: $e');
      throw 'Mesaj gönderilemedi';
    }
  }

  // Mesajları getir (Stream)
  Stream<List<MessageModel>> getMessages(String userId, String friendId) {
    final conversationId = ConversationModel.generateId(userId, friendId);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Konuşmaları getir
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Konuşmalar getirme hatası: $e');
      return [];
    }
  }

  // Mesajları okundu işaretle
  Future<void> markMessagesAsRead(String userId, String friendId) async {
    try {
      final conversationId = ConversationModel.generateId(userId, friendId);

      // Okunmamış mesajları bul
      QuerySnapshot unreadMessages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Toplu güncelleme
      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Unread count sıfırla
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print('Mesaj okundu işaretleme hatası: $e');
    }
  }

  // Bildirim oluştur
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Bildirim oluşturma hatası: $e');
    }
  }

  // Kullanıcı puanını güncelle
  Future<void> updateUserPoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalPoints': FieldValue.increment(points),
      });
    } catch (e) {
      throw 'Puan güncellenemedi: $e';
    }
  }

  // ==================== USER PROFILE İŞLEMLERİ ====================

  // Kullanıcı profilini al
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .get();
      
      if (doc.exists) {
        return UserProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Profil alınamadı: $e');
      return null;
    }
  }

  // Kullanıcı profilini kaydet/güncelle
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('data')
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw 'Profil kaydedilemedi: $e';
    }
  }

  // ==================== HABIT İŞLEMLERİ ====================

  // Alışkanlık ekle
  Future<String> addHabit(HabitModel habit) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('habits')
          .add(habit.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Alışkanlık eklenemedi: $e';
    }
  }

  // Kullanıcının alışkanlıklarını al
  Stream<List<HabitModel>> getUserHabits(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HabitModel.fromFirestore(doc))
            .toList());
  }

  // Kullanıcının alışkanlık sayısını al
  Future<int> getUserHabitCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Alışkanlık sayısı alınamadı: $e');
      return 0;
    }
  }

  // Alışkanlık güncelle
  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _firestore
          .collection('habits')
          .doc(habit.id)
          .update(habit.toFirestore());
    } catch (e) {
      throw 'Alışkanlık güncellenemedi: $e';
    }
  }

  // Alışkanlık sil (soft delete)
  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).update({
        'isActive': false,
      });
    } catch (e) {
      throw 'Alışkanlık silinemedi: $e';
    }
  }

  // Alışkanlığı bugün için tamamla
  Future<void> completeHabitToday(String habitId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('habits').doc(habitId).get();
      if (doc.exists) {
        HabitModel habit = HabitModel.fromFirestore(doc);
        HabitModel updatedHabit = habit.completeToday();
        await updateHabit(updatedHabit);
      }
    } catch (e) {
      throw 'Alışkanlık tamamlanamadı: $e';
    }
  }

  // ==================== GOAL İŞLEMLERİ ====================

  // Hedef ekle
  Future<String> addGoal(GoalModel goal) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('goals').add(goal.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Hedef eklenemedi: $e';
    }
  }

  // Kullanıcının hedeflerini al
  Stream<List<GoalModel>> getUserGoals(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList());
  }

  // Hedef güncelle
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection('goals')
          .doc(goal.id)
          .update(goal.toFirestore());
    } catch (e) {
      throw 'Hedef güncellenemedi: $e';
    }
  }

  // Hedef sil
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      throw 'Hedef silinemedi: $e';
    }
  }

  // ==================== PROGRESS İŞLEMLERİ ====================

  // Günlük ilerleme kaydet
  Future<void> saveProgress(ProgressModel progress) async {
    try {
      // Aynı gün için zaten kayıt var mı kontrol et
      String dateKey =
          '${progress.date.year}-${progress.date.month}-${progress.date.day}';
      QuerySnapshot existing = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: progress.userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(progress.date.year, progress.date.month, progress.date.day)))
          .where('date',
              isLessThan: Timestamp.fromDate(DateTime(
                  progress.date.year, progress.date.month, progress.date.day + 1)))
          .get();

      if (existing.docs.isNotEmpty) {
        // Güncelle
        await _firestore
            .collection('progress')
            .doc(existing.docs.first.id)
            .update(progress.toFirestore());
      } else {
        // Yeni kayıt oluştur
        await _firestore.collection('progress').add(progress.toFirestore());
      }
    } catch (e) {
      throw 'İlerleme kaydedilemedi: $e';
    }
  }

  // Kullanıcının ilerleme geçmişini al
  Stream<List<ProgressModel>> getUserProgress(String userId, {int days = 30}) {
    DateTime startDate = DateTime.now().subtract(Duration(days: days));
    return _firestore
        .collection('progress')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressModel.fromFirestore(doc))
            .toList());
  }

  // Bugünün ilerlemesini al
  Future<ProgressModel?> getTodayProgress(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProgressModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Günlük ilerleme alınamadı: $e';
    }
  }

  // ==================== ACHIEVEMENT İŞLEMLERİ ====================

  // Başarı kilidi aç
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      AchievementModel? achievement = AchievementModel.getDefaultAchievements()
          .firstWhere((a) => a.id == achievementId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .set(achievement.unlock().toFirestore());
    } catch (e) {
      throw 'Başarı kilidi açılamadı: $e';
    }
  }

  // Varsayılan başarıları kullanıcıya ekle
  Future<void> initializeUserAchievements(String userId) async {
    try {
      List<AchievementModel> defaultAchievements =
          AchievementModel.getDefaultAchievements();

      for (var achievement in defaultAchievements) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc(achievement.id)
            .set(achievement.toFirestore());
      }
    } catch (e) {
      throw 'Başarılar başlatılamadı: $e';
    }
  }

  // ==================== SUPPORT TICKET İŞLEMLERİ ====================

  // Destek talebi oluştur
  Future<String> createSupportTicket(SupportTicketModel ticket) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('support_tickets')
          .add(ticket.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Destek talebi oluşturulamadı: $e';
    }
  }

  // Kullanıcının taleplerini al
  Stream<List<SupportTicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportTicketModel.fromFirestore(doc))
            .toList());
  }

  // Tüm talepleri al (Admin)
  Stream<List<SupportTicketModel>> getAllTickets() {
    return _firestore
        .collection('support_tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportTicketModel.fromFirestore(doc))
            .toList());
  }

  // Talep durumunu güncelle
  Future<void> updateTicketStatus(
    String ticketId,
    String status, {
    String? adminResponse,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (adminResponse != null) {
        updateData['adminResponse'] = adminResponse;
      }

      await _firestore
          .collection('support_tickets')
          .doc(ticketId)
          .update(updateData);
    } catch (e) {
      throw 'Talep güncellenemedi: $e';
    }
  }

  // Talep sil
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).delete();
    } catch (e) {
      throw 'Talep silinemedi: $e';
    }
  }

  // ==================== ADMIN USER YÖNETİMİ ====================

  // Tüm kullanıcıları al (Admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Kullanıcı admin durumunu güncelle
  Future<void> setAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
      });
    } catch (e) {
      throw 'Admin durumu güncellenemedi: $e';
    }
  }

  // Bekleyen talep sayısını al
  Future<int> getPendingTicketCount() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('support_tickets')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Bugünkü talep sayısını al
  Future<int> getTodayTicketCount() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      QuerySnapshot snapshot = await _firestore
          .collection('support_tickets')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

