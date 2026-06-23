import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// ✅ دالة استقبال الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("تم استقبال إشعار في الخلفية: ${message.messageId}");

  // إذا أرسل السيرفر الإشعار كـ Data فقط، نقوم نحن بعرضه يدوياً
  if (message.notification == null && message.data.isNotEmpty) {
    NotificationService().showFallbackNotification(message.data);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. إعداد أيقونة الإشعار
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    
    const InitializationSettings settings = InitializationSettings(
        android: androidSettings, iOS: DarwinInitializationSettings());

    await _localNotifications.initialize(settings: settings);

    // 2. طلب إذن الإشعارات
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. إنشاء قناة إشعارات عالية الأهمية
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'إشعارات هامة', 
      description: 'هذه القناة مخصصة للإشعارات الهامة.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. ربط دالة الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. الاستماع للإشعارات وأنت داخل التطبيق (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("تم استقبال إشعار والتطبيق مفتوح!");
      
      // الحالة الأولي: السيرفر أرسل الإشعار بشكل صحيح
      if (message.notification != null) {
        _showLocalNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'إشعار',
          body: message.notification?.body ?? '',
        );
      } 
      // الحالة الثانية: السيرفر أرسل البيانات كـ data فقط (حل بديل)
      else if (message.data.isNotEmpty) {
        _showLocalNotification(
          id: message.hashCode,
          title: message.data['title'] ?? 'تنبيه جديد',
          body: message.data['body'] ?? 'لديك تحديث جديد في حجوزاتك',
        );
      }
    });
  }

  // ✅ دالة عرض الإشعار المنبثق (تم إضافة المعاملات المسماة لحل الخطأ)
  void _showLocalNotification({required int id, required String title, required String body}) {
    _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', 
          'Darb Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          color: Color(0xFFE79C24),
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // ✅ دالة مساعدة للطوارئ في الخلفية
  Future<void> showFallbackNotification(Map<String, dynamic> data) async {
    _showLocalNotification(
      id: DateTime.now().millisecond,
      title: data['title'] ?? 'إشعار جديد من درب',
      body: data['body'] ?? 'يرجى فتح التطبيق لمعرفة التفاصيل.',
    );
  }
}