import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/core/utils/validators.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart'; 

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                Align(alignment: Alignment.topRight, child: _buildCircleBackButton(context)),
                const SizedBox(height: 40),
                const Center(child: Text("إعادة تعيين كلمة المرور", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D1B3E)))),
                
                const SizedBox(height: 30),
                _buildLabel("رمز التحقق (OTP)"),
                _buildTextField(_otpController, "أدخل الرمز المرسل", (val) => val!.isEmpty ? "مطلوب" : null, false),

                const SizedBox(height: 20),
                _buildLabel("كلمة المرور الجديدة"),
                _buildTextField(_passwordController, "********", Validators.validatePassword, true),
                
                const SizedBox(height: 20),
                _buildLabel("تأكيد كلمة المرور"),
                _buildTextField(_confirmPasswordController, "********", (value) {
                  if (value != _passwordController.text) return "كلمات المرور غير متطابقة";
                  return null;
                }, true),

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
    
                             // السطر الذهبي هنا بعد الـ await
                      if (!context.mounted) return;

                       if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح!"))
                          );
       
                             Navigator.pushAndRemoveUntil(
                             context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                        }
                     }
                 },
                        child: const Text("حفظ وتغيير", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? Function(String?) validator, bool isPassword) => TextFormField(
    controller: controller, textAlign: TextAlign.right, obscureText: isPassword, validator: validator,
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))));
  Widget _buildCircleBackButton(BuildContext context) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22)));
}