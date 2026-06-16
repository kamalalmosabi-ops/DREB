import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';  
import 'package:darb/features/bookings/presentation/screens/reservation_screen.dart';  

// استيراد الترجمة والدارك مود
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  final String companyName;
  final double rating;

  const TripDetailsScreen({
    super.key,
    required this.trip,
    required this.companyName,
    required this.rating,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int ticketCount = 1;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    const primaryColor = Color(0xFFE79C24);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    // ✅ تم تحويل السعر إلى int لتجنب تعارض أنواع البيانات
    int unitPrice = widget.trip.price.toInt();

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        bottomNavigationBar: _buildStickyFooter(unitPrice, primaryColor, textColor, cardColor, subTextColor, loc, isAr),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(primaryColor, isAr),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(loc.translate('trip_itinerary_and_stops'), textColor),
                          _buildAdvancedTimeline(primaryColor, cardColor, textColor, subTextColor, loc),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle(loc.translate('booking_cancellation_policies'), textColor),
                          _buildBookingPolicies(primaryColor, cardColor, textColor, subTextColor, loc),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle(loc.translate('baggage_policy'), textColor),
                          _buildBaggageInfo(cardColor, textColor, loc),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle(loc.translate('bus_specifications_equipments'), textColor),
                          _buildBusEssentials(textColor, cardColor, loc),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle(loc.translate('select_passengers_count'), textColor),
                          _buildQuantitySelector(primaryColor, cardColor, textColor, loc),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(Color primary, bool isAr) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          child: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  "${widget.trip.fromCity} ${isAr ? '⟵' : '⟶'} ${widget.trip.toCity}", 
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.companyName, 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    Text(" ${widget.rating}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedTimeline(Color primary, Color cardColor, Color textColor, Color subTextColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // ✅ محطة الانطلاق الرئيسية
          _buildTimelineItem(widget.trip.departureTime, widget.trip.fromCity, loc.translate('main_departure_station'), true, primary, textColor, subTextColor),
          
          // ✅ محطة الوصول النهائية (تم تنظيف الحقل المعطوب هنا)
          _buildTimelineItem(widget.trip.arrivalTime.isNotEmpty ? widget.trip.arrivalTime : loc.translate('expected_arrival'), widget.trip.toCity, loc.translate('final_arrival_station'), false, Colors.green, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String city, String sub, bool showLine, Color color, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Icon(Icons.radio_button_checked, color: color, size: 16),
            ),
            if (showLine) Container(width: 2, height: 40, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(height: 2),
                    Text(sub, style: TextStyle(color: subTextColor, fontSize: 12)),
                  ],
                ),
                Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingPolicies(Color primary, Color cardColor, Color textColor, Color subTextColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _policyRow(Icons.history_toggle_off, loc.translate('modification_cancellation'), loc.translate('allowed_6_hours_before'), textColor, subTextColor),
          const SizedBox(height: 12),
          _policyRow(Icons.timer_outlined, loc.translate('attendance_time'), loc.translate('be_at_station_30_mins_before'), textColor, subTextColor),
          const SizedBox(height: 12),
          _policyRow(Icons.business_center_outlined, loc.translate('drop_off_point'), loc.translate('drop_off_main_branch'), textColor, subTextColor),
          const SizedBox(height: 12),
          _policyRow(Icons.assignment_turned_in_outlined, loc.translate('ticket_confirmation'), loc.translate('booking_confirmed_after_receipt'), textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _policyRow(IconData icon, String title, String desc, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE79C24)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: subTextColor, fontFamily: 'Tajawal'),
              children: [
                TextSpan(text: "$title ", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaggageInfo(Color cardColor, Color textColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(child: _IconText(Icons.luggage, loc.translate('checked_baggage_25kg'), textColor)),
          const SizedBox(width: 10),
          Expanded(child: _IconText(Icons.shopping_bag, loc.translate('hand_baggage_7kg'), textColor)),
        ],
      ),
    );
  }

  Widget _buildBusEssentials(Color textColor, Color cardColor, AppLocalizations loc) {
    final List<Map<String, dynamic>> essentials = [
      {"icon": Icons.ac_unit, "label": loc.translate('excellent_ac')},
      {"icon": Icons.wifi, "label": loc.translate('wifi')},
      {"icon": Icons.bolt, "label": loc.translate('charging_port')},
      {"icon": Icons.airline_seat_recline_normal, "label": loc.translate('comfortable_seats')},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: essentials.map((item) => Column(
          children: [
            Icon(item['icon'], size: 24, color: textColor),
            const SizedBox(height: 6),
            Text(item['label'], style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.bold)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildQuantitySelector(Color primary, Color cardColor, Color textColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loc.translate('seats_to_book'), 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => ticketCount > 1 ? ticketCount-- : null), 
            icon: const Icon(Icons.remove_circle_outline, size: 24, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("$ticketCount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ),
          IconButton(
            onPressed: () {
              if (ticketCount < widget.trip.seatsLeft) {
                setState(() => ticketCount++);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.translate('max_seats_reached'))),
                );
              }
            }, 
            icon: Icon(Icons.add_circle, color: primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(int unitPrice, Color primary, Color textColor, Color cardColor, Color subTextColor, AppLocalizations loc, bool isAr) {
    return Container(
      height: 90, 
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('total_booking_amount'), style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
              Text("${unitPrice * ticketCount} ${loc.translate('yer')}", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationScreen(
                      ticketCount: ticketCount,
                      unitPrice: unitPrice,
                      route: "${widget.trip.fromCity} ${isAr ? '⟵' : '⟶'} ${widget.trip.toCity}",
                      companyName: widget.companyName,
                      departureTime: widget.trip.departureTime,
                      // ✅ تم استخدام التسمية الصحيحة المحدثة بموديل السيرفر الجديد tripId
                      tripRouteId: widget.trip.tripId,      
                      companyId: widget.trip.companyId,  
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor, 
                foregroundColor: cardColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(loc.translate('continue_confirm_seats'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) => Padding(
    padding: const EdgeInsets.only(bottom: 10, right: 4, left: 4),
    child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textColor)),
  );
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  const _IconText(this.icon, this.text, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE79C24)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text, 
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.8)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}