import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/bookings/data/models/booking_service.dart'; 

// استيراد الترجمة ومدير الإعدادات
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _service = BookingService();
  List<dynamic> _statuses = []; 
  List<dynamic> _bookings = []; 
  bool _isLoading = true;
  int _selectedStatusId = 0; 

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    _statuses = await _service.getBookingStatuses();
    // جلب الحجوزات للحالة رقم 1 (أو حسب ما تختاره)
    await _fetchBookings(_selectedStatusId);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchBookings(int statusId) async {
    setState(() => _isLoading = true);
    final data = await _service.getBookingsByStatus(statusId);
    if (mounted) {
      setState(() {
        _bookings = data;
        _selectedStatusId = statusId;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildModernHeader(textColor, loc),
            _buildHorizontalFilterBar(textColor, isDark, isAr),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
                  : _bookings.isEmpty
                      ? Center(child: Text(loc.translate('no_bookings_available'), style: TextStyle(color: subTextColor)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 30),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) => _buildBookingTicket(_bookings[index], textColor, cardColor, subTextColor, loc),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(Color textColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 15, right: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFE79C24),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: Text(
          loc.translate('my_bookings'), 
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildHorizontalFilterBar(Color textColor, bool isDark, bool isAr) {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          var status = _statuses[index];
          int id = status['id'] ?? 0; 
          String name = status['statusName'] ?? 'غير معروف';
          bool isActive = _selectedStatusId == id;
          
          return GestureDetector(
            onTap: () => _fetchBookings(id),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE79C24) : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Text(name, style: TextStyle(color: isActive ? Colors.white : textColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingTicket(Map<String, dynamic> trip, Color textColor, Color cardColor, Color subTextColor, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
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
                    Expanded(
                      // ✅ قراءة اسم الشركة الحقيقي
                      child: Text(trip['companyName'] ?? loc.translate('unknown_company'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    // رقم الحجز كبديل عن حالة الحجز لأن الـ API هنا لا يعيد حالة نصية
                    _statusChip("#${trip['bookingId'] ?? '---'}"), 
                  ],
                ),
                const Divider(height: 30, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ ربط المدن بالبيانات الحقيقية (startGovernorate)
                    Expanded(child: _locationCol(trip['startGovernorate'] ?? "---", "انطلاق", textColor, subTextColor)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.swap_horiz, color: Colors.grey, size: 24),
                    ),
                    // ✅ ربط المدن بالبيانات الحقيقية (endGovernorate)
                    Expanded(child: _locationCol(trip['endGovernorate'] ?? "---", "وصول", textColor, subTextColor)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFE79C24).withValues(alpha: 0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ ربط السعر الحقيقي (totalAmount)
                Text("${trip['totalAmount'] ?? 0} ${loc.translate('riyals')}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE79C24))),
                ElevatedButton(
                  onPressed: () {
                    // الانتقال لشاشة التفاصيل التي برمجناها بالأسفل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsScreen(bookingData: trip),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(loc.translate('details')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFE79C24).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Color(0xFFE79C24), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _locationCol(String city, String sub, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(city, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
        Text(sub, style: TextStyle(fontSize: 12, color: subTextColor), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ============================================================================
// شاشة تفاصيل الحجز (مدمجة هنا لتجنب أي أخطاء استيراد)
// ============================================================================
class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final primaryColor = const Color(0xFFE79C24);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Text(loc.translate('booking_details'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        bookingData['companyName'] ?? 'شركة النقل',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('رقم الحجز', "#${bookingData['bookingId'] ?? '---'}", textColor, primaryColor),
                    const Divider(height: 30),
                    _buildDetailRow('محطة الانطلاق', bookingData['startGovernorate'] ?? '---', textColor, textColor),
                    const SizedBox(height: 10),
                    _buildDetailRow('محطة الوصول', bookingData['endGovernorate'] ?? '---', textColor, textColor),
                    const Divider(height: 30),
                    _buildDetailRow('المبلغ الإجمالي', "${bookingData['totalAmount'] ?? 0} ${loc.translate('riyals')}", textColor, primaryColor, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, Color titleColor, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            color: valueColor, 
            fontSize: isBold ? 18 : 15, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600
          ),
        ),
      ],
    );
  }
}