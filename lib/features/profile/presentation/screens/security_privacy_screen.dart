import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darb/features/onboarding/presentation/screens/welcome_screen.dart'; // تأكد من المسار

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  bool _isSaving = false;
  final String _baseUrl = "https://server-darb.runasp.net";

  // دالة تغيير كلمة المرور
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$_baseUrl/api/Customer/settings/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح"), backgroundColor: Colors.green));
        _currentPasswordController.clear();
        _newPasswordController.clear();
      } else {
        throw Exception("فشل التغيير: تحقق من كلمة المرور الحالية");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // دالة حذف الحساب
  Future<void> _deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/Customer/settings/delete-account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ أثناء حذف الحساب"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          title: const Text("الأمان والخصوصية"),
          backgroundColor: const Color(0xFFE79C24),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // قسم تغيير كلمة المرور
            ExpansionTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFFE79C24)),
              title: const Text("تغيير كلمة المرور", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Form(
                  key: _passwordFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "كلمة المرور الحالية", border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "كلمة المرور الجديدة", border: OutlineInputBorder()),
                          validator: (v) => v!.length < 6 ? "يجب أن تكون 6 خانات على الأقل" : null,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _changePassword,
                          child: _isSaving ? const CircularProgressIndicator() : const Text("تحديث"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // قسم الخصوصية
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text("سياسة الخصوصية"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () { /* رابط صفحة الويب */ },
            ),
            
            const Divider(),
            
            // قسم حذف الحساب (خطير)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("حذف الحساب نهائياً", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("تنبيه"),
                    content: const Text("هل أنت متأكد؟ سيتم مسح جميع بياناتك نهائياً."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                      TextButton(onPressed: _deleteAccount, child: const Text("حذف", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}