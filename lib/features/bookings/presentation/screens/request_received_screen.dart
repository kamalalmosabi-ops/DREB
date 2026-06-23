import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';
import 'package:darb/features/bookings/presentation/screens/my_bookings_screen.dart'; // ✅ استيراد حجوزاتي
import 'dart:ui' as ui show TextDirection;

// كلاس لتمرير بيانات النجاح (إذا لم يكن موجوداً عندك)
class BookingSuccessData {
  final int bookingId;
  final int ticketCount;
  final int totalAmount;

  BookingSuccessData({
    required this.bookingId,
    required this.ticketCount,
    required this.totalAmount,
  });
}

class RequestReceivedScreen extends StatelessWidget {
  final BookingSuccessData bookingData;

  const RequestReceivedScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة النجاح
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
                ),
                const SizedBox(height: 20),
                
                // رسالة النجاح
                Text('تم استلام طلب الحجز بنجاح!', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  'سيتم مراجعة الطلب وتأكيده من قبل الشركة قريباً.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // كرت تفاصيل الطلب
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                  child: Column(
                    children: [
                      _buildRow('رقم الطلب', '#${bookingData.bookingId}', textColor, primaryColor, isBold: true),
                      const Divider(height: 30),
                      _buildRow('عدد المقاعد', '${bookingData.ticketCount} مقاعد', textColor, textColor),
                      const Divider(height: 30),
                      _buildRow('المبلغ الإجمالي', '${bookingData.totalAmount} ريال', textColor, textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ✅ الزر الأول: متابعة حالة الحجز (يذهب إلى حجوزاتي)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى شاشة حجوزاتي
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('متابعة حالة الحجز (حجوزاتي)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 15),

                // ✅ الزر الثاني: العودة للرئيسية
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // إغلاق كل الشاشات والعودة للصفحة الرئيسية
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text('العودة للصفحة الرئيسية', style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, Color textColor, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: isBold ? 18 : 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}