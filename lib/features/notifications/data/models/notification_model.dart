class NotificationModel {
  final int id;
  final String title;
  final String body;
  final int category; // يمثل notificationType: 1 حجوزات, 2 تنبيهات...
  final DateTime createdAt;
  bool isRead;
  final String? companyLogo; // ✅ تمت الإضافة لعرض شعار الشركة المُرسِلة

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.companyLogo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      // ✅ نأخذ notificationType كما هو في السيرفر، وإذا لم يوجد نأخذ category كاحتياط
      category: json['notificationType'] ?? json['category'] ?? 1,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      // ✅ استخراج مسار اللوجو من كائن senderCompany
      companyLogo: json['senderCompany'] != null ? json['senderCompany']['logo'] : null,
    );
  }

  String get categoryName {
    switch (category) {
      case 1: return "حجوزات";
      case 2: return "تنبيهات إدارية";
      case 3: return "المدفوعات";
      default: return "أخرى";
    }
  }

  static List<NotificationModel> getFiltered(List<NotificationModel> list, String filter) {
    if (filter == "الكل") return list;
    return list.where((n) => n.categoryName == filter).toList();
  }

  static List<NotificationModel> get dummyNotifications => [
    NotificationModel(
      id: 1,
      title: "تأكيد حجز جديد",
      body: "تم تأكيد رحلتك من صنعاء إلى عدن بنجاح.",
      category: 1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];
}