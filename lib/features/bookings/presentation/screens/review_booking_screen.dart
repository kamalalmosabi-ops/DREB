import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/bookings/data/models/passenger_model.dart';
import 'package:darb/features/bookings/presentation/providers/booking_provider.dart';
// ✅ تم استيراد شاشة تأكيد استلام الطلب
import 'package:darb/features/bookings/presentation/screens/request_received_screen.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';
import 'dart:ui' as ui show TextDirection;

class ReviewBookingScreen extends StatelessWidget {
  final int ticketCount;
  final int unitPrice;
  final String route;
  final int tripRouteId;
  final String companyName;
  final String departureTime;
  final List<PassengerModel> passengers;
  final String paymentMethod;

  const ReviewBookingScreen({
    super.key,
    required this.ticketCount,
    required this.unitPrice,
    required this.route,
    required this.tripRouteId,
    required this.companyName,
    required this.departureTime,
    required this.passengers,
    required this.paymentMethod,
  });

  // ✅ الدالة المحدثة التي تنقل المستخدم لشاشة "تم الطلب بنجاح"
  Future<void> _submitFinalBooking(BuildContext context, BookingProvider provider, AppLocalizations loc) async {
    if (paymentMethod == "سند" && provider.receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إرفاق صورة السند لاعتماد الحجز النهائي')));
      return;
    }

    int? bookingId = await provider.submitBooking(
      tripRouteId: tripRouteId,
      passengers: passengers,
      receipt: provider.receiptImage!,
    );

    if (!context.mounted) return;

    if (bookingId != null) {
      // ✅ الانتقال لشاشة "تم الطلب بنجاح" وتفريغ المكدس للرئيسية
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RequestReceivedScreen(
          bookingData: BookingSuccessData(
            bookingId: bookingId, 
            ticketCount: ticketCount, 
            totalAmount: ticketCount * unitPrice
          ),
        )),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error_try_again_later') ?? 'حدث خطأ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bookingProvider = context.watch<BookingProvider>();
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final primaryColor = const Color(0xFFE79C24);
    
    final int totalAmount = ticketCount * unitPrice;

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text('مراجعة وتأكيد الحجز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottomNavigationBar: _buildStickyFooter(context, loc, cardColor, textColor, primaryColor, bookingProvider),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('تفاصيل الرحلة', textColor),
              _buildInfoCard(cardColor, [
                _buildRowItem('الشركة', companyName, textColor),
                const Divider(),
                _buildRowItem('المسار', route, textColor),
                const Divider(),
                _buildRowItem('وقت الانطلاق', departureTime, textColor),
              ]),
              const SizedBox(height: 20),

              _buildSectionTitle('بيانات الركاب (${passengers.length})', textColor),
              _buildInfoCard(cardColor, passengers.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👤 ${p.fullName}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text("الهوية: ${p.nationalId} | الجوال: ${p.phoneNumber}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    if (p != passengers.last) const Divider(height: 20),
                  ],
                ),
              )).toList()),
              const SizedBox(height: 20),

              _buildSectionTitle('إرفاق سند الدفع', textColor),
              _buildInfoCard(cardColor, [
                _buildRowItem('طريقة الدفع', paymentMethod, textColor),
                const Divider(),
                _buildRowItem('إجمالي المبلغ', "$totalAmount ${loc.translate('riyals') ?? 'ريال'}", textColor, isBold: true, valueColor: primaryColor),
                const Divider(),
                
                if (paymentMethod == "سند") ...[
                  const SizedBox(height: 10),
                  const Text('الرجاء إرفاق صورة حوالة الإيداع لاعتماد الحجز:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 10),
                  if (bookingProvider.receiptImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(bookingProvider.receiptImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) bookingProvider.updateReceiptImage(File(picked.path));
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(bookingProvider.receiptImage == null ? 'رفع صورة السند' : 'تغيير الصورة'),
                      style: TextButton.styleFrom(foregroundColor: primaryColor),
                    ),
                  )
                ]
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
    );
  }

  Widget _buildInfoCard(Color cardColor, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildRowItem(String title, String value, Color textColor, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Flexible(
          child: Text(
            value, 
            style: TextStyle(color: valueColor ?? textColor, fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context, AppLocalizations loc, Color cardColor, Color textColor, Color primaryColor, BookingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        onPressed: provider.isSubmitting ? null : () => _submitFinalBooking(context, provider, loc),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: provider.isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('تأكيد واعتماد الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}