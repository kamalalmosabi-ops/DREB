import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// =========================================================================
// الشاشة الأولى: الدعم الفني (Technical Support) - مخصصة للتواصل السريع والأسئلة الشائعة
// =========================================================================
class TechnicalSupportScreen extends StatelessWidget {
  const TechnicalSupportScreen({super.key});

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
      queryParameters: {'subject': 'طلب مساعدة - تطبيق درب'},
    );
    _launchURL(emailLaunchUri.toString());
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
              // الهيدر
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
                          "الدعم الفني",
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

                    const SizedBox(height: 30),

                    const Text("الأسئلة الشائعة:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    _buildFAQSection(context),

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

  Widget _buildFAQSection(BuildContext context) {
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
          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 20, endIndent: 20),
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
}

// =========================================================================
// الشاشة الثانية: الشكاوى (Complaints) - مخصصة لرفع الشكاوى عن الشركات والرحلات
// =========================================================================
class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tripIdController = TextEditingController();
  
  bool _isSending = false;
  bool _isLoadingCompanies = true; 
  bool _hasErrorFetching = false;   
  int? _selectedCompanyId; 

  List<Map<String, dynamic>> _companies = [];
  final String _baseUrl = "https://server-darb.runasp.net";

  @override
  void initState() {
    super.initState();
    _fetchCompanies(); 
  }

  Future<void> _fetchCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
      _hasErrorFetching = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // ✅ تم استخدام رابط الشركات الموثوق الذي يجلب البيانات بشكل صحيح
      final response = await http.get(
        Uri.parse('$_baseUrl/api/Customer/home/companies/avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); 

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
              // ✅ إضافة companyId لأن السيرفر يرسل الـ ID بهذا الاسم غالباً
              final dynamic rawId = item['companyId'] ?? item['id'] ?? item['Id'];
              final dynamic rawName = item['name'] ?? item['Name'];

              if (rawId != null && rawName != null) {
                final int? id = int.tryParse(rawId.toString());
                final String name = rawName.toString();

                if (id != null && !seenIds.contains(id)) {
                  seenIds.add(id);
                  serverCompanies.add({'id': id, 'name': name});
                }
              }
            }
          }

          if (mounted) {
            setState(() {
              _companies = serverCompanies;
              
              // التحقق مما إذا كان الـ ID المختار موجوداً في القائمة الجديدة
              if (_selectedCompanyId != null && !serverCompanies.any((c) => c['id'] == _selectedCompanyId)) {
                 _selectedCompanyId = null;
              }
              
              _isLoadingCompanies = false;
            });
            return;
          }
        }
      }
      
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
        _companies = []; 
      });
    }
  }

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
              // الهيدر
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
                          "تقديم شكوى",
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
                    const Text("هل واجهت مشكلة مع إحدى الشركات؟", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    _buildComplaintForm(primaryColor),
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
            if (_isLoadingCompanies)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF6F8FB), borderRadius: BorderRadius.circular(15)),
                child: const Row(
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE79C24))),
                    SizedBox(width: 15),
                    Text("جاري تحميل الشركات من السيرفر...", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              )
            else if (_hasErrorFetching)
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
              // ✅ التعديل هنا: استخدام value بدلاً من initialValue لحل مشكلة عدم التحديث
              DropdownButtonFormField<int>(
                value: _selectedCompanyId, 
                isExpanded: true, 
                hint: const Text("اختر الشركة المشغلة للرحلة", style: TextStyle(fontSize: 14, color: Colors.grey)),
                decoration: _inputDecoration("الشركة المشغلة للرحلة *", Icons.business_outlined),
                items: _companies.map<DropdownMenuItem<int>>((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                validator: (value) => value == null ? "يرجى تحديد الشركة لتقديم الشكوى" : null,
                onChanged: (val) {
                  setState(() {
                    _selectedCompanyId = val;
                  });
                },
              ),
              
            const SizedBox(height: 15),

            TextFormField(
              controller: _titleController,
              validator: (v) => v!.trim().isEmpty ? "يرجى كتابة عنوان للشكوى" : null,
              decoration: _inputDecoration("عنوان الشكوى (مثال: تأخر رحلة، سوء معاملة)", Icons.title_rounded),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _tripIdController,
              decoration: _inputDecoration("رقم الرحلة إن وجد (اختياري)", Icons.confirmation_number_outlined),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) => v!.trim().isEmpty ? "يرجى كتابة تفاصيل الشكوى" : null,
              decoration: _inputDecoration("اكتب تفاصيل الشكوى أو الرسالة هنا...", Icons.edit_note_rounded),
            ),
            
            const SizedBox(height: 25),
            
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
}