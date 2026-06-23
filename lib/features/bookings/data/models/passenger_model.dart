class PassengerModel {
  String fullName;
  String nationalId;
  String phoneNumber;
  String birthDate; // صيغة دقيقة YYYY-MM-DD كما يطلبها السيرفر

  PassengerModel({
    this.fullName = '',
    this.nationalId = '',
    this.phoneNumber = '',
    this.birthDate = '2000-01-01', // قيمة افتراضية يتم تحديثها من الواجهة
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "nationalId": nationalId,
      "phoneNumber": phoneNumber,
      "birthDate": birthDate,
    };
  }
}

class BookingRequestModel {
  int tripRouteId;
  List<PassengerModel> additionalPassengers;

  BookingRequestModel({
    required this.tripRouteId,
    required this.additionalPassengers,
  });

  Map<String, dynamic> toJson() {
    return {
      "tripRouteId": tripRouteId,
      "additionalPassengers": additionalPassengers.map((p) => p.toJson()).toList(),
    };
  }
}