import 'package:darb/core/network/dio_client.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';  

class NotificationApiService {
  final DioClient _dioClient = DioClient();

  // 1. جلب الإشعارات الخاصة بي
  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _dioClient.get('/Notification/my-notifications');
    if (response.statusCode == 200 && response.data['data'] != null) {
      return (response.data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  // 2. تحديد الإشعار كمقروء
  Future<void> markAsRead(int id) async {
    await _dioClient.put('/Notification/$id/read');
  }

  // 3. تسجيل توكن الجهاز لـ FCM
  Future<void> registerDeviceToken({required String fcmToken, required int deviceType}) async {
    await _dioClient.post('/Notification/register-token', data: {"token": fcmToken, "deviceType": deviceType});
  }

  // 4. إرسال إشعار آمن
  Future<void> sendSecureNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
  }) async {
    await _dioClient.post('/Notification/send', data: {
      "receiverId": receiverId,
      "title": title,
      "body": body,
      "category": category,
      "senderType": senderType,
      "senderCompanyId": senderCompanyId,
    });
  }

  // 5. إرسال إشعار تجريبي
  Future<void> sendTestNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
  }) async {
    await _dioClient.post('/Notification/send-test', data: {
      "receiverId": receiverId,
      "title": title,
      "body": body,
      "category": category,
      "senderType": senderType,
      "senderCompanyId": senderCompanyId,
    });
  }

  // 6. جلب إشعارات مستخدم معين
  Future<List<NotificationModel>> getSpecificUserNotifications({required int userId}) async {
    final response = await _dioClient.get('/Notification/user/$userId');
    if (response.statusCode == 200 && response.data['data'] != null) {
      return (response.data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  // 7. الفحص الذاتي لنظام الإشعارات
  Future<Map<String, dynamic>> runNotificationSelfTest() async {
    final response = await _dioClient.get('/Notification/self-test');
    return response.data as Map<String, dynamic>;
  }
}