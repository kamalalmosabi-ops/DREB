import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../../data/models/trip_model.dart';

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class SearchResultsScreen extends StatefulWidget {
  // الأسماء (للعرض في واجهة المستخدم)
  final String fromCity;
  final String toCity;
  final String company;
  final String timePeriod;
  final DateTime travelDate;

  // الأرقام IDs (للإرسال إلى السيرفر للبحث)
  final int fromCityId;
  final int toCityId;
  final int companyId;
  final int periodId;

  const SearchResultsScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.company,
    required this.timePeriod,
    required this.travelDate,
    required this.fromCityId, // جديد
    required this.toCityId,   // جديد
    required this.companyId,  // جديد
    required this.periodId,   // جديد
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<String> selectedFilters = ['cheapest'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String formattedDate = "${widget.travelDate.year}-${widget.travelDate.month.toString().padLeft(2, '0')}-${widget.travelDate.day.toString().padLeft(2, '0')}";
      
      // ✅ تم التعديل هنا: إرسال الأرقام (IDs) للدالة بدلاً من النصوص
      context.read<TripProvider>().search(
        fromId: widget.fromCityId,
        toId: widget.toCityId,
        companyId: widget.companyId,
        periodId: widget.periodId,
        date: formattedDate,
      );
    });
  }

  List<Trip> _getProcessedTrips(List<Trip> remoteTrips, AppLocalizations loc) {
    List<Trip> filtered = remoteTrips.where((trip) {
      bool matchCompany = (widget.company == loc.translate('all_companies') || widget.company == "كل الشركات") || (trip.companyName == widget.company);
      bool matchPeriod = (widget.timePeriod == loc.translate('all') || widget.timePeriod == "الكل" || widget.timePeriod.isEmpty) || (trip.period == widget.timePeriod);
      return matchCompany && matchPeriod;
    }).toList();

    for (var filter in selectedFilters) {
      if (filter == 'cheapest') {
        filtered.sort((a, b) => a.price.compareTo(b.price));
      } else if (filter == 'highest_rated') {
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (filter == 'closest_time') {
        filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final displayedTrips = _getProcessedTrips(provider.trips, loc);

    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildModernHeader(context, loc, isAr),
            _buildHorizontalFilterBar(isDark, loc),
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE79C24)),
                      ),
                    )
                  : displayedTrips.isEmpty
                      ? _buildNoResults(loc)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemCount: displayedTrips.length,
                          itemBuilder: (context, index) =>
                              _buildProfessionalTripCard(context, displayedTrips[index], isDark, loc),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bus_alert_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            loc.translate('no_trips_available'),
            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('try_changing_search'),
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, AppLocalizations loc, bool isAr) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE79C24),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                loc.translate('search_results'),
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15), 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerLocationInfo(widget.fromCity, loc.translate('from')),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Icon(Icons.sync_alt_rounded, color: Colors.white.withValues(alpha: 0.9), size: 28), 
                ),
                _headerLocationInfo(widget.toCity, loc.translate('to')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLocationInfo(String city, String label) {
    return Column(
      children: [
        Text(city, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)), 
      ],
    );
  }

  Widget _buildHorizontalFilterBar(bool isDark, AppLocalizations loc) {
    return SizedBox(
      height: 65,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        children: [
          _buildFilterChip('cheapest', Icons.payments_outlined, isDark, loc),
          _buildFilterChip('closest_time', Icons.access_time_rounded, isDark, loc),
          _buildFilterChip('highest_rated', Icons.star_outline_rounded, isDark, loc),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, IconData icon, bool isDark, AppLocalizations loc) {
    bool isActive = selectedFilters.contains(filterKey);
    final activeBgColor = isDark ? const Color(0xFFE79C24) : const Color(0xFF0D1B3E);
    final inactiveBgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final inactiveBorderColor = isDark ? Colors.transparent : const Color(0xFFE5E7EB);
    final inactiveTextColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            selectedFilters.remove(filterKey);
          } else {
            selectedFilters.clear();
            selectedFilters.add(filterKey);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isActive ? Colors.transparent : inactiveBorderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: isActive ? Colors.white : inactiveTextColor),
            const SizedBox(width: 8),
            Text(
              loc.translate(filterKey), 
              style: TextStyle(
                color: isActive ? Colors.white : inactiveTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTripCard(BuildContext context, Trip trip, bool isDark, AppLocalizations loc) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

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
                _buildTimeNode(trip.departureTime, widget.fromCity, textColor),
                const Expanded(child: Icon(Icons.trending_flat, color: Colors.grey)),
                _buildTimeNode(trip.arrivalTime, widget.toCity, textColor),
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
                Text(loc.translate('trip_details'), style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_back_rounded, size: 16, color: textColor),
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
        Text(time, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 2),
        Text(city, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}