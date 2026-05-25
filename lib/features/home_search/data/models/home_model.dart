class SearchCardModel {
  final List<String> governorates;
  final List<String> companies;
  final List<String> periods;
  // إضافة الحقول الجديدة للبيانات التي سيجلبها السيرفر
  final List<dynamic> ads;
  final List<dynamic> companyLogos;

  SearchCardModel({
    required this.governorates,
    required this.companies,
    required this.periods,
    required this.ads,
    required this.companyLogos,
  });

  // هذه الدالة تحول الـ JSON القادم من السيرفر إلى مودل
  factory SearchCardModel.fromJson(Map<String, dynamic> json) {
    return SearchCardModel(
      governorates: List<String>.from(json['governorates'] ?? []),
      companies: List<String>.from(json['companies'] ?? []),
      periods: List<String>.from(json['periods'] ?? []),
      ads: json['ads'] ?? [],
      companyLogos: json['companyLogos'] ?? [],
    );
  }
}