class BookingModel {
  final int id;
  final String statusName;
  final int statusId; // هام للتعامل مع الـ API
  final String companyName;
  final String fromStation;
  final String toStation;
  final String travelDate;
  final String travelTime;
  final double price;
  final String? rejectReason;
  final int numberOfSeats;

  BookingModel({
    required this.id,
    required this.statusName,
    required this.statusId,
    required this.companyName,
    required this.fromStation,
    required this.toStation,
    required this.travelDate,
    required this.travelTime,
    required this.price,
    this.rejectReason,
    required this.numberOfSeats,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      statusName: json['statusName'] ?? "",
      statusId: json['statusId'] ?? 0,
      companyName: json['companyName'] ?? "",
      fromStation: json['fromStation'] ?? "",
      toStation: json['toStation'] ?? "",
      travelDate: json['travelDate'] ?? "",
      travelTime: json['travelTime'] ?? "",
      price: (json['price'] ?? 0.0).toDouble(),
      rejectReason: json['rejectReason'],
      numberOfSeats: json['numberOfSeats'] ?? 1,
    );
  }
}