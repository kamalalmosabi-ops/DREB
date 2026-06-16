import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_bookings_screen.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

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

  const RequestReceivedScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    
    final primaryGold = const Color(0xFFE79C24);
    final darkNavy = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final lightGrey = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: lightGrey,
        body: Stack(
          children: [
            _buildBackgroundHeader(context, primaryGold),
            Column(
              children: [
                const SizedBox(height: 70),
                _buildStatusCircle(primaryGold),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      _buildMainMessage(loc),
                      const SizedBox(height: 25),
                      _buildOrderDetailsCard(cardColor, darkNavy, primaryGold, loc),
                      const SizedBox(height: 20),
                      _buildNextStepsCard(loc),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomSheet: _buildActionButtons(context, primaryGold, darkNavy, lightGrey, loc),
      ),
    );
  }

  Widget _buildBackgroundHeader(BuildContext context, Color color) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
    );
  }

  Widget _buildStatusCircle(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Icon(Icons.hourglass_empty_rounded, color: color, size: 50),
    );
  }

  Widget _buildMainMessage(AppLocalizations loc) {
    return Column(
      children: [
        Text(loc.translate('request_sent_successfully'),
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(loc.translate('request_in_review'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
      ],
    );
  }

  Widget _buildOrderDetailsCard(Color cardColor, Color textColor, Color gold, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        children: [
          _buildDataRow(loc.translate('booking_id_label'), "#${bookingData.bookingId}", isTitle: true, color: gold, textColor: textColor),
          const Divider(height: 30),
          _buildDataRow(loc.translate('passengers_count'), "${bookingData.ticketCount}", textColor: textColor),
          const SizedBox(height: 15),
          _buildDataRow(loc.translate('total_amount'), "${bookingData.totalAmount} ${loc.translate('riyals')}", textColor: textColor),
          const SizedBox(height: 15),
          _buildDataRow(loc.translate('current_booking_status'), bookingData.status, color: gold, textColor: textColor),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0D1B3E), borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              loc.translate('next_steps_info'),
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isTitle = false, Color? color, required Color textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color ?? textColor,
                fontWeight: FontWeight.bold,
                fontSize: isTitle ? 18 : 14)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Color gold, Color dark, Color bgColor, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text(loc.translate('go_to_bookings'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text(loc.translate('back_to_home'), style: TextStyle(color: dark, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}