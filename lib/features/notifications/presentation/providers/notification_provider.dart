import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import 'package:darb/features/notifications/data/models/notification_api_service.dart';  

class NotificationProvider with ChangeNotifier {
  final NotificationApiService _api = NotificationApiService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // 1. جلب الإشعارات
  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners(); 
    try {
      _notifications = await _api.getMyNotifications(token);
    } catch (e) {
      debugPrint("خطأ في جلب الإشعارات: $e");
      _notifications = []; 
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // 2. تحويل إشعار معين لمقروء
  Future<void> markAsRead(int id, String token) async {
    try {
      await _api.markAsRead(id, token);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners(); 
      }
    } catch (e) {
      debugPrint("خطأ في تحديث حالة الإشعار: $e");
    }
  }

  // 3. قراءة كل الإشعارات دفعة واحدة
  Future<void> markAllNotificationsAsRead(String token) async {
    try {
      for (var noti in _notifications) {
        if (!noti.isRead) {
          await _api.markAsRead(noti.id, token);
          noti.isRead = true;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("خطأ أثناء قراءة جميع الإشعارات: $e");
    }
  }

  // 4. تسجيل توكن الجهاز لـ FCM
  Future<void> registerDeviceToken(String fcmToken, int deviceType, String token) async {
    try {
      await _api.registerDeviceToken(
        fcmToken: fcmToken, 
        deviceType: deviceType, 
        token: token,
      );
    } catch (e) {
      debugPrint("Error registering device token: $e");
    }
  }

  // 5. إرسال إشعار آمن
  Future<void> sendSecureNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
    required String token,
  }) async {
    try {
      await _api.sendSecureNotification(
        receiverId: receiverId,
        title: title,
        body: body,
        category: category,
        senderType: senderType,
        senderCompanyId: senderCompanyId,
        token: token,
      );
    } catch (e) {
      debugPrint("Error sending secure notification: $e");
    }
  }

  // 6. إرسال إشعار تجريبي
  Future<void> sendTestNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
    required String token,
  }) async {
    try {
      await _api.sendTestNotification(
        receiverId: receiverId,
        title: title,
        body: body,
        category: category,
        senderType: senderType,
        senderCompanyId: senderCompanyId,
        token: token,
      );
    } catch (e) {
      debugPrint("Error sending test notification: $e");
    }
  }

  // 7. جلب إشعارات مستخدم معين
  Future<void> getSpecificUserNotifications(int userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _api.getSpecificUserNotifications(
        userId: userId, 
        token: token,
      );
    } catch (e) {
      debugPrint("Error getting specific user notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 8. تشغيل الفحص الذاتي
  Future<Map<String, dynamic>?> runNotificationSelfTest() async {
    try {
      return await _api.runNotificationSelfTest();
    } catch (e) {
      debugPrint("Error running self test: $e");
      return null;
    }
  }
}