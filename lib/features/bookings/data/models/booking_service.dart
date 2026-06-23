import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:darb/core/network/dio_client.dart'; 
import 'passenger_model.dart';
import 'bank_account_model.dart'; // تأكد من استيراد مودل البنك الصحيح

class BookingService {
  final DioClient _dioClient = DioClient();

  Future<List<BankAccountModel>> getCompanyBankAccounts(int companyId) async {
    try {
      final response = await _dioClient.get('/Customer/bank/accounts/$companyId');
      
      if (response.statusCode == 200 && response.data is Map) {
        if (response.data['data'] != null && response.data['data'] is List) {
          List<dynamic> dataList = response.data['data'];
          return dataList.map((json) => BankAccountModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching bank accounts: $e");
      return [];
    }
  }

  Future<int?> createBookingStage1({required int tripRouteId, required List<Map<String, dynamic>> passengers}) async {
    try {
      final response = await _dioClient.post(
        '/Customer/trips/book',
        data: {"tripRouteId": tripRouteId, "additionalPassengers": passengers},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          final data = response.data;
          
          if (data['data'] is int) {
            return data['data']; 
          } else if (data['data'] is Map) {
            return data['data']['bookingId'] ?? data['data']['id'];
          }
          
          return data['bookingId'] ?? data['id'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error in Stage 1 Booking: $e");
      return null;
    }
  }

  Future<bool> uploadBookingReceiptStage2(int bookingId, File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "BookingId": bookingId,
        "ReceiptImage": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dioClient.post(
        '/Customer/upload/booking/receipt',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error in Stage 2 Receipt Upload: $e");
      return false;
    }
  }

  Future<List<dynamic>> getBookingsByStatus(int statusId) async {
    try {
      final response = await _dioClient.get('/Customer/bookings/status', queryParameters: {'status': statusId});
      return (response.statusCode == 200 && response.data is Map) ? (response.data['data'] ?? []) : [];
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      return [];
    }
  }

  Future<List<dynamic>> getBookingStatuses() async {
    try {
      final response = await _dioClient.get('/Customer/bookings/status-banner');
      return (response.statusCode == 200 && response.data is Map) ? (response.data['data'] ?? []) : [];
    } catch (e) {
      debugPrint("Error fetching statuses: $e");
      return [];
    }
  }
}