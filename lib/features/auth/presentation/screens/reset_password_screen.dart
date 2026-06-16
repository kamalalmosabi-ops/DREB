import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/core/utils/validators.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart'; 

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController.text = widget.otp;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
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
    final labelColor = isDark ? Colors.grey[300]! : const Color(0xFF374151);
    final tfFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final align = isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: align,
              children: [
                const SizedBox(height: 20),
                Align(alignment: isAr ? Alignment.topRight : Alignment.topLeft, child: _buildCircleBackButton(context, isAr)),
                const SizedBox(height: 40),
                Center(child: Text(loc.translate('reset_password'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor))),
                
                const SizedBox(height: 30),
                _buildLabel(loc.translate('otp_code_label'), labelColor),
                _buildTextField(_otpController, loc.translate('enter_sent_code'), (val) => val!.isEmpty ? loc.translate('required_field') : null, false, isAr, tfFillColor, textColor, hintColor),

                const SizedBox(height: 20),
                _buildLabel(loc.translate('new_password'), labelColor),
                _buildTextField(_passwordController, "********", Validators.validatePassword, true, isAr, tfFillColor, textColor, hintColor),
                
                const SizedBox(height: 20),
                _buildLabel(loc.translate('confirm_password'), labelColor),
                _buildTextField(_confirmPasswordController, "********", (value) {
                  if (value != _passwordController.text) return loc.translate('passwords_do_not_match');
                  return null;
                }, true, isAr, tfFillColor, textColor, hintColor),

                const SizedBox(height: 40),
                authProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
                  : SizedBox(
                      width: double.infinity, height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                       onPressed: () async {
                       if (_formKey.currentState!.validate()) {
                       bool success = await authProvider.resetPassword(
                              widget.email, 
                          _passwordController.text, 
                          _otpController.text.trim()
                         );
    
                      if (!context.mounted) return;

                       if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate('password_changed_success')))
                          );
       
                             Navigator.pushAndRemoveUntil(
                             context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                        }
                      }
                 },
                        child: Text(loc.translate('save_and_change'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? Function(String?) validator, bool isPassword, bool isAr, Color tfFillColor, Color textColor, Color hintColor) => TextFormField(
    controller: controller, textAlign: isAr ? TextAlign.right : TextAlign.left, obscureText: isPassword, validator: validator,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: hintColor), filled: true, fillColor: tfFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildLabel(String text, Color color) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)));
  Widget _buildCircleBackButton(BuildContext context, bool isAr) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white, size: 22)));
}