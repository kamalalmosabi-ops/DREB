import 'package:darb/features/home_search/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/auth/presentation/screens/login_screen.dart'; 
import 'package:darb/features/auth/presentation/screens/register_step1_screen.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 250, fit: BoxFit.contain),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A440),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(loc.translate('login'), style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 58,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterStep1Screen())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE6A440), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(loc.translate('create_account'), style: const TextStyle(fontSize: 18, color: Color(0xFFE6A440))),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen())),
                child: Text(loc.translate('browse_as_guest'), style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}