import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/bookings/data/models/passenger_model.dart';
import 'package:darb/features/bookings/presentation/providers/booking_provider.dart';
import 'package:darb/features/bookings/presentation/screens/review_booking_screen.dart';
import 'dart:ui' as ui show TextDirection;
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class ReservationScreen extends StatefulWidget {
  final int ticketCount;
  final int unitPrice;
  final String route;
  final int tripRouteId;
  final int companyId;
  final String companyName;
  final String departureTime;

  const ReservationScreen({
    super.key,
    required this.ticketCount,
    required this.unitPrice,
    required this.route,
    required this.tripRouteId,
    required this.companyId,
    this.companyName = "شركة النقل البري",
    this.departureTime = "08:00 PM",
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<PassengerModel> passengers;
  String? _paymentMethod;
  final Color primaryColor = const Color(0xFFE79C24);

  @override
  void initState() {
    super.initState();
    passengers = List.generate(widget.ticketCount, (index) => PassengerModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadCompanyBankAccounts(widget.companyId);
    });
  }

  void _goToReviewScreen(AppLocalizations loc) {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('please_select_payment_method'))));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewBookingScreen(
          ticketCount: widget.ticketCount,
          unitPrice: widget.unitPrice,
          route: widget.route,
          tripRouteId: widget.tripRouteId,
          companyName: widget.companyName,
          departureTime: widget.departureTime,
          passengers: passengers,
          paymentMethod: _paymentMethod!,
        ),
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
    final inputBgColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF4F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        bottomNavigationBar: _buildStickyFooter(loc, cardColor),
        body: Column(
          children: [
            _buildRichHeader(loc, isAr),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 25),
                    _buildSectionTitle(loc.translate('passengers_data'), textColor),
                    ...List.generate(widget.ticketCount, (index) => _buildPassengerCard(index, loc, isAr, cardColor, inputBgColor, textColor)),
                    const SizedBox(height: 25),
                    _buildSectionTitle(loc.translate('payment_method'), textColor),
                    _buildPaymentMethodSelector(loc, textColor),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichHeader(AppLocalizations loc, bool isAr) {
     return Container(
      padding: const EdgeInsets.fromLTRB(15, 50, 15, 25),
      decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35))),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white)),
          Text(loc.translate('confirm_trip_booking'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(int index, AppLocalizations loc, bool isAr, Color cardColor, Color inputBgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("${loc.translate('passenger_data_singular')} ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
           const SizedBox(height: 15),
           _buildField(loc.translate('full_name'), Icons.person, (v) => passengers[index].fullName = v ?? "", inputBgColor, isAr),
           const SizedBox(height: 10),
           // ✅ تم تحديد الحد الأقصى للهوية بـ 11 رقم
           _buildField("رقم الهوية / الجواز", Icons.badge, (v) => passengers[index].nationalId = v ?? "", inputBgColor, isAr, isNumber: true, maxLength: 11),
           const SizedBox(height: 10),
           _buildField("رقم الجوال", Icons.phone, (v) => passengers[index].phoneNumber = v ?? "", inputBgColor, isAr, isNumber: true),
        ],
      ),
    );
  }

  // ✅ تم إضافة خصائص maxLength و counterText لإخفاء العداد
  Widget _buildField(String hint, IconData icon, Function(String?) onSaved, Color inputBgColor, bool isAr, {bool isNumber = false, int? maxLength}) {
    return TextFormField(
      onSaved: onSaved,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب لإتمام الحجز';
        if (maxLength != null && value.length != maxLength) return 'يجب أن يتكون من $maxLength رقماً';
        return null;
      },
      decoration: InputDecoration(
        hintText: hint, 
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true, 
        fillColor: inputBgColor, 
        counterText: "", // ✅ إخفاء العداد الرقمي المزعج
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }

  Widget _buildStickyFooter(AppLocalizations loc, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor),
      child: ElevatedButton(
        onPressed: () => _goToReviewScreen(loc),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text('مراجعة الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      )
    );
  }
  
  Widget _buildSectionTitle(String t, Color textColor) => Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: textColor));
  
  Widget _buildPaymentMethodSelector(AppLocalizations loc, Color textColor) =>RadioGroup<String>(
  groupValue: _paymentMethod, // نقلناها هنا للأب
  onChanged: (v) => setState(() => _paymentMethod = v), // نقلناها هنا للأب
  child: Row( // أو Column حسب تصميم صفحتك
    children: [
      Radio<String>(
        value: 'cash',
        activeColor: primaryColor,
      ),
      Radio<String>(
        value: 'card',
        activeColor: primaryColor,
      ),
    ],
  ),
);}