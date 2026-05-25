import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:darb/features/bookings/data/models/passenger_model.dart';
import 'package:darb/features/bookings/data/models/booking_service.dart';
import 'request_received_screen.dart';
import 'dart:ui' as ui show TextDirection;

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
  File? _receiptImage;
  String? _paymentMethod;

  final BookingService _bookingService = BookingService();
  List<BankAccountModel> _bankAccounts = [];
  bool _isLoadingBanks = false;
  bool _isSubmitting = false;

  final Color primaryColor = const Color(0xFFE79C24);
  final Color darkBlue = const Color(0xFF0D1B3E);
  final Color bgColor = const Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();
    passengers = List.generate(widget.ticketCount, (index) => PassengerModel());
    _loadCompanyBankAccounts();
  }

  Future<void> _loadCompanyBankAccounts() async {
    if (!mounted) return;
    setState(() => _isLoadingBanks = true);
    var accounts = await _bookingService.getCompanyBankAccounts(widget.companyId);
    if (!mounted) return;
    setState(() {
      _bankAccounts = accounts;
      _isLoadingBanks = false;
    });
  }

  int _calculateTotal() {
    return widget.unitPrice * widget.ticketCount;
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "إرفاق صورة السند من:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1B3E)),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceItem(
                    icon: Icons.camera_alt_rounded,
                    label: "الكاميرا",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildSourceItem(
                    icon: Icons.photo_library_rounded,
                    label: "المعرض",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _receiptImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("خطأ أثناء فتح مستودع الصور: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("لم نتمكن من فتح معرض الصور: $e")),
      );
    }
  }

  Widget _buildSourceItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context, int index) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: darkBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        passengers[index].birthDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildRichHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 25),
                    _buildSectionTitle("بيانات المسافرين"),
                    ...List.generate(widget.ticketCount, (index) => _buildCollapsiblePassengerCard(index)),
                    const SizedBox(height: 25),
                    _buildSectionTitle("طريقة الدفع"),
                    _buildPaymentMethodSelector(),
                    if (_paymentMethod == "سند") _buildBankTransferSection(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: _buildStickyFooter(),
      ),
    );
  }

  Widget _buildRichHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 50, 15, 25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
              const Spacer(),
              const Text("تأكيد حجز الرحلة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.route, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text("${widget.companyName} • ${widget.departureTime}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(10)),
                  child: Text("${widget.ticketCount} ركاب", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsiblePassengerCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          leading: Icon(Icons.person_pin_rounded, color: darkBlue),
          title: Text("بيانات المسافر ${index + 1}", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            const Divider(),
            _buildField("الاسم الرباعي الكامل", Icons.edit, (v) => passengers[index].fullName = v!),
            const SizedBox(height: 12),
            _buildField("رقم الهوية الوطنية", Icons.badge_outlined, (v) => passengers[index].nationalId = v!, isNumber: true, isId: true),
            const SizedBox(height: 12),
            _buildField("رقم الجوال", Icons.phone_android, (v) => passengers[index].phoneNumber = v!, isNumber: true),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectBirthDate(context, index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Icon(Icons.cake_outlined, color: darkBlue),
                    const SizedBox(width: 12),
                    Text(
                      passengers[index].birthDate.isEmpty ? "اختر تاريخ الميلاد *" : "تاريخ الميلاد: ${passengers[index].birthDate}",
                      style: TextStyle(color: darkBlue, fontSize: 14),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_month, color: primaryColor, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: RadioListTile<String>(
        title: const Text("إيداع / تحويل بنكي (سند الدفع)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: const Text("يتطلب رفع صورة السند"),
        value: "سند",
        groupValue: _paymentMethod,
        activeColor: primaryColor,
        onChanged: (v) => setState(() => _paymentMethod = v),
      ),
    );
  }

  Widget _buildBankTransferSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("قم بالتحويل إلى الحسابات التالية:", style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _isLoadingBanks
              ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
              : _bankAccounts.isEmpty
                  ? const Text("لا توجد حسابات بنكية.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bankAccounts.length,
                      itemBuilder: (context, idx) {
                        return _buildAccountRow(_bankAccounts[idx].bankName, _bankAccounts[idx].accountNumber);
                      },
                    ),
          const Divider(height: 30),
          if (_receiptImage != null)
            Stack(
              alignment: Alignment.topLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_receiptImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                IconButton(
                  onPressed: () => setState(() => _receiptImage = null),
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _showImageSourceOptions,
              icon: Icon(Icons.add_a_photo_rounded, color: darkBlue),
              label: Text(_receiptImage == null ? "إرفاق صورة السند" : "تغيير الصورة", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 35),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("إجمالي الحجز", style: TextStyle(color: Colors.grey, fontSize: 11)),
              Text("${_calculateTotal()} ر.ي", style: TextStyle(color: darkBlue, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleBookingSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("إتمام الحجز", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Future<void> _handleBookingSubmission() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى اختيار طريقة الدفع")));
      return;
    }

    for (int i = 0; i < passengers.length; i++) {
      if (passengers[i].birthDate.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تاريخ الميلاد للمسافر ${i + 1} مطلوب")));
        return;
      }
    }

    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إرفاق صورة السند")));
      return;
    }

    setState(() => _isSubmitting = true);

    BookingRequestModel apiData = BookingRequestModel(
      tripRouteId: widget.tripRouteId,
      additionalPassengers: passengers,
    );

    int? bookingId = await _bookingService.createBookingStage1(apiData);

    if (bookingId == null) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ، حاول لاحقاً")));
      return;
    }

    bool isReceiptUploaded = await _bookingService.uploadBookingReceiptStage2(bookingId, _receiptImage!);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (isReceiptUploaded) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => RequestReceivedScreen(
            bookingData: BookingSuccessData(
              bookingId: bookingId,
              ticketCount: widget.ticketCount,
              totalAmount: _calculateTotal(),
            ),
          ),
        ),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حجز البيانات ولكن فشل رفع الصورة.")));
    }
  }

  Widget _buildField(String hint, IconData icon, Function(String?) onSaved, {bool isNumber = false, bool isId = false}) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isId ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)] : null,
      decoration: _inputDecoration(hint, icon),
      validator: (v) {
        if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
        if (isId && v.length < 11) return "يجب أن يكون 11 رقماً";
        return null;
      },
      onSaved: onSaved,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: darkBlue),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      );

  Widget _buildAccountRow(String bankName, String accountNumber) => ListTile(
        title: Text(bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(accountNumber, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
        trailing: IconButton(
          icon: Icon(Icons.copy, size: 18, color: darkBlue),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: accountNumber));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم النسخ"), duration: Duration(seconds: 1)));
          },
        ),
        contentPadding: EdgeInsets.zero,
      );

  Widget _buildSectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 15)));
}