import 'package:flutter/foundation.dart';
import 'package:darb/core/network/dio_client.dart'; // تأكد من صحة مسار DioClient
import '../models/trip_model.dart'; 

class TripApiService {
  final DioClient _dioClient = DioClient();

  // 1. دالة البحث المخصصة (تستقبل الآن أرقام IDs حسب الـ Swagger بدلاً من نصوص)
  Future<List<Trip>> searchTrips({
    required int fromGovernorateId,
    required int toGovernorateId,
    required int companyId,
    required int periodId,
    required String date,
  }) async {
    try {
      final response = await _dioClient.post(
        '/Customer/home/search',
        data: {
          "fromGovernorateId": fromGovernorateId,
          "toGovernorateId": toGovernorateId,
          "companyId": companyId,
          "periodId": periodId,
          // ✅ السطر السحري: إذا كان التاريخ فارغاً نرسل null، وإلا نرسل التاريخ لتجنب خطأ 400
          "date": date.isEmpty ? null : date,
        },
      );

      debugPrint("=== [API Request - SEARCH TRIPS] ===");
      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        final decodedData = response.data;
        
        if (decodedData is List) {
          return decodedData.map((item) => Trip.fromJson(item)).toList();
        } else if (decodedData is Map && decodedData.containsKey('trips')) {
          List tripsList = decodedData['trips'];
          return tripsList.map((item) => Trip.fromJson(item)).toList();
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          List dataList = decodedData['data'];
          return dataList.map((item) => Trip.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception("فشل البحث: رمز الخطأ ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("خطأ في خدمة البحث: $e");
      rethrow;
    }
  }

  // 2. الدالة الجديدة: جلب جميع الرحلات (باستخدام نفس الرابط ولكن بإرسال 0)
  Future<List<Trip>> getAllTrips() async {
    try {
      // حسب الـ Swagger: إذا أرسلنا قيم فارغة (أصفار)، سيرجع السيرفر كافة الرحلات المجدولة
      final response = await _dioClient.post(
        '/Customer/home/search',
        data: {
          "fromGovernorateId": 0,
          "toGovernorateId": 0,
          "companyId": 0,
          "periodId": 0,
          // ✅ تم التعديل هنا: نرسل null بدلاً من "" لكي يقبلها السيرفر بدون أخطاء
          "date": null, 
        },
      );

      debugPrint("=== [API Request - GET ALL TRIPS] ===");
      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        final decodedData = response.data;
        
        if (decodedData is List) {
          return decodedData.map((item) => Trip.fromJson(item)).toList();
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          List dataList = decodedData['data'];
          return dataList.map((item) => Trip.fromJson(item)).toList();
        } else if (decodedData is Map && decodedData.containsKey('trips')) {
          List tripsList = decodedData['trips'];
          return tripsList.map((item) => Trip.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception("فشل جلب الرحلات: رمز الخطأ ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("خطأ في خدمة جلب جميع الرحلات: $e");
      rethrow;
    }
  }
}