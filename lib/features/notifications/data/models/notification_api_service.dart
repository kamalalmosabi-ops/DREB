import 'package:dio/dio.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';  

class NotificationApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server-darb.runasp.net'));

  // جلب الإشعارات
  Future<List<NotificationModel>> getMyNotifications(String token) async {
    final response = await _dio.get('/api/Notification/my-notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  // تحديد كمقروءة
  Future<void> markAsRead(int id, String token) async {
    await _dio.put('/api/Notification/$id/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }
}