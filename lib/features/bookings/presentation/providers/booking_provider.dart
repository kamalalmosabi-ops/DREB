import 'dart:io';
import 'package:flutter/material.dart';
import 'package:darb/features/bookings/data/models/passenger_model.dart';  
import 'package:darb/features/bookings/data/models/booking_service.dart';  

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<BankAccountModel> bankAccounts = [];
  bool isLoadingBanks = false;
  bool isSubmitting = false;
  String? paymentMethod;
  File? receiptImage;

  // جلب الحسابات البنكية للشركة
  Future<void> loadCompanyBankAccounts(int companyId) async {
    isLoadingBanks = true;
    notifyListeners(); // لتحديث الواجهة وعرض مؤشر التحميل

    bankAccounts = await _bookingService.getCompanyBankAccounts(companyId);
    
    isLoadingBanks = false;
    notifyListeners();
  }

  // تحديث طريقة الدفع
  void updatePaymentMethod(String? method) {
    paymentMethod = method;
    notifyListeners();
  }

  // تحديث صورة السند
  void updateReceiptImage(File? image) {
    receiptImage = image;
    notifyListeners();
  }

  // تنفيذ عملية الحجز على المرحلتين
  Future<bool> submitBooking({
    required int tripRouteId,
    required List<PassengerModel> passengers,
  }) async {
    if (receiptImage == null) return false;

    isSubmitting = true;
    notifyListeners();

    // المرحلة الأولى: إرسال الركاب وحفظ البيانات
    BookingRequestModel apiData = BookingRequestModel(
      tripRouteId: tripRouteId,
      additionalPassengers: passengers,
    );

    int? bookingId = await _bookingService.createBookingStage1(apiData);

    if (bookingId == null) {
      isSubmitting = false;
      notifyListeners();
      return false;
    }

    // المرحلة الثانية: رفع صورة السند باستخدام الـ ID المستلم
    bool isSuccess = await _bookingService.uploadBookingReceiptStage2(bookingId, receiptImage!);

    isSubmitting = false;
    notifyListeners();
    return isSuccess;
  }
}