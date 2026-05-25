import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  final String _baseUrl = "https://server-darb.runasp.net";

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // تأكد من رابط الـ API الصحيح لجلب التقييمات
      final response = await http.get(
        Uri.parse('$_baseUrl/api/Customer/my-reviews'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _reviews = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "فشل في جلب التقييمات: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ في الاتصال: $e";
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
        appBar: AppBar(
          title: const Text("تقييماتي"),
          backgroundColor: const Color(0xFFE79C24),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _reviews.isEmpty
                    ? const Center(child: Text("لا توجد تقييمات حالياً"))
                    : RefreshIndicator(
                        onRefresh: _fetchReviews,
                        color: const Color(0xFFE79C24),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return _buildReviewCard(review);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['companyName'] ?? "غير معروف", // تأكد من اسم الحقل في الباك اند
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Text("${review['rating'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review['comment'] ?? "لا يوجد تعليق",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              review['date'] ?? "", // تأكد من صيغة التاريخ
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}