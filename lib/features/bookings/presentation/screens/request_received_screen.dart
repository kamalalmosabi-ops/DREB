import 'package:flutter/material.dart';
import 'my_bookings_screen.dart';

class BookingSuccessData {
  final int bookingId;
  final int ticketCount;
  final int totalAmount;
  final String status;

  BookingSuccessData({
    required this.bookingId,
    required this.ticketCount,
    required this.totalAmount,
    this.status = "قيد الانتظار",
  });
}

class RequestReceivedScreen extends StatelessWidget {
  final BookingSuccessData bookingData;

  const RequestReceivedScreen({
    super.key,
    required this.bookingData,
  });

  final Color primaryGold = const Color(0xFFE79C24);
  final Color darkNavy = const Color(0xFF0D1B3E);
  final Color lightGrey = const Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightGrey,
        body: Stack(
          children: [
            _buildBackgroundHeader(context),
            Column(
              children: [
                const SizedBox(height: 70),
                _buildStatusCircle(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      _buildMainMessage(),
                      const SizedBox(height: 25),
                      _buildOrderDetailsCard(),
                      const SizedBox(height: 20),
                      _buildNextStepsCard(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomSheet: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildBackgroundHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: primaryGold,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
    );
  }

  Widget _buildStatusCircle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Icon(Icons.hourglass_empty_rounded, color: primaryGold, size: 50),
    );
  }

  Widget _buildMainMessage() {
    return Column(
      children: [
        const Text("تم إرسال طلبك بنجاح!",
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("طلبك الآن في مرحلة التدقيق الفني من قبل الشركة",
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
      ],
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)
          ]),
      child: Column(
        children: [
          _buildDataRow("رقم الحجز الفني", "#${bookingData.bookingId}", isTitle: true),
          const Divider(height: 30),
          _buildDataRow("عدد المسافرين", "${bookingData.ticketCount} مسافرين"),
          const SizedBox(height: 15),
          _buildDataRow("المبلغ الإجمالي", "${bookingData.totalAmount} ر.ي"),
          const SizedBox(height: 15),
          _buildDataRow("حالة الحجز الحالية", bookingData.status, color: primaryGold),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: darkNavy, borderRadius: BorderRadius.circular(25)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white70, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "سيقوم موظف شركة النقل بمطابقة السند المرفق بالتحويل الفعلي، وستصدر تذكرتك النهائية متضمنة الـ QR Code في قسم حجوزاتي فور الاعتماد.",
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {bool isTitle = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color ?? (isTitle ? primaryGold : darkNavy),
                fontWeight: FontWeight.bold,
                fontSize: isTitle ? 18 : 14)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      color: lightGrey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // تم تعديل الاستدعاء هنا وحذف المتغير المسبب للخطأ
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBookingsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: const Text("الانتقال إلى حجوزاتي",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("العودة للرئيسية",
                style:
                    TextStyle(color: darkNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}