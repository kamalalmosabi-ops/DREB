import 'package:flutter/material.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart';
import 'package:darb/features/auth/presentation/screens/register_step1_screen.dart';
import 'package:darb/features/home_search/presentation/screens/home_screen.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              
              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A440),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("تسجيل الدخول", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // زر إنشاء حساب
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterStep1Screen())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE6A440), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("إنشاء حساب جديد", style: TextStyle(fontSize: 18, color: Color(0xFFE6A440))),
                ),
              ),

              const SizedBox(height: 15),

              // تصفح كزائر
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                child: const Text("تصفح كزائر", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}