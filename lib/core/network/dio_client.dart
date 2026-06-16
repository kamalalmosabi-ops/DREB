import 'package:dio/dio.dart';

class DioClient {
  // 1. إنشاء نسخة واحدة مشتركة (Singleton) للتطبيق بالكامل
  static final DioClient _instance = DioClient._internal();

  // 2. Factory يُرجع نفس النسخة دائماً عند استدعاء DioClient()
  factory DioClient() {
    return _instance;
  }

  final Dio _dio;

  // الوصول المباشر لكائن Dio
  Dio get dio => _dio;

  static const String baseUrl = "https://server-darb.runasp.net/api"; 

  // 3. المنشئ الداخلي الذي يتم استدعاؤه مرة واحدة فقط
  DioClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 13),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // إضافة الـ Interceptor لطباعة الطلبات
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // دالة لتحديث التوكين في الهيدرز (تُستخدم بعد تسجيل الدخول)
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // دالة لمسح التوكين (تُستخدم عند تسجيل الخروج)
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // 1. دالة جلب البيانات الموحدة (GET Request)
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 2. دالة إرسال البيانات الموحدة (POST Request)
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 3. نظام معالجة الأخطاء الذكي
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "انتهت مهلة الاتصال بالسيرفر، يرجى التحقق من جودة الإنترنت.";
      case DioExceptionType.receiveTimeout:
        return "السيرفر استغرق وقتاً طويلاً في الاستجابة.";
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'];
        // تحسين عرض الخطأ لتسهيل التتبع
        if (statusCode == 401) return "غير مصرح لك (401). يرجى التأكد من تسجيل الدخول.";
        return message ?? "حدث خطأ في السيرفر: كود $statusCode";
      case DioExceptionType.connectionError:
        return "فشل الاتصال بالسيرفر، يرجى التأكد من شبكة الإنترنت لديك.";
      default:
        return "حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى لاحقاً.";
    }
  }
}