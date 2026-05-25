class Company {
  final int? id;
  final String name;
  final double rating;
  final int totalTrips;
  final String? logoUrl;

  Company({
    this.id,
    required this.name,
    required this.rating,
    required this.totalTrips,
    this.logoUrl,
  });

  // دالة تحويل الـ JSON القادم من السيرفر إلى كائن كود
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? json['companyId'],
      name: json['name'] ?? json['companyName'] ?? 'شركة نقل',
      rating: (json['rating'] ?? json['averageRating'] ?? 4.5).toDouble(),
      totalTrips: json['totalTrips'] ?? json['tripsCount'] ?? 0,
      logoUrl: json['logoUrl'] ?? json['avatar'] ?? json['logo'],
    );
  }
}