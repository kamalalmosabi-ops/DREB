import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/core/utils/validators.dart'; 
import '../providers/auth_provider.dart';
import 'register_step1_screen.dart'; 
import 'forgot_password_screen.dart';
import '../../../home_search/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topRight, 
                  child: _buildCircleBackButton(context)
                ),
                
                const SizedBox(height: 40), 
                
                const Text("!مرحباً بعودتك", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D1B3E))),
                const SizedBox(height: 10),
                const Text("سجل دخولك لمتابعة حجوزاتك مع درب.", textAlign: TextAlign.right, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
                
                // هنا أضفنا مسافة أكبر بين الوصف وأول ليبل
                const SizedBox(height: 40), 
                
                const Text("البريد الإلكتروني", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  textAlign: TextAlign.right,
                  validator: Validators.validateEmail,
                  decoration: _inputDecoration("example@email.com"),
                ),
                
                const SizedBox(height: 25),
                const Text("كلمة المرور", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.right,
                  validator: Validators.validatePassword,
                  decoration: _inputDecoration("********"),
                ),
                
                Align(
                  alignment: Alignment.centerLeft, 
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), 
                    child: const Text("نسيت كلمة المرور؟", style: TextStyle(color: Color(0xFFE79C24), fontWeight: FontWeight.bold))
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
                          if (_formKey.currentState!.validate()) {
                            bool success = await authProvider.login(
                              _emailController.text.trim(), 
                              _passwordController.text.trim()
                            );
                            
                            if (success && mounted) {
                              Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (context) => const HomeScreen())
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("بيانات الدخول غير صحيحة"))
                              );
                            }
                          }
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE79C24), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ), 
                        child: const Text("تسجيل الدخول", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))
                      )
                    ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterStep1Screen())), 
                      child: const Text("تسجيل جديد", style: TextStyle(color: Color(0xFFE79C24), fontWeight: FontWeight.bold))
                    ), 
                    const Text("  ليس لديك حساب؟ ")
                  ]
                ),
              ],
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
      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20)
    )
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint, 
    filled: true, 
    fillColor: const Color(0xFFF9FAFB), 
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15), 
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
  );
}