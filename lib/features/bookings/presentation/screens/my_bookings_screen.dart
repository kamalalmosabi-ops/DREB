import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/bookings/data/models/booking_service.dart'; 
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';
import 'package:darb/core/network/dio_client.dart'; 
import 'dart:ui' as ui show TextDirection;

// ============================================================================
// الشاشة الرئيسية لحجوزاتي
// ============================================================================
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
  int _selectedStatusId = 1; 

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    _statuses = await _service.getBookingStatuses();
    
    if (_statuses.isNotEmpty) {
      _selectedStatusId = _statuses.first['id'] ?? 1;
    }
    
    await _fetchBookings(_selectedStatusId);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchBookings(int statusId) async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getBookingsByStatus(statusId);
      if (mounted) {
        setState(() {
          _bookings = data;
          _selectedStatusId = statusId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookings = [];
          _selectedStatusId = statusId;
          _isLoading = false;
        });
      }
    }
  }

  // ✅ تم تحديث دالة الإلغاء لتقرأ رسائل الخطأ أو النجاح من السيرفر
  Future<void> _cancelBooking(int bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24))),
    );

    try {
      final response = await DioClient().put('/Customer/bookings/$bookingId/request-cancellation');
      Navigator.pop(context); 

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'تم إرسال طلب الإلغاء بنجاح'), 
            backgroundColor: Colors.green
          ),
        );
        _fetchBookings(_selectedStatusId);
      }
    } catch (e) {
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()), // طباعة رسالة السيرفر بوضوح
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmCancellation(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              _cancelBooking(bookingId); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('نعم، إلغاء الحجز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
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
                      ? Center(child: Text(loc.translate('no_bookings_available') ?? 'لا توجد حجوزات', style: TextStyle(color: subTextColor)))
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
          loc.translate('my_bookings') ?? 'حجوزاتي', 
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
    String currentStatusName = "غير معروف";
    try {
      currentStatusName = _statuses.firstWhere((s) => s['id'] == _selectedStatusId)['statusName'];
    } catch(e) {}

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
                      child: Text(trip['companyName'] ?? loc.translate('unknown_company') ?? 'شركة غير معروفة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    
                    if (_selectedStatusId == 2)
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TicketQrScreen(bookingData: trip)));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: const [
                              Icon(Icons.qr_code_2, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text("عرض التذكرة", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    else
                      _statusChip(currentStatusName, _selectedStatusId),
                  ],
                ),
                const Divider(height: 30, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _locationCol(trip['startGovernorate'] ?? "---", "انطلاق", textColor, subTextColor)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.swap_horiz, color: Colors.grey, size: 24),
                    ),
                    Expanded(child: _locationCol(trip['endGovernorate'] ?? "---", "وصول", textColor, subTextColor)),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFE79C24).withValues(alpha: 0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${trip['totalAmount'] ?? 0} ${loc.translate('riyals') ?? 'ريال'}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE79C24), fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ التعديل هنا: يظهر زر الإلغاء فقط في حالة "مؤكد" (Status = 2) ولن يظهر في حالة "الانتظار" (Status = 1)
                    if (_selectedStatusId == 2) ...[
                      TextButton(
                        onPressed: () => _confirmCancellation(trip['bookingId']),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('إلغاء الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 5),
                    ],
                    
                    ElevatedButton(
                      onPressed: () {
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(loc.translate('details') ?? 'التفاصيل', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, int statusId) {
    Color chipColor = statusId == 3 || statusId == 5 ? Colors.red : const Color(0xFFE79C24);
    if(statusId == 4) chipColor = Colors.green; 
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: chipColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(color: chipColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
// شاشة تفاصيل الحجز 
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
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Text(loc.translate('booking_details') ?? 'تفاصيل الحجز', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        bookingData['companyName'] ?? loc.translate('unknown_company') ?? 'شركة غير معروفة',
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
                    _buildDetailRow('المبلغ الإجمالي', "${bookingData['totalAmount'] ?? 0} ${loc.translate('riyals') ?? 'ريال'}", textColor, primaryColor, isBold: true),
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

// ============================================================================
// شاشة الـ QR Code 
// ============================================================================
class TicketQrScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const TicketQrScreen({super.key, required this.bookingData});

  @override
  State<TicketQrScreen> createState() => _TicketQrScreenState();
}

class _TicketQrScreenState extends State<TicketQrScreen> {
  String? base64QrImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    try {
      final bookingId = widget.bookingData['bookingId'];
      final response = await DioClient().get('/Customer/bookings/$bookingId/details');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (mounted) {
          setState(() {
            base64QrImage = data['ticketCode']; 
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching ticket details: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isAr = settings.locale.languageCode == 'ar';
    final isDark = settings.isDark;
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE79C24); 
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final primaryColor = const Color(0xFFE79C24);

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('تذكرة الصعود', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('يرجى إبراز هذا الرمز للموظف', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 35),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text('رقم الحجز', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('#${widget.bookingData['bookingId']}', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(thickness: 1, color: Colors.grey)),
                      
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                        ),
                        child: isLoading 
                          ? const SizedBox(
                              width: 180.0, height: 180.0,
                              child: Center(child: CircularProgressIndicator(color: Color(0xFFE79C24))),
                            )
                          : (base64QrImage != null && base64QrImage!.isNotEmpty)
                              ? Image.memory(
                                  base64Decode(base64QrImage!),
                                  width: 180.0,
                                  height: 180.0,
                                  fit: BoxFit.contain,
                                )
                              : const SizedBox(
                                  width: 180.0, height: 180.0,
                                  child: Center(child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey)),
                                ),
                      ),
                      
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildMiniDetail('المبلغ', '${widget.bookingData['totalAmount']} ${loc.translate('riyals') ?? 'ريال'}', textColor, primaryColor)),
                          Expanded(child: _buildMiniDetail('الشركة', widget.bookingData['companyName'] ?? '---', textColor, textColor, alignRight: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniDetail(String title, String val, Color tColor, Color vColor, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        Text(val, style: TextStyle(color: vColor, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}