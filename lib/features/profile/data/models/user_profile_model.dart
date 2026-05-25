class UserProfile {
  final String name;
  final String phone;
  final String address;
  final String email;

  UserProfile({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'مستخدم',
      phone: json['phone'] ?? 'لا يوجد',
      address: json['address'] ?? 'غير محدد',
      email: json['email'] ?? 'لا يوجد',
    );
  }
}