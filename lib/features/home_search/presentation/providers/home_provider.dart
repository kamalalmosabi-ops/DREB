import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:darb/core/network/dio_client.dart';

class HomeProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  // 1. استقبال كائنات السيرفر
  List<Map<String, dynamic>> rawGovernorates = [];
  List<Map<String, dynamic>> rawCompanies = [];
  List<Map<String, dynamic>> rawPeriods = [];

  // 2. استخراج الأسماء للقوائم المنسدلة
  List<String> get governoratesNames => rawGovernorates.map((e) => (e['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
  List<String> get companiesNames => rawCompanies.map((e) => (e['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList();
  List<String> get periodsNames => rawPeriods.map((e) => (e['name'] ?? '').toString()).where((e) => e.isNotEmpty).toList();

  // 3. مطابقة صريحة لبيانات الـ API لصيد الـ IDs
  int get selectedFromId {
    if (rawGovernorates.isEmpty) return 0;
    final val = selectedFrom ?? governoratesNames.first;
    return rawGovernorates.firstWhere((e) => e['name'] == val, orElse: () => {})['governorateId'] ?? 0;
  }

  int get selectedToId {
    if (rawGovernorates.isEmpty) return 0;
    final val = selectedTo ?? governoratesNames.first;
    return rawGovernorates.firstWhere((e) => e['name'] == val, orElse: () => {})['governorateId'] ?? 0;
  }

  int get selectedCompanyId {
    if (rawCompanies.isEmpty) return 0;
    final val = selectedCompany ?? companiesNames.first;
    return rawCompanies.firstWhere((e) => e['name'] == val, orElse: () => {})['companyId'] ?? 0;
  }

  int get selectedPeriodId {
    if (rawPeriods.isEmpty) return 0;
    final val = selectedTime ?? periodsNames.first;
    return rawPeriods.firstWhere((e) => e['name'] == val, orElse: () => {})['periodId'] ?? 0;
  }

  SearchCardModel? searchData;
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> companiesLogos = []; 
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? selectedFrom;
  String? selectedTo;
  String? selectedCompany;
  String? selectedTime;
  DateTime? selectedDate = DateTime.now();

  void updateSelectedFrom(String? val) { selectedFrom = val; notifyListeners(); }
  void updateSelectedTo(String? val) { selectedTo = val; notifyListeners(); }
  void updateSelectedCompany(String? val) { selectedCompany = val; notifyListeners(); }
  void updateSelectedTime(String? val) { selectedTime = val; notifyListeners(); }
  void updateSelectedDate(DateTime? date) { selectedDate = date; notifyListeners(); }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.get('/Customer/home'); 

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> resData = response.data is Map ? response.data : {};
        
        if (resData.containsKey('data')) {
          final data = resData['data'];

          if (data['adCards'] != null) ads = List<Map<String, dynamic>>.from(data['adCards']);

          if (data['searchCard'] != null) {
            final searchCard = data['searchCard'];

            if (searchCard['governorates'] != null) rawGovernorates = List<Map<String, dynamic>>.from(searchCard['governorates']);
            
            if (searchCard['companies'] != null) {
              rawCompanies = List<Map<String, dynamic>>.from(searchCard['companies']);
              companiesLogos = rawCompanies; 
            }

            // الاعتماد صراحة على periodOptions كما وردت في الـ JSON
            if (searchCard['periodOptions'] != null) {
              rawPeriods = List<Map<String, dynamic>>.from(searchCard['periodOptions']);
            }
          }

          searchData = SearchCardModel(
            governorates: governoratesNames,
            companies: companiesNames,
            periods: periodsNames,
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching API: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}