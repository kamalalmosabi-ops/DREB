import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  final String _baseUrl = "https://server-darb.runasp.net";

  // دالة إرسال التذكرة للباك إند
  Future<void> _sendTicket() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى كتابة رسالتك أولاً")));
      return;
    }

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/Customer/support/ticket'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'message': _messageController.text,
          'subject': 'رسالة دعم من التطبيق',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال رسالتك بنجاح، سيتم الرد عليك قريباً"), backgroundColor: Colors.green));
        _messageController.clear();
      } else {
        throw Exception("فشل الإرسال");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ، يرجى المحاولة لاحقاً"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSending = false);
    }
  }

  // دالة فتح الروابط الخارجية
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا يمكن فتح هذا الرابط")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(title: const Text("الدعم الفني"), backgroundColor: const Color(0xFFE79C24)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("كيف يمكننا مساعدتك اليوم؟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // وسائل التواصل
              _buildContactItem(Icons.phone, "اتصال هاتفي", "0500000000", () => _launchURL("tel:+966500000000")),
              _buildContactItem(Icons.email, "البريد الإلكتروني", "support@darb.com", () => _launchURL("mailto:support@darb.com")),
              
              const SizedBox(height: 30),
              
              // نموذج الإرسال
              const Align(alignment: Alignment.centerRight, child: Text("أو أرسل رسالة لنا:", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "اكتب تفاصيل مشكلتك هنا...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendTicket,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isSending ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال الرسالة", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE79C24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}