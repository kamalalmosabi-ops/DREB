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

  // --- دالة تسجيل الدخول (المعدلة والآمنة) ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _dioClient.post(
        '/Auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // حماية ضد مشكلة نوع البيانات (التأكد من أنها Map وليست String)
        if (response.data is Map) {
          var dataObj = response.data['data'];
          if (dataObj != null) {
            await _handleSuccessfulAuth(dataObj);
            return true;
          }
        }
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
    
    debugPrint("🚀 [إرسال البيانات] الايميل: $email | الجوال: $phone | الهوية: $nationalId");

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
      
      debugPrint("✅ [رد السيرفر] الكود: ${response.statusCode} | البيانات: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
            await _handleSuccessfulAuth(response.data['data']);
        } else {
            _setLoading(false);
        }
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint("❌ [خطأ في السيرفر] التفاصيل: $e");
      _setExceptionError(e);
      return false;
    }
  }

  // --- دالة معالجة الدخول وحفظ التوكن (المعدلة والآمنة) ---
  Future<void> _handleSuccessfulAuth(dynamic userData) async {
    try {
      String? token;

      // استخراج التوكن بأمان أولاً
      if (userData is Map) {
        token = userData['token'];
      }

      // حفظ التوكن فوراً في DioClient و SharedPreferences
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _dioClient.setToken(token); 
        debugPrint("✅ تم التقاط التوكن وحفظه بنجاح!");
      }

      // محاولة تحويل البيانات إلى UserModel داخل Try-Catch لتجنب الكراش
      try {
        _currentUser = UserModel.fromJson(userData);
      } catch (e) {
        debugPrint("⚠️ تحذير: UserModel.fromJson لم يجد كل الحقول. الخطأ: $e");
      }

    } catch (e) {
      debugPrint("❌ خطأ غير متوقع في معالجة الدخول: $e");
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