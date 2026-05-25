import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_model.dart'; 

class TripApiService {
  // تم وضع رابط السيرفر الفعلي وتصحيحه بناءً على سجلات مشروعكِ
  final String baseUrl = "https://server-darb.runasp.net/api"; 

  Future<List<Trip>> searchTrips(String from, String to, String date) async {
    try {
      // إرسال الطلب عبر POST كما يقتضي الـ Swagger للبحث
      final response = await http.post(
        Uri.parse('$baseUrl/Customer/home/search'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "fromCity": from,
          "toCity": to,
          "date": date,
        }),
      );

      // طباعة الرد في الـ Console لسهولة تتبع البيانات ومعرفة المشاكل مستقبلاً
      debugPrint("=== [Darb API Request] ===");
      debugPrint("URL: $baseUrl/Customer/home/search");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        
        final decodedData = jsonDecode(response.body);
        
        // التحقق الذكي من نوع البيانات لمنع كراش الأنماط (Subtype of string/int)
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
        throw Exception("فشل جلب الرحلات: رمز الخطأ ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("خطأ في كلاس الـ API Service: $e");
      rethrow;
    }
  }
}