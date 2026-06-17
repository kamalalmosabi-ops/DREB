import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/onboarding/presentation/screens/welcome_screen.dart';

// استيراد مدير الإعدادات
import '../../../settings/presentation/providers/settings_provider.dart';
// استيراد قاموس الترجمة
import '../../../../core/localization/app_localizations.dart';

import 'account_data_screen.dart';
import 'security_privacy_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  
  bool _notificationsEnabled = true; 

  final String _baseUrl = "https://server-darb.runasp.net";

  // دالة ذكية لجلب اسم المستخدم الحقيقي بجميع الاحتمالات من السيرفر
  String get _getUserName {
    if (_userData == null) return "User Name";
    // إذا كانت البيانات داخل كائن فرعي اسمه data أو result
    final data = _userData!['data'] ?? _userData!['result'] ?? _userData!;
    return data['name']?.toString() ?? 
           data['Name']?.toString() ?? 
           data['fullName']?.toString() ?? 
           data['FullName']?.toString() ?? 
           data['userName']?.toString() ?? 
           "User Name";
  }

  // دالة ذكية لجلب البريد الإلكتروني   
  String get _getUserEmail {
    if (_userData == null) return "example@email.com";
    final data = _userData!['data'] ?? _userData!['result'] ?? _userData!;
    return data['email']?.toString() ?? 
           data['Email']?.toString() ?? 
           "example@email.com";
  }

  // دالة ذكية لجلب عدد الرحلات  
  String get _getTripsCount {
    if (_userData == null) return "0";
    final data = _userData!['data'] ?? _userData!['result'] ?? _userData!;
    return data['tripsCount']?.toString() ?? 
           data['TripsCount']?.toString() ?? 
           data['trips']?.toString() ?? 
           data['Trips']?.toString() ?? 
           "0";
  }

  // دالة ذكية لجلب النقاط  
  String get _getPointsCount {
    if (_userData == null) return "0";
    final data = _userData!['data'] ?? _userData!['result'] ?? _userData!;
    return data['points']?.toString() ?? 
           data['Points']?.toString() ?? 
           data['pointsCount']?.toString() ?? 
           data['PointsCount']?.toString() ?? 
           "0";
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _errorMessage = "يرجى تسجيل الدخول للوصول إلى الحساب";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/Customer/settings/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "خطأ في الاتصال: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ غير متوقع: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bool isDark = settings.isDark;

    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF6F8FB);
    final Color cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color primaryColor = const Color(0xFFE79C24); 

    // التأكد من أن المترجم جاهز
    final localizations = AppLocalizations.of(context);

    return Directionality(
      // تغيير اتجاه الشاشة بناءً على اللغة المختارة
      textDirection: settings.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : _errorMessage != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: textColor)),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: _buildStatsBar(cardColor, textColor),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(localizations?.translate('account_settings') ?? "إعدادات الحساب", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              
                              Container(
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    // تم تعديل الاسم هنا ليصبح باللغة العربية مباشرة وبشكل ثابت
                                    _menuTile(Icons.person_outline_rounded, "بيانات الحساب", textColor, subTextColor, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(userData: _userData)));
                                    }),
                                    _buildDivider(cardColor),
                                    _menuTile(Icons.lock_outline_rounded, localizations?.translate('security_privacy') ?? "الأمان والخصوصية", textColor, subTextColor, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()));
                                    }),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 25),
                              Text(localizations?.translate('app_preferences') ?? "تفضيلات التطبيق", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),

                              Container(
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    SwitchListTile(
                                      value: _notificationsEnabled,
                                      onChanged: (value) => setState(() => _notificationsEnabled = value),
                                      secondary: Icon(Icons.notifications_active_outlined, color: textColor),
                                      title: Text(localizations?.translate('notifications') ?? "الإشعارات", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                      activeTrackColor: primaryColor,
                                    ),
                                    _buildDivider(cardColor),
                                    ListTile(
                                      leading: Icon(Icons.language, color: textColor),
                                      title: Text(localizations?.translate('language') ?? "اللغة", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(settings.locale.languageCode == 'ar' ? "العربية" : "English", style: TextStyle(color: subTextColor, fontSize: 14)),
                                          const SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subTextColor),
                                        ],
                                      ),
                                      onTap: () {
                                        String newLang = settings.locale.languageCode == 'ar' ? 'en' : 'ar';
                                        settings.setLocale(newLang);
                                      },
                                    ),
                                    _buildDivider(cardColor),
                                    SwitchListTile(
                                      value: isDark,
                                      onChanged: (value) => settings.toggleTheme(),
                                      secondary: Icon(Icons.dark_mode_outlined, color: textColor),
                                      title: Text(localizations?.translate('dark_mode') ?? "الوضع الليلي", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                      activeTrackColor: primaryColor,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              Container(
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    _menuTile(Icons.headset_mic_outlined, localizations?.translate('support') ?? "الدعم الفني", textColor, subTextColor, () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                                    }),
                                    _buildDivider(cardColor),
                                    ListTile(
                                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                                      title: Text(localizations?.translate('logout') ?? "تسجيل الخروج", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subTextColor),
                                      onTap: () => _logout(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Center(child: Text("إصدار التطبيق 1.0.24", style: TextStyle(color: subTextColor, fontSize: 12))),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE79C24), Color(0xFFD18B1E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50), 
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 45, 
            backgroundColor: Colors.white24, 
            child: Icon(Icons.person, size: 45, color: Colors.white)
          ),
          const SizedBox(height: 15),
          Text(
            _getUserName, 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
          ),
          Text(
            _getUserEmail, 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem("الرحلات", _getTripsCount, Colors.blue, textColor), 
          Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
          _statItem("النقاط", _getPointsCount, const Color(0xFFE79C24), textColor), 
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color iconColor, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: iconColor)), 
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600))
      ]
    );
  }

  Widget _menuTile(IconData icon, String title, Color textColor, Color subTextColor, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subTextColor),
    );
  }

  Widget _buildDivider(Color cardColor) {
    return Divider(
      height: 1, 
      thickness: 1, 
      color: cardColor == Colors.white ? Colors.grey[100] : Colors.grey[800],
      indent: 55, 
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }
}