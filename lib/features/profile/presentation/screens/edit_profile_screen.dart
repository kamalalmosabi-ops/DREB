import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isSaving = false;
  final String _baseUrl = "https://server-darb.runasp.net";

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الموجودة من البروفايل
    _nameController.text = widget.userData?['name'] ?? "";
    _emailController.text = widget.userData?['email'] ?? "";
    _phoneController.text = widget.userData?['phoneNumber'] ?? ""; // تأكد من اسم المفتاح في الـ API
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$_baseUrl/api/Customer/settings/profile/update'), // تأكد من رابط الـ Endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث البيانات بنجاح"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // العودة للخلف بعد النجاح
      } else {
        throw Exception("فشل الحفظ: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          title: const Text("تعديل الحساب", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFE79C24),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("الاسم الكامل", _nameController, Icons.person_outline),
                const SizedBox(height: 15),
                _buildTextField("البريد الإلكتروني", _emailController, Icons.email_outlined, isEmail: true),
                const SizedBox(height: 15),
                _buildTextField("رقم الهاتف", _phoneController, Icons.phone_android_outlined),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE79C24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("حفظ التغييرات", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE79C24)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (value) => value!.isEmpty ? "هذا الحقل مطلوب" : null,
    );
  }
}