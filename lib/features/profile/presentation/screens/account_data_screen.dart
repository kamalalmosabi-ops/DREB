import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfileScreen({super.key, this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // التحكم في الحقول (للعرض فقط)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController(); // حقل رقم الهوية الجديد
  final TextEditingController _cityController = TextEditingController();     // حقل المدينة الجديد

  @override
  void initState() {
    super.initState();
    // استخراج البيانات بذكاء مع دعم كل احتمالات التسمية من السيرفر
    final data = widget.userData?['data'] ?? widget.userData?['result'] ?? widget.userData ?? {};
    
    _nameController.text = data['name']?.toString() ?? 
                           data['Name']?.toString() ?? 
                           data['fullName']?.toString() ?? 
                           data['FullName']?.toString() ?? "غير محدد";
                           
    _emailController.text = data['email']?.toString() ?? 
                            data['Email']?.toString() ?? "غير محدد";
                            
    _phoneController.text = data['phoneNumber']?.toString() ?? 
                            data['PhoneNumber']?.toString() ?? 
                            data['phone']?.toString() ?? 
                            data['Phone']?.toString() ?? "غير محدد";

    // جلب رقم الهوية من السيرفر (يدعم مسميات مختلفة المتوقعة من الباك إيند)
    _idNumberController.text = data['idNumber']?.toString() ?? 
                               data['identityNumber']?.toString() ?? 
                               data['nationalId']?.toString() ?? 
                               data['nationalID']?.toString() ?? "غير محدد";

    // جلب المدينة من السيرفر
    _cityController.text = data['city']?.toString() ?? 
                           data['City']?.toString() ?? "غير محدد";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          toolbarHeight: 80, 
          title: const Text(
            "بيانات الحساب",  // تم تغيير العنوان ليتناسب مع العرض فقط
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold) 
          ),
          centerTitle: true, 
          backgroundColor: const Color(0xFFE79C24),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), 
            onPressed: () => Navigator.pop(context),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), 
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل الاسم الكامل
              _buildFieldLabel("الاسم الكامل"),
              _buildReadOnlyField(_nameController, Icons.person_outline),
              const SizedBox(height: 20),
              
              // حقل البريد الإلكتروني
              _buildFieldLabel("البريد الإلكتروني"),
              _buildReadOnlyField(_emailController, Icons.email_outlined),
              const SizedBox(height: 20),
              
              // حقل رقم الهاتف
              _buildFieldLabel("رقم الهاتف"),
              _buildReadOnlyField(_phoneController, Icons.phone_android_outlined),
              const SizedBox(height: 20),

              // حقل رقم الهوية الجديد القادم من السيرفر
              _buildFieldLabel("رقم الهوية"),
              _buildReadOnlyField(_idNumberController, Icons.badge_outlined),
              const SizedBox(height: 20),

              // حقل المدينة الجديد القادم من السيرفر
              _buildFieldLabel("المدينة"),
              _buildReadOnlyField(_cityController, Icons.location_city_outlined),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت عنوان الحقل
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0D1B3E),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // بناء حقل نصي مخصص للقراءة فقط بشكل أنيق ومريح للعين
  Widget _buildReadOnlyField(TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true, // جعل الحقل للقراءة فقط ومنع إدخال النص
      enabled: false,  // إيقاف التفاعل لتبدو الشاشة كعرض بيانات مستقرة
      style: const TextStyle(fontSize: 15, color: Color(0xFF556080), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE79C24).withValues(alpha: 0.7), size: 22),
        filled: true,
        fillColor: Colors.white, // خلفية بيضاء نظيفة
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}