import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:darb/core/network/dio_client.dart';

class HomeProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  // البيانات القادمة من السيرفر
  SearchCardModel? searchData;
  List<dynamic> ads = [];
  List<dynamic> companiesLogos = [];
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- حقول حالة الشاشة والاختيارات الحالية ---
  String? selectedFrom;
  String? selectedTo;
  String? selectedCompany;
  String? selectedTime;
  DateTime selectedDate = DateTime.now();

  // دوال لتحديث الاختيارات
  void updateSelectedFrom(String? val) {
    selectedFrom = val;
    notifyListeners();
  }

  void updateSelectedTo(String? val) {
    selectedTo = val;
    notifyListeners();
  }

  void updateSelectedCompany(String? val) {
    selectedCompany = val;
    notifyListeners();
  }

  void updateSelectedTime(String? val) {
    selectedTime = val;
    notifyListeners();
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // جلب البيانات مع دعم بيانات تجريبية إذا كان السيرفر غير جاهز
  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // تم تصحيح المسارات بحذف "/api" لأنها مضافة مسبقاً في الـ BaseUrl الخاص بالـ DioClient
      final searchResponse = await _dioClient.get('/Customer/home/search/card');
      final adsResponse = await _dioClient.get('/Customer/home/ads');
      final companiesResponse = await _dioClient.get('/Customer/home/companies/avatar');

      // معالجة وحماية بيانات كرت البحث
      if (searchResponse.statusCode == 200 && searchResponse.data != null) {
        final resData = searchResponse.data;
        if (resData is Map<String, dynamic>) {
          // فحص ذكي: إذا كانت البيانات مغلفة داخل كائن 'data' قادم من السيرفر
          if (resData.containsKey('data') && resData['data'] is Map<String, dynamic>) {
            searchData = SearchCardModel.fromJson(resData['data']);
          } else {
            searchData = SearchCardModel.fromJson(resData);
          }
        }
      }
      
      // معالجة بيانات الإعلانات
      if (adsResponse.statusCode == 200 && adsResponse.data != null) {
        final resAds = adsResponse.data;
        if (resAds is List) {
          ads = resAds;
        } else if (resAds is Map && resAds.containsKey('data') && resAds['data'] is List) {
          ads = resAds['data'];
        }
      }
      
      // معالجة شعارات الشركات
      if (companiesResponse.statusCode == 200 && companiesResponse.data != null) {
        final resCompanies = companiesResponse.data;
        if (resCompanies is List) {
          companiesLogos = resCompanies;
        } else if (resCompanies is Map && resCompanies.containsKey('data') && resCompanies['data'] is List) {
          companiesLogos = resCompanies['data'];
        }
      }

    } catch (e) {
      debugPrint("خطأ في جلب بيانات السيرفر الحقيقية: $e");
    } finally {
      // --- بيانات تجريبية (Mock Data) احتياطية لكي لا تقف الشاشة أبداً في حال تعطل السيرفر ---
      searchData ??= SearchCardModel(
        governorates: ["صنعاء", "عدن", "تعز", "إب", "حضرموت", "الحديدة"],
        companies: ["شركة الرويشان", "شركة الأولى", "شركة الراحة", "شركة البراق"],
        periods: ["صباحاً (08:00 ص)", "عصراً (04:00 م)", "مساءً (09:00 م)"],
        ads: [],
        companyLogos: [],
      );
      
      _isLoading = false;
      notifyListeners();
    }
  }
}