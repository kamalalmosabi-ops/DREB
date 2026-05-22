class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? token; // الـ Token الفريد لإثبات هوية المستخدم بعد الدخول

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.token,
  });

  // 1. تحويل البيانات القادمة من السيرفر (JSON) إلى كائن (UserModel Object) داخل التطبيق
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name'] ?? json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      token: json['token'] ?? json['jwtToken'], // يقرأ التوكن بأي صيغة يرسلها السيرفر
    );
  }

  // 2. تحويل كائن المستخدم إلى (JSON) إذا احتجنا لحفظ بياناته محلياً في الـ Shared Preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'token': token,
    };
  }
}