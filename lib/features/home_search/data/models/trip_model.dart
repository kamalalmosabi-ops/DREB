class Trip {
  final int tripId;
  final int companyId;
  final double price;
  final String fromCity;
  final String toCity;
  final String departureTime;
  final String arrivalTime; // ✅ هذا هو المتغير الذي يشتكي منه البرنامج
  final int seatsLeft;
  final String companyName;
  final String companyLogo;
  final double rating;

  Trip({
    required this.tripId,
    required this.companyId,
    required this.price,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.arrivalTime, // ✅ تم التأكد من وجوده
    required this.seatsLeft,
    this.companyName = '',
    this.companyLogo = '',
    this.rating = 0.0,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'] ?? 0,
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      rating: (json['companyRating'] ?? 0).toDouble(),
      fromCity: json['startGoveName'] ?? '',
      toCity: json['endGoveName'] ?? '',
      price: (json['basePrice'] ?? 0).toDouble(),
      departureTime: json['departureDate'] ?? '', 
      arrivalTime: json['period'] ?? '', // نربط فترة الرحلة بـ arrivalTime
      seatsLeft: json['availableSeats'] ?? 0,
    );
  }
}

class TripStation {
  final int tripRouteId;
  final String departureTime;
  final String cityName;
  final String address;
  final double seatFare;

  TripStation({
    required this.tripRouteId,
    required this.departureTime,
    required this.cityName,
    required this.address,
    required this.seatFare,
  });

  factory TripStation.fromJson(Map<String, dynamic> json) {
    return TripStation(
      tripRouteId: json['tripRouteId'] ?? 0,
      departureTime: json['departureTime'] ?? '',
      cityName: json['cityName'] ?? '',
      address: json['address'] ?? '',
      seatFare: (json['seatFare'] ?? 0).toDouble(),
    );
  }
}