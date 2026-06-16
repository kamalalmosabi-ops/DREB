import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/core/utils/validators.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/features/auth/presentation/screens/reset_password_screen.dart';

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
    final tfFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(alignment: isAr ? Alignment.topRight : Alignment.topLeft, child: _buildCircleBackButton(context, isAr)),
                const SizedBox(height: 60),
                Text(loc.translate('forgot_password_title'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor)),
                const SizedBox(height: 50),

                _buildLabel(loc.translate('email'), isAr, textColor),
                _buildTextField(_emailController, "example@email.com", Validators.validateEmail, isAr, tfFillColor, textColor, hintColor),
                const SizedBox(height: 40),

                authProvider.isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFE79C24))
                    :_buildMainButton(loc.translate('send_verification_code'), () async {
                      if (_formKey.currentState!.validate()) {
                        bool success = await authProvider.sendForgotPasswordOTP(_emailController.text.trim());
                        if (!context.mounted) return; 

                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(
                                email: _emailController.text.trim(),
                                otp: "", 
                              ),
                            ),
                          );
                        }
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? Function(String?) validator, bool isAr, Color tfFillColor, Color textColor, Color hintColor) => TextFormField(
      controller: controller,
      textAlign: isAr ? TextAlign.right : TextAlign.left,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: hintColor), filled: true, fillColor: tfFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );

  Widget _buildLabel(String text, bool isAr, Color color) => Align(alignment: isAr ? Alignment.centerRight : Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color))));
  Widget _buildMainButton(String text, VoidCallback onTap) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))));
  Widget _buildCircleBackButton(BuildContext context, bool isAr) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white, size: 22)));
}