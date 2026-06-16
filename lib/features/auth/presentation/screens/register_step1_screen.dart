import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/screens/register_step2_screen.dart';

// استيراد الترجمة ومدير الإعدادات للوضع الليلي
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _isObscurePassword = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;

    // الألوان
    final isDark = settings.isDark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final labelColor = isDark ? Colors.grey[300]! : const Color(0xFF374151);
    final tfFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    // المحاذاة
    final isAr = settings.locale.languageCode == 'ar';
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
                Align(
                  alignment: isAr ? Alignment.topRight : Alignment.topLeft, 
                  child: _buildCircleBackButton(context, isAr)
                ),
                const SizedBox(height: 20),
                Center(child: Text(loc.translate('create_new_account'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor))),
                const SizedBox(height: 15),
                Center(child: _buildSteps(1)), 
                const SizedBox(height: 30),
                
                _buildLabel(loc.translate('email'), labelColor),
                _buildTextField(hint: "example@gmail.com", controller: _emailController, isEmail: true, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc),
                
                _buildLabel(loc.translate('password'), labelColor),
                _buildTextField(
                  hint: "********", 
                  controller: _passwordController, 
                  isPassword: true,
                  isObscure: _isObscurePassword, 
                  isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc,
                  onToggleVisibility: () {
                    setState(() {
                      _isObscurePassword = !_isObscurePassword; 
                    });
                  }
                ),
                
                _buildLabel(loc.translate('confirm_password'), labelColor),
                _buildTextField(
                  hint: "********", 
                  controller: _confirmController, 
                  isPassword: true,
                  isObscure: _isObscureConfirm, 
                  isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc,
                  onToggleVisibility: () {
                    setState(() {
                      _isObscureConfirm = !_isObscureConfirm; 
                    });
                  }
                ),
                
                const SizedBox(height: 40),
                _buildMainButton(loc.translate('next'), () {
                  if (_formKey.currentState!.validate()) {
                    if (_passwordController.text != _confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('passwords_do_not_match'))));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterStep2Screen(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    )));
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)));
  
  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    bool isPassword = false, 
    bool isEmail = false,
    bool? isObscure,
    VoidCallback? onToggleVisibility,
    required bool isAr,
    required Color tfFillColor,
    required Color textColor,
    required Color hintColor,
    required AppLocalizations loc,
  }) => TextFormField(
    controller: controller, 
    obscureText: isObscure ?? isPassword, 
    textAlign: isAr ? TextAlign.right : TextAlign.left,
    style: TextStyle(color: textColor),
    validator: (v) => v == null || v.isEmpty ? loc.translate('required_field') : null,
    decoration: InputDecoration(
      hintText: hint, 
      hintStyle: TextStyle(color: hintColor),
      filled: true, 
      fillColor: tfFillColor, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      prefixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                (isObscure ?? true) ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
    ),
  );

  Widget _buildSteps(int step) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _buildStepIndicator(width: step == 1 ? 35 : 15, color: step == 1 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
    const SizedBox(width: 8),
    _buildStepIndicator(width: step == 2 ? 35 : 15, color: step == 2 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
  ]);

  Widget _buildStepIndicator({required double width, required Color color}) => Container(width: width, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)));
  
  Widget _buildMainButton(String text, VoidCallback onTap) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))));
  
  Widget _buildCircleBackButton(BuildContext context, bool isAr) => GestureDetector(
    onTap: () => Navigator.pop(context), 
    child: Container(
      padding: const EdgeInsets.all(8), 
      decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), 
      child: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white)
    )
  );
}