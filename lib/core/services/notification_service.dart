import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // كود ثابت للـ Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. إعدادات الإشعارات المحلية (أندرويد)
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(
        android: androidSettings, iOS: DarwinInitializationSettings());

    // تم إرجاع المعامل المسمى (settings:) للتوافق مع التحديث الجديد
    await _localNotifications.initialize(settings: settings);

    // 2. طلب إذن الإشعارات من المستخدم (مهم جداً لنظام iOS وأندرويد الحديث)
    await FirebaseMessaging.instance.requestPermission();

    // 3. الاستماع للإشعارات وأنت داخل التطبيق (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    // تم إرجاع المعاملات المسماة (id:, title:, body:, notificationDetails:) هنا أيضاً
    _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // هذا الاسم يجب أن يتطابق مع الـ AndroidManifest
          'Darb Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
    );
  }
}