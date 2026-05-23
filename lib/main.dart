import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // إذا وصل الكود لهذا السطر، فهذا يعني أن الربط تم بنجاح 100%
    debugPrint("تم الاتصال بسيرفرات الفايربيس بنجاح !");
  } catch (e) {
    // إذا فشل الربط لأي سبب، سيتم طباعة هذا الخطأ
    debugPrint(" حدث خطأ أثناء الاتصال بالفايربيس: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const DarbApp(),
    ),
  );
}

class DarbApp extends StatelessWidget {
  const DarbApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'درب للرحلات',
      locale: settings.locale,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      
      // ثيم التطبيق (مع التركيز على لون الهوية)
      theme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE6A440),
          primary: const Color(0xFFE6A440),
          brightness: Brightness.light,
        ),
      ),
      
      darkTheme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE6A440),
          primary: const Color(0xFFE6A440),
          brightness: Brightness.dark,
        ),
      ),

      home: const SplashScreen(), 
    );
  }
}

// مدير الإعدادات (نفس كودك السابق تماماً مع إضافة بسيطة للـ WidgetsBinding)
class SettingsProvider with ChangeNotifier {
  bool _isDark = false;
  Locale _locale = const Locale('ar');

  bool get isDark => _isDark;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadFromPrefs();
  }

  void toggleTheme(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', value);
  }

  void changeLanguage(String langCode) async {
    _locale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', langCode);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    String lang = prefs.getString('languageCode') ?? 'ar';
    _locale = Locale(lang);
    notifyListeners();
  }
}