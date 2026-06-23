import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui; 
import 'package:darb/core/network/dio_client.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';
import 'package:darb/features/bookings/presentation/screens/trip_details_screen.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class SearchResultsScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String company;
  final DateTime? travelDate;
  final String timePeriod;
  final int fromCityId;
  final int toCityId;
  final int companyId;
  final int periodId;

  const SearchResultsScreen({
    super.key,
    required this.fromCity, required this.toCity, required this.company,
    this.travelDate, required this.timePeriod, required this.fromCityId,
    required this.toCityId, required this.companyId, required this.periodId,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool isLoading = true;
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    try {
      // بناء الـ Body الخاص بالـ API
      final Map<String, dynamic> requestData = {
        "fromGovernorateId": widget.fromCityId,
        "toGovernorateId": widget.toCityId,
        "companyId": widget.companyId,
        "periodId": widget.periodId,
      };

      // ✅ التعديل الأول: نرسل التاريخ فقط إذا اختاره المستخدم
      if (widget.travelDate != null) {
        // نستخدم علامة ! لتأكيد أن التاريخ ليس فارغاً هنا
        requestData["date"] = DateFormat('yyyy-MM-dd').format(widget.travelDate!); 
      }

      final response = await DioClient().post('/Customer/home/search', data: requestData);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          trips = data.map((json) => Trip.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE79C24),
          title: Text(loc.translate('search_results') ?? 'نتائج البحث', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
          : trips.isEmpty ? Center(child: Text(loc.translate('no_trips_found') ?? 'لا توجد رحلات مطابقة'))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: trips.length,
              itemBuilder: (context, index) => _buildTripCard(context, trips[index], isDark, loc, isAr),
            ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip, bool isDark, AppLocalizations loc, bool isAr) {
    final primaryColor = const Color(0xFFE79C24);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      backgroundImage: trip.companyLogo.isNotEmpty ? NetworkImage(trip.companyLogo) : null,
                      child: trip.companyLogo.isEmpty ? Icon(Icons.business, color: primaryColor) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(trip.companyName.isNotEmpty ? trip.companyName : widget.company, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text("${trip.price.toInt()} ${loc.translate('riyals') ?? 'ريال'}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('departure') ?? 'انطلاق', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(trip.fromCity, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded, color: Colors.grey[400]),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(loc.translate('arrival') ?? 'وصول', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(trip.toCity, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  // ✅ التعديل الثاني: التحقق من التاريخ قبل العرض
                  Text(
                    trip.departureTime.isNotEmpty 
                      ? trip.departureTime 
                      : (widget.travelDate != null ? DateFormat('yyyy-MM-dd').format(widget.travelDate!) : "كل الأيام"), 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.event_seat, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text("${trip.seatsLeft} مقعد", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripDetailsScreen(
                      trip: trip,
                      companyName: trip.companyName.isNotEmpty ? trip.companyName : widget.company,
                      rating: trip.rating,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('حجز الرحلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}