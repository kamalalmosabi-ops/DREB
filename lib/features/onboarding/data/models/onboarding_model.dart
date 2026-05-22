// مسار الملف المقترح: lib/features/onboarding/data/models/onboarding_model.dart

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingData {
  // استخدام List<OnboardingContent> كقائمة ثابتة للبيانات
  static const List<OnboardingContent> contents = [
    OnboardingContent(
      title: "احجز رحلتك",
      description: "ابحث عن رحلاتك إلى وجهتك المفضلة واحجز تذكرتك.",
      image: "assets/images/onboarding1.png",
    ),
    OnboardingContent(
      title: "خطط مسارك",
      description: "استكشف المسارات والمواعيد وتفاصيل الحافلات المتاحة في أي وقت.",
      image: "assets/images/onboarding2.png",
    ),
    OnboardingContent(
      title: "دفع آمن وسريع",
      description: "خيارات دفع متعددة آمنة واستلم تذكرتك فوراً على هاتفك الذكي.",
      image: "assets/images/onboarding3.jpg", // تأكدي من صيغة الملف (png أو jpg)
    ),
  ];
}