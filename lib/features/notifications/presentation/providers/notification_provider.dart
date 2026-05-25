import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import 'package:darb/features/notifications/data/models/notification_api_service.dart';  

class NotificationProvider with ChangeNotifier {
  // تعريف الخدمة
  final NotificationApiService _api = NotificationApiService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// دالة جلب الإشعارات من السيرفر
  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners(); // إخبار الواجهة ببدء التحميل

    try {
      _notifications = await _api.getMyNotifications(token);
    } catch (e) {
      debugPrint("خطأ في جلب الإشعارات: $e");
      _notifications = []; // في حال حدوث خطأ نجعل القائمة فارغة
    } finally {
      _isLoading = false;
      notifyListeners(); // إخبار الواجهة بانتهاء التحميل
    }
  }

  /// دالة تحديث حالة الإشعار (مقروء)
  Future<void> markAsRead(int id, String token) async {
    try {
      // إرسال الطلب للسيرفر
      await _api.markAsRead(id, token);
      
      // تحديث الحالة محلياً في القائمة فوراً
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners(); // تحديث الواجهة فوراً
      }
    } catch (e) {
      debugPrint("خطأ في تحديث حالة الإشعار: $e");
    }
  }
}