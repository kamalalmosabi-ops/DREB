class Trip {
  final int id;
  final String companyName;
  final double rating;
  final int reviewsCount;
  final int price; // سنبقيها int كما ترغبين ولكن مع تحويل آمن في الـ factory
  final String departureTime;
  final String arrivalTime;
  final int seatsLeft;
  final String fromCity;
  final String toCity;
  final String period;
  
  // الحقول الإضافية المتوافقة مع الباكيند (Swagger)
  final int? busId;
  final String? departureDate;
  final List<TripRoute> routes; // لدعم مخطط الرحلة الديناميكي

  Trip({
    required this.id,
    required this.companyName,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatsLeft,
    required this.fromCity,
    required this.toCity,
    required this.period,
    this.busId,
    this.departureDate,
    required this.routes,
  });

  // 💡 الـ Getter الذكي الخاص بك لربط الحقول
  int get remainingSeats => seatsLeft;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      // الباكيند أحياناً يرجع اسم الشركة أو اسم المحافظة في حقول مخصصة، نضع قيم افتراضية ذكية
      companyName: json['companyName'] ?? json['company']?['name'] ?? "غير معروف",
      rating: (json['rating'] ?? json['company']?['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      
      // تحويل آمن للسعر في حال جاء من الباكيند كـ double
      price: (json['price'] ?? json['fare'] ?? 0).toInt(),
      
      departureTime: json['departureTime'] ?? json['time'] ?? "",
      arrivalTime: json['arrivalTime'] ?? "وصول متوقع",
      
      // الباكيند يعبر عن المقاعد المتبقية بالسعة أو حقل مخصص
      seatsLeft: json['seatsLeft'] ?? json['remainingSeats'] ?? json['capacity'] ?? 0,
      
      fromCity: json['fromCity'] ?? json['startGoveName'] ?? "",
      toCity: json['toCity'] ?? json['endGoveName'] ?? "",
      period: json['period']?.toString() ?? "",
      busId: json['busId'],
      departureDate: json['departureDate'],
      
      // عمل مابينج لمحطات التوقف القادمة من الـ API
      routes: json['routes'] != null
          ? (json['routes'] as List).map((i) => TripRoute.fromJson(i)).toList()
          : [],
    );
  }
}

// مودل فرعي خاص بمحطات التوقف (Trip Routes) حسب الـ API الخاص بالشركة
class TripRoute {
  final int id;
  final String stationName;
  final String departureTime;

  TripRoute({
    required this.id,
    required this.stationName,
    required this.departureTime,
  });

  factory TripRoute.fromJson(Map<String, dynamic> json) {
    return TripRoute(
      id: json['id'] ?? 0,
      stationName: json['stationName'] ?? json['station']?['address'] ?? "محطة توقف",
      departureTime: json['departureTime'] ?? "",
    );
  }
}