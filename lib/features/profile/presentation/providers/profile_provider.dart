import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // أو dio
import 'dart:convert';
import 'package:darb/features/profile/data/models/user_profile_model.dart';  

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // استبدل الرابط برابط السيرفر الحقيقي الخاص بك
      final response = await http.get(Uri.parse('https://your-api-url.com/api/Customer/settings/profile'));

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(json.decode(response.body));
      } else {
        _error = "فشل تحميل البيانات";
      }
    } catch (e) {
      _error = "حدث خطأ في الاتصال";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}