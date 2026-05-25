import 'package:flutter/material.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';
import 'package:darb/features/home_search/data/models/trip_api_service.dart';   

class TripProvider with ChangeNotifier {
  final TripApiService _api = TripApiService();
  List<Trip> _trips = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> search(String from, String to, String date) async {
    // التحقق من البيانات المرسلة لمنع الطلبات الفارغة
    if (from.isEmpty || to.isEmpty) {
      debugPrint("تنبيه: حقول المدن فارغة، لن يتم إرسال طلب للسيرفر.");
      _trips = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = "";
    _trips = []; // تصفية نتائج البحث القديمة فوراً ليظهر المؤشر بسلاسة
    notifyListeners();
    
    try {
      debugPrint("جاري إرسال طلب البحث للرحلات من $from إلى $to بتاريخ $date");
      _trips = await _api.searchTrips(from, to, date);
    } catch (e) {
      debugPrint("حدث خطأ أثناء تحديث البيانات في الـ Provider: $e");
      _errorMessage = e.toString();
      _trips = []; // تفريغ القائمة عند حدوث خطأ لكسر اللوب اللانهائي للمؤشر
    } finally {
      // إغلاق مؤشر التحميل في كل الأحوال (سواء نجح الطلب أو فشل)
      _isLoading = false;
      notifyListeners();
    }
  }
}