import 'package:flutter/material.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';
import '../../data/models/company_api_service.dart';

class CompanyDetailsProvider extends ChangeNotifier {
  final CompanyApiService _apiService = CompanyApiService();
  
  List<Trip> _trips = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCompanyTrips(int companyId) async {
    _isLoading = true;
    _errorMessage = '';
    _trips = []; // تصفية الرحلات السابقة لعدم حدوث تداخل بين الشركات
    notifyListeners();

    try {
      _trips = await _apiService.getCompanyTrips(companyId);
    } catch (e) {
      _errorMessage = 'لا توجد رحلات متاحة لهذه الشركة حالياً.';
      debugPrint("🛠️ Error in fetchCompanyTrips: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // 🟢 تضمن تحديث الواجهة وإيقاف مؤشر التحميل في كل الحالات
    }
  }
}