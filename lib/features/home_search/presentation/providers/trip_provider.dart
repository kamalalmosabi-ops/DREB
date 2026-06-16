import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart'; // تأكد أن هذا المسار يطابق مجلدك
import 'package:darb/core/network/dio_client.dart';

class TripProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();
  
  List<Trip> trips = [];
  bool isLoading = false;

  // دالة لجلب كل الرحلات المتاحة
  Future<void> fetchAllTrips() async {
    isLoading = true;
    notifyListeners();

    try {
      // إرسال القيم صفر كافتراضي لجلب الكل
      final response = await _dioClient.post(
        '/Customer/home/search',
        data: {
          "fromGovernorateId": 0,
          "toGovernorateId": 0,
          "companyId": 0,
          "periodId": 0,
          "date": null
        }
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['success'] == true && resData['data'] != null) {
          final List<dynamic> tripsData = resData['data'];
          trips = tripsData.map((json) => Trip.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint("خطأ في جلب كل الرحلات: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // دالة البحث المخصص
  Future<void> search({
    required int fromId,
    required int toId,
    required int companyId,
    required int periodId,
    required String date,
  }) async {
    isLoading = true;
    trips.clear();
    notifyListeners();

    try {
      // إرسال البيانات (البودي) كما يتوقعها السيرفر بالضبط
      final response = await _dioClient.post(
        '/Customer/home/search',
        data: {
          "fromGovernorateId": fromId,
          "toGovernorateId": toId,
          "companyId": companyId,
          "periodId": periodId,
          "date": date.isEmpty ? null : date // إذا كان التاريخ فارغاً نرسله null
        }
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['success'] == true && resData['data'] != null) {
          final List<dynamic> tripsData = resData['data'];
          trips = tripsData.map((json) => Trip.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint("خطأ في البحث عن الرحلات: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}