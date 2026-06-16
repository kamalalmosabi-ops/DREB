import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/features/auth/presentation/screens/otp_screen.dart';

// استيراد الترجمة ومدير الإعدادات
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class RegisterStep2Screen extends StatefulWidget {
  final String email;
  final String password;
  const RegisterStep2Screen({super.key, required this.email, required this.password});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime(2000), 
      firstDate: DateTime(1950), 
      lastDate: DateTime.now()
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;

    // الألوان المتكيفة
    final isDark = settings.isDark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final labelColor = isDark ? Colors.grey[300]! : const Color(0xFF374151);
    final tfFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    // المحاذاة حسب اللغة
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
                Align(alignment: isAr ? Alignment.topRight : Alignment.topLeft, child: _buildCircleBackButton(context, isAr)),
                const SizedBox(height: 20),
                Center(child: Text(loc.translate('complete_data'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor))),
                const SizedBox(height: 15),
                Center(child: _buildSteps(2)),
                const SizedBox(height: 30),

                _buildLabel(loc.translate('full_name'), labelColor),
                _buildTextField(hint: loc.translate('name_example'), controller: _nameController, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc),
                
                _buildLabel(loc.translate('phone_number'), labelColor),
                _buildTextField(hint: "05xxxxxxxx", controller: _phoneController, type: TextInputType.phone, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc),
                
                _buildLabel(loc.translate('national_id'), labelColor),
                _buildTextField(hint: "11111111111", controller: _nationalIdController, type: TextInputType.number, isNationalId: true, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc),
                
                _buildLabel(loc.translate('dob'), labelColor),
                GestureDetector(onTap: _selectDate, child: AbsorbPointer(child: _buildTextField(hint: loc.translate('choose_date'), controller: _dobController, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc))),
                
                _buildLabel(loc.translate('address'), labelColor),
                _buildTextField(hint: loc.translate('city_neighborhood'), controller: _addressController, isAr: isAr, tfFillColor: tfFillColor, textColor: textColor, hintColor: hintColor, loc: loc),

              const SizedBox(height: 40),
              authProvider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24))) 
                : _buildMainButton(loc.translate('register_account'), () async {
                    if (_formKey.currentState!.validate()) {
                      bool otpSent = await authProvider.sendRegistrationOTP(widget.email);
                      if (!context.mounted) return; 
                      
                      if (otpSent) {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => OtpScreen(
                              email: widget.email,
                              password: widget.password,
                              fullName: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              nationalId: _nationalIdController.text.trim(),
                              address: _addressController.text.trim(),
                              dateOfBirth: _dobController.text.trim(),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage ?? loc.translate('otp_send_failed'))),
                        );
                      }
                    }
                  }),
              const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) => Padding(padding: const EdgeInsets.only(top: 15, bottom: 8), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)));
  
  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    TextInputType type = TextInputType.text, 
    bool isNationalId = false,
    required bool isAr,
    required Color tfFillColor,
    required Color textColor,
    required Color hintColor,
    required AppLocalizations loc,
  }) => TextFormField(
    controller: controller, keyboardType: type, textAlign: isAr ? TextAlign.right : TextAlign.left,
    style: TextStyle(color: textColor),
    validator: (v) {
      if (v == null || v.isEmpty) return loc.translate('required_field');
      if (isNationalId && v.length < 11) return loc.translate('must_be_11_digits');
      return null;
    },
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: hintColor), filled: true, fillColor: tfFillColor, contentPadding: const EdgeInsets.all(18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );
  
  Widget _buildMainButton(String text, VoidCallback onTap) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))));
  
  Widget _buildCircleBackButton(BuildContext context, bool isAr) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white, size: 20)));
  
  Widget _buildSteps(int step) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _buildStepIndicator(width: step == 1 ? 35 : 15, color: step == 1 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
    const SizedBox(width: 8),
    _buildStepIndicator(width: step == 2 ? 35 : 15, color: step == 2 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
  ]);
  
  Widget _buildStepIndicator({required double width, required Color color}) => Container(width: width, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)));
}