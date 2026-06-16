import 'package:dio/dio.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';  

class NotificationApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://server-darb.runasp.net',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // 1. جلب الإشعارات الخاصة بي
  Future<List<NotificationModel>> getMyNotifications(String token) async {
    final response = await _dio.get('/api/Notification/my-notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // 2. تحديد الإشعار كمقروء
  Future<void> markAsRead(int id, String token) async {
    await _dio.put('/api/Notification/$id/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 3. تسجيل توكن الجهاز لـ FCM
  Future<void> registerDeviceToken({
    required String fcmToken,
    required int deviceType,
    required String token,
  }) async {
    await _dio.post('/api/Notification/register-token',
        data: {"token": fcmToken, "deviceType": deviceType},
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 4. إرسال إشعار آمن
  Future<void> sendSecureNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
    required String token,
  }) async {
    await _dio.post('/api/Notification/send',
        data: {
          "receiverId": receiverId,
          "title": title,
          "body": body,
          "category": category,
          "senderType": senderType,
          "senderCompanyId": senderCompanyId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 5. إرسال إشعار تجريبي
  Future<void> sendTestNotification({
    required int receiverId,
    required String title,
    required String body,
    required int category,
    required int senderType,
    required int senderCompanyId,
    required String token,
  }) async {
    await _dio.post('/api/Notification/send-test',
        data: {
          "receiverId": receiverId,
          "title": title,
          "body": body,
          "category": category,
          "senderType": senderType,
          "senderCompanyId": senderCompanyId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // 6. جلب إشعارات مستخدم معين
  Future<List<NotificationModel>> getSpecificUserNotifications({
    required int userId,
    required String token,
  }) async {
    final response = await _dio.get('/api/Notification/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // 7. الفحص الذاتي لنظام الإشعارات
  Future<Map<String, dynamic>> runNotificationSelfTest() async {
    final response = await _dio.get('/api/Notification/self-test');
    return response.data as Map<String, dynamic>;
  }
}