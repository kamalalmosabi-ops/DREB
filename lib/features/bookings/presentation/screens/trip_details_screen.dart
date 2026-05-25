import 'package:flutter/material.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart';  
import 'package:darb/features/bookings/presentation/screens/reservation_screen.dart';  

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
    const primaryColor = Color(0xFFE79C24);
    const darkBlue = Color(0xFF0D1B3E);
    
    int unitPrice = widget.trip.price;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        bottomNavigationBar: _buildStickyFooter(unitPrice, primaryColor, darkBlue),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(primaryColor, darkBlue),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("مخطط الرحلة ومحطات التوقف"),
                          _buildAdvancedTimeline(primaryColor),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle("سياسات الحجز والإلغاء"),
                          _buildBookingPolicies(primaryColor),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle("سياسة الأمتعة والمتاع"),
                          _buildBaggageInfo(),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle("مواصفات وتجهيزات الحافلة"),
                          _buildBusEssentials(darkBlue),
                          const SizedBox(height: 20),
                          
                          _buildSectionTitle("تحديد عدد المسافرين"),
                          _buildQuantitySelector(primaryColor),
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

  Widget _buildSliverHeader(Color primary, Color dark) {
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
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
                  "${widget.trip.fromCity} ⟵ ${widget.trip.toCity}", 
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

  Widget _buildAdvancedTimeline(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildTimelineItem(widget.trip.departureTime, widget.trip.fromCity, "محطة الانطلاق الرئيسية", true, primary),
          
          if (widget.trip.routes.isNotEmpty)
            ...widget.trip.routes.map((route) => _buildTimelineItem(
                  route.departureTime, 
                  route.stationName, 
                  "محطة توقف فرعية", 
                  true, 
                  primary.withValues(alpha: 0.7),
                )),
                
          _buildTimelineItem(widget.trip.arrivalTime.isNotEmpty ? widget.trip.arrivalTime : "وصول متوقع", widget.trip.toCity, "المحطة النهائية للوصول", false, Colors.green),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String loc, String sub, bool showLine, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Icon(Icons.radio_button_checked, color: color, size: 16),
            ),
            if (showLine) Container(width: 2, height: 40, color: Colors.grey[200]),
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
                    Text(loc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D1B3E))),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  Widget _buildBookingPolicies(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _policyRow(Icons.history_toggle_off, "التعديل والإلغاء:", "مسموح قبل موعد انطلاق الرحلة بـ 6 ساعات."),
          const SizedBox(height: 12),
          _policyRow(Icons.timer_outlined, "وقت الحضور:", "الرجاء التواجد بالمحطة قبل الإقلاع بـ 30 دقيقة."),
          const SizedBox(height: 12),
          _policyRow(Icons.business_center_outlined, "نقطة الإنزال:", "يتم الإنزال في فرع الشركة الرئيسي بالمدينة المحددة."),
          const SizedBox(height: 12),
          _policyRow(Icons.assignment_turned_in_outlined, "تأكيد التذكرة:", "يعتبر الحجز مؤكداً بشكل نهائي فور رفع سند الدفع الإلكتروني."),
        ],
      ),
    );
  }

  Widget _policyRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE79C24)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'Cairo'),
              children: [
                TextSpan(text: "$title ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaggageInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _IconText(Icons.luggage, "الوزن المشحون: 25 كجم متاح"),
          _IconText(Icons.shopping_bag, "حقيبة يد: 7 كجم داخل المقصورة"),
        ],
      ),
    );
  }

  Widget _buildBusEssentials(Color dark) {
    final List<Map<String, dynamic>> essentials = [
      {"icon": Icons.ac_unit, "label": "تكييف ممتاز"},
      {"icon": Icons.wifi, "label": "واي فاي"},
      {"icon": Icons.bolt, "label": "منفذ شحن"},
      {"icon": Icons.airline_seat_recline_normal, "label": "مقاعد مريحة"},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: essentials.map((item) => Column(
          children: [
            Icon(item['icon'], size: 24, color: dark),
            const SizedBox(height: 6),
            Text(item['label'], style: TextStyle(fontSize: 11, color: dark, fontWeight: FontWeight.bold)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildQuantitySelector(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Text("عدد المقاعد المطلوب حجزها", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D1B3E))),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => ticketCount > 1 ? ticketCount-- : null), 
            icon: const Icon(Icons.remove_circle_outline, size: 24, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("$ticketCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () {
              if (ticketCount < widget.trip.seatsLeft) {
                setState(() => ticketCount++);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("عذراً، لقد وصلت للحد الأقصى للمقاعد المتاحة")),
                );
              }
            }, 
            icon: Icon(Icons.add_circle, color: primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(int unitPrice, Color primary, Color dark) {
    return Container(
      height: 90, 
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("المبلغ الإجمالي للحجز", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
              Text("${unitPrice * ticketCount} ر.ي", style: TextStyle(color: dark, fontSize: 20, fontWeight: FontWeight.w900)),
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
                      route: "${widget.trip.fromCity} ⟵ ${widget.trip.toCity}",
                      companyName: widget.companyName,
                      departureTime: widget.trip.departureTime,
                      tripRouteId: widget.trip.id,      
                      // تم الاعتماد على معرف الرحلة مؤقتاً لتخطي مشكلة غياب حقل الشركة في كائن الرحلة
                      companyId: widget.trip.id,  
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dark, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("استمرار وتأكيد المقاعد", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, right: 4),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0D1B3E))),
  );
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconText(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE79C24)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.8))),
      ],
    );
  }
}