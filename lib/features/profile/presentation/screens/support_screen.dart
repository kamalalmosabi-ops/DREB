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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tripIdController = TextEditingController();
  
  bool _isSending = false;
  bool _isLoadingCompanies = true; // مؤشر لحالة جلب البيانات من السيرفر
  bool _hasErrorFetching = false;   // مؤشر في حال فشل الاتصال بالسيرفر
  int? _selectedCompanyId; 

  // جعل القائمة فارغة تماماً لكي لا تعرض إلا الشركات القادمة من السيرفر مباشرة
  List<Map<String, dynamic>> _companies = [];

  final String _baseUrl = "https://server-darb.runasp.net";

  @override
  void initState() {
    super.initState();
    _fetchCompanies(); // طلب الشركات من السيرفر فوراً عند بناء الشاشة
  }

  // دالة جلب الشركات الاحترافية من السيرفر مباشرة
  Future<void> _fetchCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
      _hasErrorFetching = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/Customer/companies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 7)); // إعطاء السيرفر وقت كافٍ للاستجابة

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> fetchedList = [];
        
        if (decodedData is List) {
          fetchedList = decodedData;
        } else if (decodedData is Map && decodedData['data'] != null) {
          fetchedList = decodedData['data'];
        }

        if (fetchedList.isNotEmpty) {
          final List<Map<String, dynamic>> serverCompanies = [];
          final Set<int> seenIds = {};
          
          for (var item in fetchedList) {
            if (item is Map) {
              // معالجة مرنة لحالة الأحرف (PascalCase / camelCase) لضمان القراءة من ASP.NET
              final dynamic rawId = item['id'] ?? item['Id'] ?? item['ID'];
              final dynamic rawName = item['name'] ?? item['Name'] ?? item['NAME'];

              if (rawId != null && rawName != null) {
                final int? id = int.tryParse(rawId.toString());
                final String name = rawName.toString();

                if (id != null && !seenIds.contains(id)) {
                  seenIds.add(id);
                  serverCompanies.add({
                    'id': id,
                    'name': name,
                  });
                }
              }
            }
          }

          if (mounted) {
            setState(() {
              _companies = serverCompanies;
              _isLoadingCompanies = false;
            });
            return;
          }
        }
      }
      
      // إذا لم تكن الاستجابة 200 أو كانت القائمة فارغة
      _handleFetchError();

    } catch (e) {
      debugPrint("خطأ أثناء الاتصال بالسيرفر لجلب الشركات: $e");
      _handleFetchError();
    }
  }

  void _handleFetchError() {
    if (mounted) {
      setState(() {
        _isLoadingCompanies = false;
        _hasErrorFetching = true;
        _companies = []; // إبقاء القائمة فارغة لضمان عدم عرض بيانات خاطئة
      });
    }
  }

  // إرسال الشكوى للسيرفر
  Future<void> _sendTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      const String urlPath = '/api/Customer/complaints/company';

      String finalDescription = _descriptionController.text.trim();
      if (_tripIdController.text.trim().isNotEmpty) {
        finalDescription += "\n\n[رقم الرحلة المرتبطة: ${_tripIdController.text.trim()}]";
      }

      final Map<String, dynamic> requestBody = {
        'title': _titleController.text.trim(),
        'description': finalDescription,
        'companyId': _selectedCompanyId, 
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$urlPath'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        body: json.encode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إرسال بلاغك بنجاح، فريقنا سيراجعه فوراً 👍"), backgroundColor: Colors.green),
        );
        _titleController.clear();
        _descriptionController.clear();
        _tripIdController.clear();
        setState(() {
          _selectedCompanyId = null;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الإرسال، يرجى المحاولة لاحقاً"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmailApp() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@darb.com',
      queryParameters: {'subject': 'طلب دعم / شكوى - تطبيق درب'},
    );
    _launchURL(emailLaunchUri.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tripIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE79C24);
    const Color bgColor = Color(0xFFF6F8FB);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // الهيدر المقوس الذهبي
              Container(
                width: double.infinity,
                height: 135,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE79C24), Color(0xFFD18B1E)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "الدعم الفني والشكاوى",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    
                    const Text("تواصل مباشر معنا:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQuickContact(Icons.phone_in_talk_rounded, "اتصال", () => _launchURL("tel:+967000000")),
                        _buildQuickContact(Icons.chat_bubble_rounded, "واتساب", () => _launchURL("https://wa.me/967000000")),
                        _buildQuickContact(Icons.mail_rounded, "إيميل", _openEmailApp),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text("أرسل لنا تفاصيل مشكلتك:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    _buildComplaintForm(primaryColor),

                    const SizedBox(height: 25),

                    const Text("الأسئلة الشائعة:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    _buildFAQSection(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickContact(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(15), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10, 
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFE79C24), size: 24),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10, 
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // إدارة عرض حقل الشركات بناءً على حالة الجلب من السيرفر
            if (_isLoadingCompanies)
              // 1. حالة التحميل من السيرفر
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE79C24))),
                    SizedBox(width: 15),
                    Text("جاري تحميل الشركات من السيرفر...", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              )
            else if (_hasErrorFetching)
              // 2. حالة حدوث خطأ أو انقطاع الاتصال بالسيرفر (إمكانية إعادة المحاولة)
              InkWell(
                onTap: _fetchCompanies,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 12),
                          Text("فشل جلب الشركات. اضغط لإعادة المحاولة", style: TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 20),
                    ],
                  ),
                ),
              )
            else
              // 3. الحالة الناجحة: عرض الحقل المربوط بالسيرفر 100% بدون أي تزوير محلي
              DropdownButtonFormField<int>(
                key: ValueKey(_companies.hashCode), 
                initialValue: _selectedCompanyId, 
                isExpanded: true, 
                hint: const Text("اختر الشركة المشغلة للرحلة", style: TextStyle(fontSize: 14, color: Colors.grey)),
                decoration: _inputDecoration("الشركة المشغلة للرحلة *", Icons.business_outlined),
                items: _companies.map<DropdownMenuItem<int>>((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return "يرجى تحديد الشركة لتقديم الشكوى";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _selectedCompanyId = val;
                  });
                },
              ),
              
            const SizedBox(height: 15),

            // حقل عنوان الشكوى
            TextFormField(
              controller: _titleController,
              validator: (v) => v!.trim().isEmpty ? "يرجى كتابة عنوان للشكوى" : null,
              decoration: _inputDecoration("عنوان الشكوى (مثال: تأخر رحلة، سوء معاملة)", Icons.title_rounded),
            ),
            const SizedBox(height: 15),

            // حقل رقم الرحلة
            TextFormField(
              controller: _tripIdController,
              decoration: _inputDecoration("رقم الرحلة إن وجد (اختياري)", Icons.confirmation_number_outlined),
            ),
            const SizedBox(height: 15),

            // حقل تفاصيل الشكوى
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) => v!.trim().isEmpty ? "يرجى كتابة تفاصيل الشكوى" : null,
              decoration: _inputDecoration("اكتب تفاصيل الشكوى أو الرسالة هنا...", Icons.edit_note_rounded),
            ),
            
            const SizedBox(height: 25),
            
            // زر الإرسال المتفاعل
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSending 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("إرسال الشكوى", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10, 
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: _buildFAQItem(
              "كيفية إلغاء الحجز وكيف أسترجع أموالي؟", 
              "إلغاء الحجز يتم عبر الانتقال لشاشة 'حجوزاتي' وإرسال طلب إلغاء، حيث يتطلب هذا الإجراء موافقة الشركة المشغلة للرحلة أولاً ليتم إلغاء الحجز بشكل رسمي بعد موافقتهم. أما بالنسبة لاسترجاع المبالغ المالية المدفوعة، فيتم ذلك حصراً من خلال التواصل مباشرة مع فريق الدعم الفني الخاص بنا بالتطبيق، أو عبر زيارة أحد الفروع الرسمية التابعة للشركة المشغلة للرحلة."
            ),
          ),
          _buildDivider(),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: _buildFAQItem(
              "ماذا أفعل إذا تأخرت الحافلة عن موعدها؟", 
              "في حال تأخر انطلاق الحافلة عن الموعد المحدد المدون في التذكرة، يرجى منك التوجه فوراً للتواصل مع الدعم الفني للتطبيق عبر قنوات الاتصال المتاحة بأعلى الصفحة لإبلاغنا بالتأخير الحاصل ومتابعة حالة الرحلة فقط."
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      iconColor: const Color(0xFFE79C24),
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20), 
          child: Text(
            a, 
            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        )
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFE79C24), size: 20),
      filled: true,
      fillColor: const Color(0xFFF6F8FB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 20, endIndent: 20);
}