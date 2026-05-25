import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darb/features/onboarding/presentation/screens/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'my_reviews_screen.dart';
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

  final String _baseUrl = "https://server-darb.runasp.net";

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
            : _errorMessage != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatsBar(),
                        const SizedBox(height: 25),
                        _buildMenuSection(context),
                        _buildLogoutButton(context),
                        const SizedBox(height: 30),
                        Text("إصدار التطبيق 1.0.24", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        const SizedBox(height: 20),
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
            radius: 50, 
            backgroundColor: Colors.white24, 
            child: Icon(Icons.person, size: 50, color: Colors.white)
          ),
          const SizedBox(height: 15),
          Text(
            _userData?['name'] ?? " User Name ", 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
          ),
          Text(
            _userData?['email'] ?? "example@email.com", 
            style: TextStyle(color: Colors.black.withValues(alpha: 0.04), fontSize: 14)
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("الرحلات", "0", Colors.blue),
          _statItem("النقاط", "0", Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))]);
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _menuTile(Icons.person_outline_rounded, "تعديل الحساب", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(userData: _userData)));
          }),
          _menuTile(Icons.star_outline_rounded, "تقييماتي", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen()));
          }),
          _menuTile(Icons.lock_outline_rounded, "الأمان والخصوصية", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()));
          }),
          _menuTile(Icons.headset_mic_outlined, "الدعم الفني", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
          }),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFE79C24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: TextButton.icon(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}