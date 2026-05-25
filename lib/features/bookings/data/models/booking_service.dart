import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/passenger_model.dart';
import 'package:flutter/foundation.dart';

class BookingService {
  final String baseUrl = "https://your-api-domain.com/api"; // استبدليها برابط السيرفر الفعلي

  // 1. جلب حسابات البنك الخاصة بالشركة ديناميكياً
  Future<List<BankAccountModel>> getCompanyBankAccounts(int companyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Customer/bank/accounts/$companyId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankAccountModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching bank accounts: $e");
      return [];
    }
  }

  // 2. تنفيذ عملية الحجز كاملة (المرحلة 1 + المرحلة 2)
  Future<int?> createBookingStage1(BookingRequestModel bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Customer/trips/book'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bookingData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // نفترض أن السيرفر يعيد الـ id الخاص بالحجز مباشرة أو داخل كائن
        return responseData['bookingId'] ?? responseData['id']; 
      }
      return null;
    } catch (e) {
      debugPrint("Error in Stage 1 Booking: $e");
      return null;
    }
  }

  // 3. رفع صورة السند لتأكيد الحجز (المرحلة 2)
  Future<bool> uploadBookingReceiptStage2(int bookingId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Customer/upload/booking/receipt'),
      );

      // إضافة الحقول النصية المتطلبة في الـ Swagger
      request.fields['BookingId'] = bookingId.toString();

      // إضافة ملف الصورة المتطلب (ReceiptImage)
      request.files.add(await http.MultipartFile.fromPath(
        'ReceiptImage',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // أو png حسب الملف
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error in Stage 2 Receipt Upload: $e");
      return false;
    }
  }
  // جلب حالات الحجوزات
  Future<List<dynamic>> getBookingStatuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Customer/bookings/status-banner'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching statuses: $e");
      return [];
    }
  }

  // جلب الحجوزات حسب الحالة
  Future<List<dynamic>> getBookingsByStatus(int statusId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Customer/bookings/status?status=$statusId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      return [];
    }
  }
}