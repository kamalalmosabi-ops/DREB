import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/models/notification_model.dart';
import 'package:darb/features/notifications/data/models/notification_api_service.dart';  

class NotificationProvider with ChangeNotifier {
  final NotificationApiService _api = NotificationApiService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  Timer? _pollingTimer; // مؤقت الفحص الصامت

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((noti) => !noti.isRead).length;

  NotificationProvider() {
    // 1. الاستماع المباشر لإشعارات الفايربيس (إن وصلت)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      fetchNotificationsSilently();
    });

    // 2. فحص صامت كل 15 ثانية (يضمن تحديث العداد حتى لو تأخر السيرفر)
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchNotificationsSilently();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // جلب الإشعارات العادي (يُظهر دائرة تحميل في شاشة الإشعارات)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners(); 
    try {
      _notifications = await _api.getMyNotifications();
    } catch (e) {
      debugPrint("خطأ في جلب الإشعارات: $e");
      _notifications = []; 
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // ✅ دالة جديدة: جلب صامت يعمل في الخلفية بدون التأثير على الواجهة
  Future<void> fetchNotificationsSilently() async {
    try {
      final newNotis = await _api.getMyNotifications();
      int newUnread = newNotis.where((noti) => !noti.isRead).length;

      // نحدث الشاشة فقط إذا كان هناك تغيير فعلي في عدد الإشعارات لتوفير الموارد
      if (unreadCount != newUnread || _notifications.length != newNotis.length) {
        _notifications = newNotis;
        notifyListeners();
      } else {
        _notifications = newNotis; 
      }
    } catch (e) {
      debugPrint("خطأ في الجلب الصامت: $e");
    }
  }

  // تحويل إشعار معين لمقروء
  Future<void> markAsRead(int id) async {
    try {
      await _api.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners(); 
      }
    } catch (e) {
      debugPrint("خطأ في تحديث حالة الإشعار: $e");
    }
  }

  // قراءة كل الإشعارات دفعة واحدة
  Future<void> markAllNotificationsAsRead() async {
    try {
      for (var noti in _notifications) {
        if (!noti.isRead) {
          await _api.markAsRead(noti.id);
          noti.isRead = true;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("خطأ أثناء قراءة جميع الإشعارات: $e");
    }
  }

  Future<void> registerDeviceToken(String fcmToken, int deviceType) async {
    try { await _api.registerDeviceToken(fcmToken: fcmToken, deviceType: deviceType); } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> sendSecureNotification({required int receiverId, required String title, required String body, required int category, required int senderType, required int senderCompanyId}) async {
    try { await _api.sendSecureNotification(receiverId: receiverId, title: title, body: body, category: category, senderType: senderType, senderCompanyId: senderCompanyId); } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> sendTestNotification({required int receiverId, required String title, required String body, required int category, required int senderType, required int senderCompanyId}) async {
    try { await _api.sendTestNotification(receiverId: receiverId, title: title, body: body, category: category, senderType: senderType, senderCompanyId: senderCompanyId); } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> getSpecificUserNotifications(int userId) async {
    _isLoading = true; notifyListeners();
    try { _notifications = await _api.getSpecificUserNotifications(userId: userId); } catch (e) { debugPrint("Error: $e"); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<Map<String, dynamic>?> runNotificationSelfTest() async {
    try { return await _api.runNotificationSelfTest(); } catch (e) { debugPrint("Error: $e"); return null; }
  }
}