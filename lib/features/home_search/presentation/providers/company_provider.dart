import 'package:flutter/material.dart';
import 'package:darb/features/home_search/data/models/company_model.dart';
import 'package:darb/features/home_search/data/models/company_api_service.dart';   

class CompanyProvider with ChangeNotifier {
  final CompanyApiService _apiService = CompanyApiService();
  List<Company> _companies = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      _companies = await _apiService.getAllCompanies();
    } catch (e) {
      _errorMessage = e.toString();
      _companies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}