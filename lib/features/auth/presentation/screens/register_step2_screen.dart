import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import '../../../home_search/presentation/screens/home_screen.dart';

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

  // تعديل صيغة التاريخ لتكون متوافقة مع السيرفر
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
                const SizedBox(height: 20),
                const Center(child: Text("إكمال البيانات", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D1B3E)))),
                const SizedBox(height: 15),
                Center(child: _buildSteps(2)),
                const SizedBox(height: 30),

                _buildLabel("الاسم الكامل"),
                _buildTextField(hint: "مثال: الاسم", controller: _nameController),
                _buildLabel("رقم الهاتف"),
                _buildTextField(hint: "05xxxxxxxx", controller: _phoneController, type: TextInputType.phone),
                _buildLabel("الهوية الوطنية (11 رقم)"),
                _buildTextField(hint: "رقم الهوية", controller: _nationalIdController, type: TextInputType.number, isNationalId: true),
                _buildLabel("تاريخ الميلاد"),
                GestureDetector(onTap: _selectDate, child: AbsorbPointer(child: _buildTextField(hint: "اختر التاريخ", controller: _dobController))),
                _buildLabel("العنوان"),
                _buildTextField(hint: "المدينة، الحي", controller: _addressController),

                const SizedBox(height: 40),
                authProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24))) 
                  : _buildMainButton("تسجيل الحساب", () async {
                      if (_formKey.currentState!.validate()) {
                        bool success = await authProvider.registerCustomer(
                          name: _nameController.text.trim(),
                          email: widget.email,
                          password: widget.password,
                          phone: _phoneController.text.trim(),
                          nationalId: _nationalIdController.text.trim(),
                          address: _addressController.text.trim(),
                          dateOfBirth: _dobController.text.trim(),
                        );
                        
                        if (success && mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        } else if (mounted) {
                          // إظهار رسالة خطأ في حال فشل التسجيل
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authProvider.errorMessage ?? "حدث خطأ أثناء التسجيل")),
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

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(top: 15, bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))));
  
  Widget _buildTextField({required String hint, required TextEditingController controller, TextInputType type = TextInputType.text, bool isNationalId = false}) => TextFormField(
    controller: controller, keyboardType: type, textAlign: TextAlign.right,
    validator: (v) {
      if (v == null || v.isEmpty) return "مطلوب";
      if (isNationalId && v.length < 11) return "يجب أن تكون 11 رقماً";
      return null;
    },
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF9FAFB), contentPadding: const EdgeInsets.all(18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );
  
  Widget _buildMainButton(String text, VoidCallback onTap) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))));
  
  Widget _buildCircleBackButton(BuildContext context) => GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20)));
  
  Widget _buildSteps(int step) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _buildStepIndicator(width: step == 1 ? 35 : 15, color: step == 1 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
    const SizedBox(width: 8),
    _buildStepIndicator(width: step == 2 ? 35 : 15, color: step == 2 ? const Color(0xFFE79C24) : const Color(0xFFE5E7EB)),
  ]);
  
  Widget _buildStepIndicator({required double width, required Color color}) => Container(width: width, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)));
}