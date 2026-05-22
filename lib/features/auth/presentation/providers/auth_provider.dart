import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- دالة تسجيل الدخول ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _dioClient.post(
        '/Auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleSuccessfulAuth(response.data['data']);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setExceptionError(e);
      return false;
    }
  }

  // --- دالة تسجيل مستخدم جديد ---
  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String nationalId,
    required String address,
    required String dateOfBirth,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _dioClient.post(
        '/Auth/register/customers',
        data: {
          'fullName': name,
          'email': email,
          'phone': phone,
          'password': password,
          'nationalId': nationalId,
          'address': address,
          "dateOfBirth": dateOfBirth, 
        },
      );
      
      // بعد التسجيل الناجح، غالباً السيرفر يعيد بيانات المستخدم مع التوكن
      if (response.statusCode == 200 || response.statusCode == 201) {
        // إذا كان السيرفر يعيد بيانات المستخدم في الـ body بعد التسجيل:
        if (response.data['data'] != null) {
            _handleSuccessfulAuth(response.data['data']);
        } else {
            _setLoading(false);
        }
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setExceptionError(e);
      return false;
    }
  }

  // دالة مساعدة لتخزين بيانات المستخدم والتوكن
  Future<void> _handleSuccessfulAuth(dynamic userData) async {
    _currentUser = UserModel.fromJson(userData);
    if (_currentUser?.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _currentUser!.token!);
      _dioClient.setToken(_currentUser!.token!);
    }
    _setLoading(false);
    notifyListeners();
  }

  // --- دوال التسجيل (OTP) ---
  Future<bool> sendRegistrationOTP(String email) async {
    _setLoading(true);
    try {
      final response = await _dioClient.post('/Auth/send-registration-otp', data: {'email': email});
      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) { _setExceptionError(e); return false; }
  }

  Future<bool> verifyRegistrationOTP(String email, String otp) async {
    _setLoading(true);
    try {
      final response = await _dioClient.post('/Auth/verify-registration-otp', data: {'email': email, 'otpCode': otp});
      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) { _setExceptionError(e); return false; }
  }

  // --- دوال "نسيت كلمة المرور" ---
  Future<bool> sendForgotPasswordOTP(String email) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _dioClient.post('/Auth/forget-password', data: {'email': email});
      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) { _setExceptionError(e); return false; }
  }

  Future<bool> resetPassword(String email, String newPassword, String otp) async {
    _setLoading(true);
    try {
      final response = await _dioClient.post('/Auth/reset-password', data: {
        'email': email, 
        'otpCode': otp, 
        'newPassword': newPassword
      });
      _setLoading(false);
      return response.statusCode == 200;
    } catch (e) { 
      _setExceptionError(e); 
      return false; 
    }
  }

  // --- دوال المساعدة ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setExceptionError(dynamic error) {
    _errorMessage = error.toString();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _dioClient.dio.options.headers.remove('Authorization');
    notifyListeners();
  }
}