import 'package:flutter/material.dart';
import 'package:darb/core/network/dio_client.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class TripStationsScreen extends StatelessWidget {
  final Trip trip;

  const TripStationsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDark;
    final primaryColor = const Color(0xFFE79C24);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('مسار الرحلة'),
        backgroundColor: primaryColor,
      ),
      body: FutureBuilder(
        // الرابط الصحيح حسب ما ظهر في الـ API الخاص بك
        future: DioClient().get('/Customer/trip/stations/${trip.tripId}'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('حدث خطأ في تحميل المسار'));
          }

          final response = snapshot.data as Map<String, dynamic>;
          List<TripStation> stations = [];
          if (response['success'] == true && response['data'] != null) {
            stations = (response['data'] as List).map((e) => TripStation.fromJson(e)).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              final isLast = index == stations.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline UI
                  Column(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                      if (!isLast) Container(width: 2, height: 60, color: primaryColor.withValues(alpha: 0.3)),
                    ],
                  ),
                  const SizedBox(width: 15),
                  // Station Details
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(station.cityName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                          const SizedBox(height: 5),
                          Text(station.address, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 5),
                          Text("وقت الانطلاق: ${station.departureTime} | السعر: ${station.seatFare.toInt()} ريال", 
                               style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}