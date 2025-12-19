import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bildirim başlatma
  Future<void> initialize() async {
    // Timezone başlat
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android ayarları
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // İzin iste (Android 13+)
    await _requestPermissions();
  }

  // İzin kontrolü
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Bildirime tıklandığında
  void _onNotificationTapped(NotificationResponse response) {
    print('Bildirime tıklandı: ${response.payload}');
  }

  // Günlük bildirimleri planla
  Future<void> scheduleDailyNotifications(String userId) async {
    // Sabah 09:00
    await _scheduleDailyNotification(
      id: 1,
      hour: 9,
      minute: 0,
      title: 'Günaydın! 🌅',
      body: 'Bugünkü alışkanlıklarını tamamlamayı unutma! 💪',
      userId: userId,
    );

    // Öğlen 12:00
    await _scheduleDailyNotification(
      id: 2,
      hour: 12,
      minute: 0,
      title: 'Günün Yarısı! ⏰',
      body: 'Alışkanlıklarını kontrol et! 🎯',
      userId: userId,
    );

    // Akşam 20:00
    await _scheduleDailyNotification(
      id: 3,
      hour: 20,
      minute: 0,
      title: 'Gün Bitmeden! 🌙',
      body: 'Alışkanlıklarını tamamla! 🌟',
      userId: userId,
    );
  }

  // Tek bir günlük bildirim planla
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String userId,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notifications',
          'Günlük Hatırlatmalar',
          channelDescription: 'Alışkanlık hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Bildirimi Firestore'a kaydet
    await _saveNotificationToHistory(userId, title, body);
  }

  // Bir sonraki bildirim zamanını hesapla
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Eğer zaman geçmişse, yarına ayarla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Bildirimi geçmişe kaydet
  Future<void> _saveNotificationToHistory(
    String userId,
    String title,
    String body,
  ) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      sentAt: DateTime.now(),
    );

    await _firestore.collection('notifications').add(notification.toFirestore());
  }

  // Kullanıcının bildirim geçmişini getir
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    await _notifications.show(
      0,
      'Test Bildirimi',
      'Bildirimler çalışıyor! 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Bildirimleri',
          channelDescription: 'Test için bildirimler',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
