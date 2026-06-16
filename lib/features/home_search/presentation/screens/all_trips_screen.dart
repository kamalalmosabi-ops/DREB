import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../../data/models/trip_model.dart';
import 'package:darb/features/bookings/presentation/screens/trip_details_screen.dart';

// استيراد الترجمة والدارك مود
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  
 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ تم تغيير الاستدعاء للدالة الجديدة التي تجلب جميع الرحلات
      context.read<TripProvider>().fetchAllTrips(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    const primaryColor = Color(0xFFE79C24);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildModernHeader(loc, isAr, primaryColor),
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : provider.trips.isEmpty
                      ? _buildNoResults(loc, textColor)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 30),
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.trips.length,
                          itemBuilder: (context, index) =>
                              _buildProfessionalTripCard(context, provider.trips[index], isDark, loc, cardColor, textColor, isAr),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(AppLocalizations loc, bool isAr, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                loc.translate('explore_all_trips'),
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 48), // لموازنة الأيقونة
            ],
          ),
          const SizedBox(height: 15),
          Text(
            loc.translate('all_available_trips'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations loc, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bus_alert_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            loc.translate('no_trips_available'),
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTripCard(BuildContext context, Trip trip, bool isDark, AppLocalizations loc, Color cardColor, Color textColor, bool isAr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(15)),
                  child: Icon(Icons.directions_bus_filled, color: isDark ? Colors.white : const Color(0xFF0D1B3E), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.companyName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                          const SizedBox(width: 4),
                          Text("${trip.rating}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                          Text(" (${trip.reviewsCount} ${loc.translate('rating_word')})", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${trip.price}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFE79C24))),
                    Text(loc.translate('yemeni_riyal'), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.grey, thickness: 0.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeNode(trip.departureTime, trip.fromCity, textColor),
                Expanded(child: Icon(isAr ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded, color: Colors.grey)),
                _buildTimeNode(trip.arrivalTime.isNotEmpty ? trip.arrivalTime : loc.translate('expected_arrival'), trip.toCity, textColor),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "${loc.translate('seats_left_count')} ${trip.seatsLeft} ${loc.translate('seats')}",
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(
                          trip: trip,
                          companyName: trip.companyName,
                          rating: trip.rating,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(loc.translate('trip_details'), style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded, size: 16, color: textColor),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeNode(String time, String city, Color textColor) {
    return Column(
      children: [
        Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 2),
        Text(city, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}