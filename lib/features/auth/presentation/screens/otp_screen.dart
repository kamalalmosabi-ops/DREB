import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
// لا تنسَ استيراد شاشة تسجيل الدخول أو الشاشة الرئيسية التي سينتقل لها بعد التأكيد
import 'package:darb/features/auth/presentation/screens/login_screen.dart'; 

class OtpScreen extends StatefulWidget {
  final String email; // نستقبل الإيميل بدلاً من verificationId

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController pinController = TextEditingController();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استدعاء المزود (Provider)
    final authProvider = Provider.of<AuthProvider>(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xFF0D1B3E),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFFE79C24), width: 2),
      borderRadius: BorderRadius.circular(15),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.mark_email_read_rounded,
                size: 80,
                color: Color(0xFFE79C24),
              ),
              const SizedBox(height: 24),
              const Text(
                "تأكيد الحساب",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B3E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "أدخل الرمز المكون من 6 أرقام الذي أرسلناه للتو إلى بريدك الإلكتروني:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 40),
              
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  controller: pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  showCursor: true,
                ),
              ),
              
              const SizedBox(height: 40),
              authProvider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
                : SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                    onPressed: () async {
  String otpCode = pinController.text.trim();
  if (otpCode.length == 6) {
    bool success = await authProvider.verifyRegistrationOTP(
      widget.email, 
      otpCode,
    );
    
    // السطر الذهبي المستقل
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تأكيد الحساب بنجاح!"))
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "الرمز غير صحيح، يرجى المحاولة مرة أخرى."))
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("يرجى إدخال الرمز المكون من 6 أرقام بالكامل"))
    );
  }
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE79C24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "تأكيد",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}