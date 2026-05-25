import 'package:darb/core/network/dio_client.dart';
import 'company_model.dart';
import 'trip_model.dart';

class CompanyApiService {
  final DioClient _dioClient = DioClient();

  // 1. جلب قائمة الشركات بالكامل
  Future<List<Company>> getAllCompanies() async {
    try {
      // تم توحيد الرابط ليكون مطابقاً لما يقبله السيرفر ويعطي statusCode 200
      final response = await _dioClient.get('/Customer/home/companies/avatar');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Company.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('فشل جلب الشركات: $e');
    }
  }

  // 2. جلب رحلات شركة معينة بناءً على الـ ID
  Future<List<Trip>> getCompanyTrips(int companyId) async {
    try {
      // 🟢 تصحيح رابط جلب الرحلات ليتوافق مع الـ Controller الخاص بالشركات في السيرفر
      final response = await _dioClient.get('/Company/trips', queryParameters: {
        'companyId': companyId,
      });

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Trip.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('فشل جلب رحلات الشركة: $e');
    }
  }
}