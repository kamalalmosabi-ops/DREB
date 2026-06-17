import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/company_model.dart'; 
import '../providers/company_provider.dart';  
import 'company_details_screen.dart'; 

// استيراد الترجمة والدارك مود
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProvider>(context, listen: false).fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';

    const primaryColor = Color(0xFFE79C24);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FD);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildStandardHeader(context, primaryColor, loc, isAr), // ✅ تم تمرير اتجاه اللغة للفحص
            Expanded(
              child: Consumer<CompanyProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (provider.companies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_rounded, size: 60, color: textColor.withValues(alpha: 0.3)),
                          const SizedBox(height: 10),
                          Text(loc.translate('no_companies_available'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 45, crossAxisSpacing: 15, childAspectRatio: 0.72,
                    ),
                    itemCount: provider.companies.length,
                    itemBuilder: (context, index) =>
                        _buildUltimateCompanyCard(context, provider.companies[index], primaryColor, textColor, cardColor, loc),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تعديل الهيدر ليفحص إمكانية الرجوع ويظهر السهم فقط عند الدخول من الصفحة الرئيسية
  Widget _buildStandardHeader(BuildContext context, Color primaryColor, AppLocalizations loc, bool isAr) {
    // التحقق التلقائي: هل الشاشة مفتوحة فوق شاشة أخرى ويمكن الرجوع؟
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      height: 135, // تم تعديل الارتفاع قليلاً ليعطي مساحة مريحة للـ Stack والـ SafeArea
      width: double.infinity,
      decoration: BoxDecoration( 
        color: primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // يظهر زر السهم فقط إذا جاء المستخدم من شاشة "عرض المزيد" في الصفحة الرئيسية
            if (canPop)
              Positioned(
                right: isAr ? 15 : null,
                left: isAr ? null : 15,
                child: IconButton(
                  icon: Icon(
                    isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // العودة الآمنة للصفحة الرئيسية
                  },
                ),
              ),
            // نصوص الهيدر تظل متمردة ومستقرة في المنتصف دائماً
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.translate('transport_companies'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(loc.translate('choose_travel_partner'), style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimateCompanyCard(BuildContext context, Company company, Color primary, Color textColor, Color cardColor, AppLocalizations loc) {
    return Stack(
      clipBehavior: Clip.none, alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 35),
                Text(company.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    Text(" ${company.rating}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                    const SizedBox(width: 8),
                    Text("| ${company.totalTrips} ${loc.translate('trip_word')}", style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyDetailsScreen(company: company)));
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(15)),
                    child: Center(child: Text(loc.translate('explore'), style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -28,
          child: Container(
            height: 70, width: 70,
            decoration: BoxDecoration(
              color: cardColor, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 8))],
              border: Border.all(color: cardColor, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? Image.network(company.logoUrl!, fit: BoxFit.cover, errorBuilder: (c, o, s) => Center(child: Icon(Icons.directions_bus_filled_rounded, color: primary, size: 35)))
                  : Center(child: Icon(Icons.directions_bus_filled_rounded, color: primary, size: 35)),
            ),
          ),
        ),
      ],
    );
  }
}