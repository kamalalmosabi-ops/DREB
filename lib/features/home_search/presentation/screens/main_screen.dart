import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:darb/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'package:darb/features/home_search/presentation/screens/companies_screen.dart';
import 'package:darb/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // البداية دائماً من شاشة "الرئيسية" (Index 3)
  int _currentIndex = 3;

  // تعريف الصفحات بنفس الترتيب الذي سيظهر في الـ BottomNavigationBar
  final List<Widget> _screens = [
    const ProfileScreen(),      // 0: حسابي
    const CompaniesScreen(),    // 1: الشركات
    const MyBookingsScreen(),   // 2: حجوزاتي
    const HomeScreen(),         // 3: الرئيسية
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // لا يسمح بالخروج من التطبيق إلا إذا كان المستخدم واقفاً بالفعل على شاشة "الرئيسية"
      canPop: _currentIndex == 3,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // إذا ضغط المستخدم زر الرجوع وهو في أي صفحة أخرى، يتم إرجاعه للرئيسية (3)
        setState(() {
          _currentIndex = 3;
        });
      },
      child: Scaffold(
        // IndexedStack يحافظ على حالة الصفحات (State) عند التنقل بينها
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              type: BottomNavigationBarType.fixed, // ضروري ليظهر الأيقونات والأسماء معاً
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFE79C24),
              unselectedItemColor: const Color(0xFF9CA3AF),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'حسابي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business_rounded),
                  label: 'الشركات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number_rounded),
                  label: 'حجوزاتي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'الرئيسية',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}