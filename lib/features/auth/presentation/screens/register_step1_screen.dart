import 'package:flutter/material.dart';
import 'package:darb/features/auth/presentation/screens/register_step2_screen.dart';

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
  
  // المتغيرات للتحكم بحالة إظهار كلمة المرور
  bool _isObscurePassword = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // المحاذاة لليمين
              children: [
                const SizedBox(height: 20),
                Align(alignment: Alignment.topRight, child: _buildCircleBackButton(context)),
                const SizedBox(height: 20),
                const Center(child: Text("إنشاء حساب جديد", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D1B3E)))),
                const SizedBox(height: 15),
                Center(child: _buildSteps(1)), // مؤشر الخطوات
                const SizedBox(height: 30),
                
                _buildLabel("البريد الإلكتروني"),
                _buildTextField(hint: "example@gmail.com", controller: _emailController, isEmail: true),
                
                _buildLabel("كلمة المرور"),
                _buildTextField(
                  hint: "********", 
                  controller: _passwordController, 
                  isPassword: true,
                  isObscure: _isObscurePassword, // تمرير الحالة الحالية
                  onToggleVisibility: () {
                    setState(() {
                      _isObscurePassword = !_isObscurePassword; // عكس الحالة عند الضغط
                    });
                  }
                ),
                
                _buildLabel("تأكيد كلمة المرور"),
                _buildTextField(
                  hint: "********", 
                  controller: _confirmController, 
                  isPassword: true,
                  isObscure: _isObscureConfirm, // تمرير الحالة الحالية
                  onToggleVisibility: () {
                    setState(() {
                      _isObscureConfirm = !_isObscureConfirm; // عكس الحالة عند الضغط
                    });
                  }
                ),
                
                const SizedBox(height: 40),
                _buildMainButton("التالي", () {
                  if (_formKey.currentState!.validate()) {
                    if (_passwordController.text != _confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمات المرور غير متطابقة")));
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

  // المكونات المساعدة
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))));
  
  // دالة المساعدة المحدثة لدعم أيقونة العين
  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    bool isPassword = false, 
    bool isEmail = false,
    bool? isObscure, // لتحديد هل النص مخفي أم لا
    VoidCallback? onToggleVisibility, // دالة تنفذ عند الضغط على العين
  }) => TextFormField(
    controller: controller, 
    obscureText: isObscure ?? isPassword, // استخدام isObscure إذا تم تمريره، وإلا استخدام isPassword
    textAlign: TextAlign.right,
    validator: (v) => v == null || v.isEmpty ? "هذا الحقل مطلوب" : null,
    decoration: InputDecoration(
      hintText: hint, 
      filled: true, 
      fillColor: const Color(0xFFF9FAFB), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      // إضافة أيقونة العين فقط إذا كان الحقل من نوع كلمة مرور
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
  Widget _buildCircleBackButton(BuildContext context) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white)));
}