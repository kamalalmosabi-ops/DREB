import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/core/utils/validators.dart'; 
import '../providers/auth_provider.dart';
import 'register_step1_screen.dart'; 
import 'forgot_password_screen.dart';
import '../../../home_search/presentation/screens/main_screen.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; 

  // متغيرات حفظ الأخطاء المخصصة لتظهر تحت الحقول مباشرة
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;

    final isDark = settings.isDark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final subTextColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);
    final tfFillColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl, // فرض التوجيه من اليمين لليسار بالكامل
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // البداية تعني اليمين في بيئة RTL
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topRight, 
                    child: _buildCircleBackButton(context)
                  ),
                  
                  const SizedBox(height: 40), 
                  
                  Text(loc.translate('welcome_back'), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 10),
                  Text(loc.translate('login_subtitle'), style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5)),
                  
                  const SizedBox(height: 40), 
                  
                  Text(loc.translate('email'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: _emailController,
                    textAlign: TextAlign.right,
                    validator: Validators.validateEmail,
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                    decoration: InputDecoration(
                      errorText: _emailError,
                      hintText: "example@email.com",
                      hintStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: tfFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  Text(loc.translate('password'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    textAlign: TextAlign.right,
                    validator: Validators.validatePassword,
                    style: TextStyle(color: textColor),
                    onChanged: (value) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                    decoration: InputDecoration(
                      errorText: _passwordError,
                      hintText: "********",
                      hintStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: tfFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                      suffixIcon: IconButton( // تم تحويل الأيقونة لليسار تلقائياً في الـ RTL لتناسب كلمة المرور
                        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _isObscure = !_isObscure),
                      ),
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment.centerLeft, 
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), 
                      child: Text(loc.translate('forgot_password_q'), style: const TextStyle(color: Color(0xFFE79C24), fontWeight: FontWeight.bold))
                    )
                  ),
                  
                  const SizedBox(height: 30),
                  authProvider.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
                    : SizedBox(
                        width: double.infinity, 
                        height: 58, 
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _emailError = null;
                              _passwordError = null;
                            });

                            if (_formKey.currentState!.validate()) {
                              bool success = await authProvider.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (!context.mounted) return;

                              if (success) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainScreen()),
                                  (route) => false, 
                                );
                              } else {
                                String serverError = authProvider.errorMessage ?? '';
                                setState(() {
                                  if (serverError.contains('user-not-found') || serverError.contains('no-user')) {
                                    _emailError = 'البريد الإلكتروني غير مسجل لدينا. المطلوب: تأكد من البيانات أو أنشئ حساباً.';
                                  } else if (serverError.contains('invalid-email')) {
                                    _emailError = 'صيغة البريد الإلكتروني غير صحيحة. المطلوب: كتابة بريد مألوف وصحيح.';
                                  } else if (serverError.contains('wrong-password') || serverError.contains('invalid-password')) {
                                    _passwordError = 'كلمة المرور غير صحيحة. المطلوب: فحص حالة الأحرف الكبيرة والصغيرة والأرقام.';
                                  } else if (serverError.contains('too-many-requests') || serverError.contains('locked')) {
                                    _passwordError = 'تم حظر الدخول مؤقتاً لكثرة المحاولات. المطلوب: الانتظار 5 دقائق ثم المحاولة.';
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.translate('invalid_credentials'))),
                                    );
                                  }
                                });
                              }
                            }
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE79C24), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ), 
                          child: Text(loc.translate('login'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))
                        )
                      ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Text(loc.translate('dont_have_account'), style: TextStyle(color: textColor)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterStep1Screen())), 
                        child: Text(loc.translate('new_register'), style: const TextStyle(color: Color(0xFFE79C24), fontWeight: FontWeight.bold))
                      ), 
                    ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBackButton(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(8), 
      decoration: const BoxDecoration(color: Color(0xFFE79C24), shape: BoxShape.circle), 
      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20) // سهم يشير للأمام في اليمين للعودة للخلف بالـ RTL
    )
  );
}