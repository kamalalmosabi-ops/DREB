class NotificationModel {
  final int id;
  final String title;
  final String body;
  final int category; // 1: حجوزات, 2: تنبيهات إدارية, 3: المدفوعات
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  // تحويل البيانات من JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  // دالة لتحويل رقم التصنيف إلى نص يعرض في الواجهة
  String get categoryName {
    switch (category) {
      case 1: return "حجوزات";
      case 2: return "تنبيهات إدارية";
      case 3: return "المدفوعات";
      default: return "أخرى";
    }
  }

  // دالة مساعدة لفلترة القائمة بناءً على التبويب المختار
  static List<NotificationModel> getFiltered(List<NotificationModel> list, String filter) {
    if (filter == "الكل") return list;
    return list.where((n) => n.categoryName == filter).toList();
  }

  // يمكنك إضافة هذه القائمة للاختبار (Dummy Data)
  static List<NotificationModel> get dummyNotifications => [
    NotificationModel(
      id: 1,
      title: "تأكيد حجز جديد",
      body: "تم تأكيد رحلتك من صنعاء إلى عدن بنجاح.",
      category: 1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationModel(
      id: 2,
      title: "تنبيه إداري",
      body: "يرجى تحديث بيانات الملف الشخصي لضمان استمرارية الخدمة.",
      category: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
  ];
}