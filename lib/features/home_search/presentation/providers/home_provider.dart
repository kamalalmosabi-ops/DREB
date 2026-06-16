import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:darb/core/network/dio_client.dart';

class HomeProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  // 1. استخراج البيانات الحقيقية من السيرفر (مع الآيديات)
  List<Map<String, dynamic>> rawGovernorates = [];
  List<Map<String, dynamic>> rawCompanies = [];
  List<Map<String, dynamic>> rawPeriods = [];

  // 2. استخراج الأسماء فقط لعرضها في القوائم المنسدلة
  List<String> get governoratesNames => rawGovernorates.map((e) => e['name'].toString()).toList();
  List<String> get companiesNames => rawCompanies.map((e) => e['name'].toString()).toList();
  List<String> get periodsNames => rawPeriods.map((e) => e['name'].toString()).toList();

  // 3. دوال سحرية لجلب الآيدي الحقيقي عند البحث
  int get selectedFromId => rawGovernorates.firstWhere((e) => e['name'] == selectedFrom, orElse: () => {'governorateId': 0})['governorateId'] ?? 0;
  int get selectedToId => rawGovernorates.firstWhere((e) => e['name'] == selectedTo, orElse: () => {'governorateId': 0})['governorateId'] ?? 0;
  int get selectedCompanyId => rawCompanies.firstWhere((e) => e['name'] == selectedCompany, orElse: () => {'companyId': 0})['companyId'] ?? 0;
  int get selectedPeriodId => rawPeriods.firstWhere((e) => e['name'] == selectedTime, orElse: () => {'periodId': 0})['periodId'] ?? 0;

  // البيانات الأساسية للواجهة
  SearchCardModel? searchData;
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> companiesLogos = [];
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // الاختيارات الحالية للمستخدم
  String? selectedFrom;
  String? selectedTo;
  String? selectedCompany;
  String? selectedTime;
  DateTime selectedDate = DateTime.now();

  void updateSelectedFrom(String? val) { selectedFrom = val; notifyListeners(); }
  void updateSelectedTo(String? val) { selectedTo = val; notifyListeners(); }
  void updateSelectedCompany(String? val) { selectedCompany = val; notifyListeners(); }
  void updateSelectedTime(String? val) { selectedTime = val; notifyListeners(); }
  void updateSelectedDate(DateTime date) { selectedDate = date; notifyListeners(); }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ⚠️ تأكد من هذا المسار أنه هو الذي يرجع الـ JSON المجمع
      final response = await _dioClient.get('/Customer/home'); 

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> resData = response.data is Map ? response.data : {};
        
        if (resData.containsKey('data')) {
          final data = resData['data'];

          // 1. جلب الإعلانات
          if (data['adCards'] != null) {
            ads = List<Map<String, dynamic>>.from(data['adCards']);
          }

          // 2. جلب بيانات كرت البحث
          if (data['searchCard'] != null) {
            final searchCard = data['searchCard'];

            // قراءة المدن
            if (searchCard['governorates'] != null) {
              rawGovernorates = List<Map<String, dynamic>>.from(searchCard['governorates']);
            }

            // قراءة الشركات (وتحتوي على الشعار مباشرة)
            if (searchCard['companies'] != null) {
              rawCompanies = List<Map<String, dynamic>>.from(searchCard['companies']);
              companiesLogos = rawCompanies; // نستخدم نفس المصفوفة لعرض الشركات بالأسفل
            }

            // قراءة الفترات الزمنية (بالمسمى الجديد periodOptions)
            if (searchCard['periodOptions'] != null) {
              rawPeriods = List<Map<String, dynamic>>.from(searchCard['periodOptions']);
            }
          }

          // تعبئة كائن SearchCardModel كنصوص للـ Dropdown
          searchData = SearchCardModel(
            governorates: governoratesNames,
            companies: companiesNames,
            periods: periodsNames,
            ads: [], // لم نعد نحتاجها هنا لأننا فصلناها
            companyLogos: [], // لم نعد نحتاجها هنا
          );
        }
      }
    } catch (e) {
      debugPrint("خطأ في جلب بيانات السيرفر المجمعة: $e");
      // بيانات تجريبية للحماية من الكراش
      if (rawGovernorates.isEmpty) {
        searchData = SearchCardModel(
          governorates: ["صنعاء", "عدن", "تعز"],
          companies: ["شركة الرويشان", "شركة الأولى"],
          periods: ["صباحي", "مسائي"],
          ads: [],
          companyLogos: [],
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}