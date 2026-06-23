import 'dart:convert'; // ✅ تأكد من إضافة هذه المكتبة في أعلى الملف لفك التشفير
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';
import 'dart:ui' as ui show TextDirection;

// ============================================================================
// شاشة الـ QR Code (المحدثة لعرض صورة الـ Base64 من السيرفر)
// ============================================================================
class TicketQrScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const TicketQrScreen({super.key, required this.bookingData});

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

    // ✅ جلب كود الصورة المشفرة من السيرفر
    final String? base64QrImage = bookingData['ticketCode'];

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
                      Text('#${bookingData['bookingId']}', style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(thickness: 1, color: Colors.grey)),
                      
                      // ⬛ مربع الـ QR Code (تم التحديث هنا)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                        ),
                        child: (base64QrImage != null && base64QrImage.isNotEmpty)
                            ? Image.memory(
                                base64Decode(base64QrImage), // فك تشفير الصورة وعرضها
                                width: 180.0,
                                height: 180.0,
                                fit: BoxFit.contain,
                              )
                            : const SizedBox(
                                width: 180.0,
                                height: 180.0,
                                child: Center(
                                  child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildMiniDetail('المبلغ', '${bookingData['totalAmount']} ${loc.translate('riyals') ?? 'ريال'}', textColor, primaryColor)),
                          Expanded(child: _buildMiniDetail('الشركة', bookingData['companyName'] ?? '---', textColor, textColor, alignRight: true)),
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