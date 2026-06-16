import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart';

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String nationalId;
  final String address;
  final String dateOfBirth;

  const OtpScreen({
    super.key, 
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.nationalId,
    required this.address,
    required this.dateOfBirth,
  });

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
    final authProvider = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;

    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final subTextColor = isDark ? Colors.grey[400]! : const Color(0xFF374151);
    final pinBgColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: pinBgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFFE79C24), width: 2),
      borderRadius: BorderRadius.circular(15),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
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
              Text(
                loc.translate('confirm_account'),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${loc.translate('enter_6_digit_code')}${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                  height: 1.5,
                ),
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 40),
              
              // الـ Pinput دائماً خله LTR عشان الأرقام تنكتب من اليسار لليمين صح
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
                        
                        bool isOtpValid = await authProvider.verifyRegistrationOTP(widget.email, otpCode);
                        if (!context.mounted) return;
                        
                        if (isOtpValid) {
                          bool isRegistered = await authProvider.registerCustomer(
                            name: widget.fullName,
                            email: widget.email,
                            password: widget.password,
                            phone: widget.phone,
                            nationalId: widget.nationalId,
                            address: widget.address,
                            dateOfBirth: widget.dateOfBirth,
                          );

                          if (!context.mounted) return;

                          if (isRegistered) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('account_registered_success')))
                            );
                            
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.errorMessage ?? loc.translate('error_saving_data')))
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authProvider.errorMessage ?? loc.translate('invalid_otp_try_again')))
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate('enter_full_6_digits')))
                        );
                      }
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE79C24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        loc.translate('confirm'),
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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