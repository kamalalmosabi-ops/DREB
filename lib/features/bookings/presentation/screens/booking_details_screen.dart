import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

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
              // كرت التذكرة الرئيسي
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('رقم الحجز', "#${bookingData['bookingId'] ?? bookingData['id'] ?? '---'}", textColor, primaryColor),
                    const Divider(height: 30),
                    _buildDetailRow('حالة الحجز', bookingData['statusName'] ?? '---', textColor, Colors.green),
                    const Divider(height: 30),
                    _buildDetailRow('محطة الانطلاق', bookingData['fromStation'] ?? '---', textColor, textColor),
                    const SizedBox(height: 10),
                    _buildDetailRow('وقت الانطلاق', bookingData['travelTime'] ?? '---', textColor, Colors.grey),
                    const Divider(height: 30),
                    _buildDetailRow('محطة الوصول', bookingData['toStation'] ?? '---', textColor, textColor),
                    const SizedBox(height: 10),
                    _buildDetailRow('تاريخ الوصول', bookingData['travelDate'] ?? '---', textColor, Colors.grey),
                    const Divider(height: 30),
                    _buildDetailRow('المبلغ الإجمالي', "${bookingData['price'] ?? bookingData['totalAmount'] ?? 0} ${loc.translate('riyals')}", textColor, primaryColor, isBold: true),
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