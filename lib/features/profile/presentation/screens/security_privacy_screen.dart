import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darb/features/onboarding/presentation/screens/welcome_screen.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final String _baseUrl = "https://server-darb.runasp.net";

  // دالة تغيير كلمة المرور والاتصال بالسيرفر
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // ✅ التعديل هنا: استخدام المسار الصحيح حسب الـ Swagger
      final response = await http.put(
        Uri.parse('$_baseUrl/api/Auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // ✅ التعديل هنا: استخدام oldPassword بدلاً من currentPassword
        body: json.encode({
          'oldPassword': _currentPasswordController.text.trim(),
          'newPassword': _newPasswordController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح 🔐"), backgroundColor: Colors.green),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        throw Exception("فشل التغيير: يرجى التحقق من كلمة المرور الحالية");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e".replaceAll("Exception: ", "")), backgroundColor: Colors.red),
      );
    } finally { 
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // دالة حذف الحساب نهائياً من السيرفر
  Future<void> _deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/Customer/settings/delete-account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await prefs.remove('auth_token');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      } else {
        throw Exception("فشل في حذف الحساب من السيرفر");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء حذف الحساب"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE79C24);
    const Color bgColor = Color(0xFFF6F8FB);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر المطور والمصغر باستخدام Stack لضبط المحاذاة بشكل كامل 100%
              Container(
                width: double.infinity,
                height: 135, // حجم مصغر ومثالي للهيدر المقوس
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE79C24), Color(0xFFD18B1E)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // عنوان الصفحة في المنتصف الهندسي تماماً وبخط أبيض عريض
                      const Center(
                        child: Text(
                          "الأمان والخصوصية",
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // سهم العودة لليمين مثبت بدقة في جهة اليمين المتوافقة مع الـ RTL
                      Positioned(
                        right: 15,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // محتوى الصفحة الرئيسي باللغة العربية بالكامل
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // قسم تغيير كلمة المرور
                    const Text(
                      "تغيير كلمة المرور",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Form(
                        key: _passwordFormKey,
                        child: Column(
                          children: [
                            _buildPasswordField(
                              controller: _currentPasswordController,
                              label: "كلمة المرور الحالية",
                              obscureText: _obscureCurrent,
                              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: "كلمة المرور الجديدة",
                              obscureText: _obscureNew,
                              onToggle: () => setState(() => _obscureNew = !_obscureNew),
                              validator: (v) => v!.length < 6 ? "يجب أن تكون 6 خانات على الأقل" : null,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: "تأكيد كلمة المرور الجديدة",
                              obscureText: _obscureConfirm,
                              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              validator: (v) => v != _newPasswordController.text ? "كلمة المرور غير متطابقة" : null,
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("تحديث كلمة المرور", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // قسم السياسات والشروط المنسدلة
                    const Text(
                      "السياسات والشروط",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: const Icon(Icons.privacy_tip_outlined, color: primaryColor),
                              title: const Text("سياسة الخصوصية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              iconColor: primaryColor,
                              collapsedIconColor: Colors.grey,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  child: Text(
                                    "نحن في تطبيق 'درب' نلتزم بحماية خصوصيتك وأمن بياناتك الشخصية. نقوم بجمع المعلومات الأساسية مثل الاسم، رقم الهاتف، والبريد الإلكتروني فقط لتسهيل عمليات حجز تذاكر الحافلات، تنظيم الرحلات، وتوفير الدعم الفني اللازم لك. نقوم بتشفير كافة البيانات الحساسة ولا يتم مشاركتها مع أي أطراف ثالثة خارج نطاق مشغلي الرحلات المعتمدين لتأكيد حجزك.",
                                    style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                                    textAlign: TextAlign.justify,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 50),
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: const Icon(Icons.gavel_rounded, color: primaryColor),
                              title: const Text("الشروط والأحكام", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              iconColor: primaryColor,
                              collapsedIconColor: Colors.grey,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  child: Text(
                                    "باستخدامك لتطبيق 'درب'، فإنك توافق على الالتزام بالشروط الآتية: يجب إدخال بيانات صحيحة ومطابقة للهوية الشخصية عند حجز أي رحلة. يحق للمستخدم إلغاء أو تعديل التذاكر وفقاً للسياسة الزمنية والمالية المحددة من قِبل الشركات المشغلة للرحلات. يُخلي التطبيق مسؤوليته عن أي تأخير خارج عن الإرادة ناتج عن ظروف الطرق أو الجهات التشغيلية.",
                                    style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                                    textAlign: TextAlign.justify,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // إجراءات الحساب الحساسة
                    const Text(
                      "إجراءات الحساب",
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                        title: const Text("حذف الحساب نهائياً", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text("تنبيه هام"),
                                content: const Text("هل أنت متأكد من رغبتك في حذف الحساب؟ سيتم مسح جميع بياناتك، النقاط، وسجل الرحلات نهائياً ولا يمكن استعادتها."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteAccount();
                                    },
                                    child: const Text("تأكيد الحذف", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator ?? (value) => value!.isEmpty ? "هذا الحقل مطلوب" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFE79C24), size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF6F8FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}