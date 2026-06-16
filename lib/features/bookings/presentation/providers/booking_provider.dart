import 'dart:io';
import 'package:flutter/material.dart';
import 'package:darb/features/bookings/data/models/passenger_model.dart';
import 'package:darb/features/bookings/data/models/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  List<BankAccountModel> bankAccounts = [];
  List<dynamic> bookings = [];
  bool isLoading = false;
  bool isSubmitting = false;
  File? receiptImage; // هذا المتغير الذي كانت تنقصك الدالة لتحديثه

  // تحديث صورة السند (هذه الدالة التي كانت تظهر كخطأ)
  void updateReceiptImage(File? image) {
    receiptImage = image;
    notifyListeners();
  }

  Future<void> loadCompanyBankAccounts(int companyId) async {
    isLoading = true; notifyListeners();
    bankAccounts = await _service.getCompanyBankAccounts(companyId);
    isLoading = false; notifyListeners();
  }

  Future<int?> submitBooking({required int tripRouteId, required List<PassengerModel> passengers, required File receipt}) async {
    isSubmitting = true; notifyListeners();
    List<Map<String, dynamic>> passengerList = passengers.map((p) => p.toJson()).toList();
    int? bookingId = await _service.createBookingStage1(tripRouteId: tripRouteId, passengers: passengerList);
    
    if (bookingId != null) {
      bool uploaded = await _service.uploadBookingReceiptStage2(bookingId, receipt);
      isSubmitting = false; notifyListeners();
      return uploaded ? bookingId : null;
    }
    isSubmitting = false; notifyListeners();
    return null;
  }

  Future<void> fetchBookings(int statusId) async {
    isLoading = true; notifyListeners();
    bookings = await _service.getBookingsByStatus(statusId);
    isLoading = false; notifyListeners();
  }
}