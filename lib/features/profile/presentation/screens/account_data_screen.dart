import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
// استيراد مدير الإعدادات للوضع الليلي
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfileScreen({super.key, this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // التحكم في الحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); 

  DateTime? _selectedDateOfBirth;
  bool _isSaving = false;
  final String _baseUrl = "https://server-darb.runasp.net";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // دالة لاستخراج البيانات وتعبئتها في الحقول
  void _loadInitialData() {
    final data = widget.userData?['data'] ?? widget.userData?['result'] ?? widget.userData ?? {};
    
    _nameController.text = data['fullName']?.toString() ?? data['name']?.toString() ?? "";
    _emailController.text = data['email']?.toString() ?? "";
    _phoneController.text = data['phoneNumber']?.toString() ?? data['phone']?.toString() ?? "";
    _nationalIdController.text = data['nationalId']?.toString() ?? data['identityNumber']?.toString() ?? "";
    _addressController.text = data['address']?.toString() ?? data['city']?.toString() ?? "";

    // محاولة استخراج تاريخ الميلاد إذا كان موجوداً
    if (data['dateOfBirth'] != null) {
      try {
        _selectedDateOfBirth = DateTime.parse(data['dateOfBirth'].toString());
      } catch (e) {
        _selectedDateOfBirth = null;
      }
    }
  }

  // دالة اختيار تاريخ الميلاد
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE79C24)),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // دالة إرسال التحديثات للسيرفر
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار تاريخ الميلاد"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // تجهيز البيانات بناءً على صورة الـ Swagger التي أرسلتها
      final Map<String, dynamic> requestBody = {
        "fullName": _nameController.text.trim(),
        "dateOfBirth": _selectedDateOfBirth!.toIso8601String(), // صيغة ISO المطلوبة
        "phoneNumber": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "nationalId": _nationalIdController.text.trim(),
        "email": _emailController.text.trim(),
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/api/Customer/settings/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*'
        },
        body: json.encode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        // تحديث البيانات المحلية ليتم عرضها في شاشة البروفايل الرئيسية
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث بياناتك بنجاح! 🎉"), backgroundColor: Colors.green),
        );
        
        Navigator.pop(context, true); // العودة مع إشارة نجاح لتحديث الشاشة السابقة
      } else {
        throw Exception("فشل التحديث، كود الخطأ: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Update Profile Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء حفظ البيانات، يرجى المحاولة لاحقاً."), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // دعم الوضع الليلي
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDark;
    
    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF6F8FB);
    final Color fieldBgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final Color labelColor = isDark ? Colors.grey[400]! : const Color(0xFF0D1B3E);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          toolbarHeight: 80, 
          title: const Text(
            "تعديل بيانات الحساب",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold) 
          ),
          centerTitle: true, 
          backgroundColor: const Color(0xFFE79C24),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), 
            onPressed: () => Navigator.pop(context),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel("الاسم الكامل", labelColor),
                _buildInputField(
                  controller: _nameController, 
                  icon: Icons.person_outline, 
                  isDark: isDark, 
                  fieldBgColor: fieldBgColor, 
                  textColor: textColor,
                  validator: (v) => v!.isEmpty ? "يرجى إدخال الاسم" : null,
                ),
                const SizedBox(height: 20),
                
                _buildFieldLabel("البريد الإلكتروني", labelColor),
                _buildInputField(
                  controller: _emailController, 
                  icon: Icons.email_outlined, 
                  isDark: isDark, 
                  fieldBgColor: fieldBgColor, 
                  textColor: textColor,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? "بريد إلكتروني غير صالح" : null,
                ),
                const SizedBox(height: 20),
                
                _buildFieldLabel("رقم الهاتف", labelColor),
                _buildInputField(
                  controller: _phoneController, 
                  icon: Icons.phone_android_outlined, 
                  isDark: isDark, 
                  fieldBgColor: fieldBgColor, 
                  textColor: textColor,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "يرجى إدخال رقم الهاتف" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("رقم الهوية", labelColor),
                _buildInputField(
                  controller: _nationalIdController, 
                  icon: Icons.badge_outlined, 
                  isDark: isDark, 
                  fieldBgColor: fieldBgColor, 
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "يرجى إدخال رقم الهوية" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("العنوان (المحافظة / المدينة)", labelColor),
                _buildInputField(
                  controller: _addressController, 
                  icon: Icons.location_city_outlined, 
                  isDark: isDark, 
                  fieldBgColor: fieldBgColor, 
                  textColor: textColor,
                  validator: (v) => v!.isEmpty ? "يرجى إدخال العنوان" : null,
                ),
                const SizedBox(height: 20),

                _buildFieldLabel("تاريخ الميلاد", labelColor),
                GestureDetector(
                  onTap: () => _selectDateOfBirth(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: fieldBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, color: const Color(0xFFE79C24).withValues(alpha: 0.7), size: 22),
                        const SizedBox(width: 15),
                        Text(
                          _selectedDateOfBirth != null 
                              ? DateFormat('yyyy/MM/dd').format(_selectedDateOfBirth!)
                              : "اختر تاريخ ميلادك",
                          style: TextStyle(
                            fontSize: 15, 
                            color: _selectedDateOfBirth != null ? textColor : Colors.grey,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE79C24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    required Color fieldBgColor,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE79C24).withValues(alpha: 0.7), size: 22),
        filled: true,
        fillColor: fieldBgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: const BorderSide(color: Color(0xFFE79C24), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}