import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'package:darb/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:darb/features/home_search/presentation/screens/companies_screen.dart';
import 'package:darb/features/profile/presentation/screens/profile_screen.dart';

// استيراد الترجمة والدارك مود
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 3;

  final List<Widget> _screens = [
    const ProfileScreen(),      // 0: حسابي
    const CompaniesScreen(),    // 1: الشركات
    const MyBookingsScreen(),   // 2: حجوزاتي
    const HomeScreen(),         // 3: الرئيسية
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final isDark = settings.isDark;

    // ألوان شريط التنقل حسب الثيم
    final navBgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final unselectedColor = isDark ? Colors.grey[600] : const Color(0xFF9CA3AF);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05);

    return PopScope(
      canPop: _currentIndex == 3,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 3;
        });
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Directionality(
          // التأكد أن شريط التنقل يقلب اتجاهه مع اللغة
          textDirection: settings.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: navBgColor,
              selectedItemColor: const Color(0xFFE79C24),
              unselectedItemColor: unselectedColor,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: loc.translate('my_account'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.business_outlined),
                  activeIcon: const Icon(Icons.business_rounded),
                  label: loc.translate('companies_tab'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.confirmation_number_outlined),
                  activeIcon: const Icon(Icons.confirmation_number_rounded),
                  label: loc.translate('my_bookings_tab'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: loc.translate('home_tab'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}