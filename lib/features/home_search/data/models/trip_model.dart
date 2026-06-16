class Trip {
  final int tripId;
  final int companyId;
  final String companyName;
  final String companyLogo;
  final double rating;
  final int reviewsCount;
  final String fromCity;
  final String toCity;
  final double price;
  final String departureDate;
  final String departureTime;
  final String arrivalTime;
  final int seatsLeft;
  final String period;

  Trip({
    required this.tripId,
    required this.companyId,
    required this.companyName,
    required this.companyLogo,
    required this.rating,
    required this.reviewsCount,
    required this.fromCity,
    required this.toCity,
    required this.price,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatsLeft,
    required this.period,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'] ?? 0,
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? 'شركة نقل غير معروفة',
      companyLogo: json['companyLogo'] ?? '',
      rating: (json['companyRating'] ?? 0).toDouble(),
      reviewsCount: 0, // السيرفر لا يرسل عدد التقييمات حالياً، نضعها 0
      fromCity: json['startGoveName'] ?? 'غير محدد', 
      toCity: json['endGoveName'] ?? 'غير محدد',     
      price: (json['basePrice'] ?? 0).toDouble(),    
      departureDate: json['departureDate'] ?? '',
      departureTime: json['period'] ?? '00:00', // نستخدم الفترة مؤقتاً لوقت الانطلاق
      arrivalTime: '', 
      seatsLeft: json['availableSeats'] ?? 0,        
      period: json['period'] ?? '',
    );
  }
}