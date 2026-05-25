import 'package:flutter/material.dart';
import 'package:darb/features/bookings/data/models/booking_service.dart'; 

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _service = BookingService();
  
  List<dynamic> _statuses = []; // لتخزين الحالات القادمة من API
  List<dynamic> _bookings = []; // لتخزين الحجوزات
  bool _isLoading = true;
  int _selectedStatusId = 0; // الحالة الافتراضية

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    // جلب الحالات أولاً
    _statuses = await _service.getBookingStatuses();
    // جلب الحجوزات (افتراضياً الكل أو أول حالة)
    await _fetchBookings(_selectedStatusId);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchBookings(int statusId) async {
    setState(() => _isLoading = true);
    final data = await _service.getBookingsByStatus(statusId);
    setState(() {
      _bookings = data;
      _selectedStatusId = statusId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        body: Column(
          children: [
            _buildModernHeader(),
            _buildHorizontalFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 30),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) => _buildBookingTicket(_bookings[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 15, right: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFE79C24),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: const Center(
        child: Text(
          "حجوزاتي", 
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildHorizontalFilterBar() {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          var status = _statuses[index];
          int id = status['id']; // تأكد من اسم الحقل حسب الـ JSON
          String name = status['name'];
          bool isActive = _selectedStatusId == id;
          
          return GestureDetector(
            onTap: () => _fetchBookings(id),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF0D1B3E) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Text(name, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF0D1B3E), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingTicket(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0D1B3E).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trip['companyName'] ?? "غير معروف", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    _statusChip(trip['statusName'] ?? "---", const Color(0xFFE79C24)), 
                  ],
                ),
                const Divider(height: 30, color: Color(0xFFF3F4F6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _locationCol(trip['fromStation'] ?? "", trip['travelTime'] ?? ""),
                    const Icon(Icons.swap_horiz, color: Color(0xFFCBD5E1), size: 24),
                    _locationCol(trip['toStation'] ?? "", trip['travelDate'] ?? ""),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${trip['price'] ?? 0} ريال", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE79C24))),
                ElevatedButton(
                  onPressed: () {
                     // انتقل لصفحة التفاصيل ومرر الـ ID
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("عرض التفاصيل"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF0D1B3E).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _locationCol(String city, String sub) {
    return Column(
      children: [
        Text(city, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
        Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("لا توجد سجلات حالياً"));
  }
}