import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// استيرادات الميزات
import 'package:darb/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:darb/features/auth/presentation/providers/auth_provider.dart';
import 'package:darb/features/home_search/presentation/providers/home_provider.dart';
import 'package:darb/features/notifications/presentation/providers/notification_provider.dart';
import 'features/home_search/presentation/providers/trip_provider.dart';
import 'features/home_search/presentation/providers/company_provider.dart';
import 'features/home_search/presentation/providers/company_details_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    debugPrint("تم الاتصال بسيرفرات الفايربيس بنجاح !");
  } catch (e) {
    debugPrint("حدث خطأ أثناء الاتصال بالفايربيس: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => CompanyDetailsProvider()),
      ],
      child: const DarbApp(),
    ),
  );
}

class DarbApp extends StatelessWidget {
  const DarbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'درب للرحلات',
          locale: settings.locale,
          themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
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
          
          // البداية الآن هي صفحة الهوم
          home: const SplashScreen(), 
        );
      },
    );
  }
}

class SettingsProvider with ChangeNotifier {
  bool _isDark = false;
  Locale _locale = const Locale('ar');

  bool get isDark => _isDark;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadFromPrefs();
  }

  void toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  void setLocale(String langCode) async {
    _locale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', langCode);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    String lang = prefs.getString('languageCode') ?? 'ar';
    _locale = Locale(lang);
    notifyListeners();
  }
}