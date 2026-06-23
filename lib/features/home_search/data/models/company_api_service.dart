import 'package:darb/core/network/dio_client.dart';
import '../models/company_model.dart';
import '../models/trip_model.dart';

class CompanyApiService {
  final DioClient _dioClient = DioClient();

  Future<List<Company>> getAllCompanies() async {
    try {
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

  // ✅ استخدام مسار البحث المسموح للعملاء لحل خطأ 403
  Future<List<Trip>> getCompanyTrips(int companyId) async {
    try {
      final response = await _dioClient.post(
        '/Customer/home/search',
        data: {
          "fromGovernorateId": 0,
          "toGovernorateId": 0,
          "companyId": companyId,
          "periodId": 0,
          "date": null,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final decodedData = response.data;
        if (decodedData is Map && decodedData.containsKey('data')) {
          List dataList = decodedData['data'];
          return dataList.map((item) => Trip.fromJson(item)).toList();
        } else if (decodedData is List) {
          return decodedData.map((item) => Trip.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("🛠️ Error in getCompanyTrips: $e");
      return [];
    }
  }
}