class BookingSuccessData {
  final int bookingId;
  final int ticketCount;
  final int totalAmount;
  final String status;

  BookingSuccessData({
    required this.bookingId,
    required this.ticketCount,
    required this.totalAmount,
    this.status = "قيد الانتظار", // الحالة الافتراضية عند الرفع لأول مرة
  });
}