class Validators {
  // ignore: deprecated_member_use
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  // ignore: deprecated_member_use
  static final RegExp _phoneRegex = RegExp(r'^[0-9]{9,10}$');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف أو أكثر';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    // الاستدعاء هنا أصبح مباشر ونظيف جداً
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }
    // الاستدعاء هنا أصبح مباشر ونظيف جداً
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'رقم الجوال يجب أن يكون 9 أو 10 أرقام';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن لا تقل عن 6 خانات';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رمز التحقق';
    }
    if (value.trim().length < 4 || value.trim().length > 6) {
      return 'رمز التحقق يجب أن يكون بين 4 و 6 أرقام';
    }
    return null;
  }
}