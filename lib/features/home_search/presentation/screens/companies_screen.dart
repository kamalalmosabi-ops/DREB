import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/company_model.dart'; 
import '../providers/company_provider.dart';  
import 'company_details_screen.dart'; 

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
    const primaryColor = Color(0xFFE79C24);
    const darkBlue = Color(0xFF0D1B3E);
    const bgColor = Color(0xFFF8F9FD);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildStandardHeader(context, primaryColor),
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
                          Icon(Icons.business_rounded, size: 60, color: darkBlue.withValues(alpha: 0.3)),
                          const SizedBox(height: 10),
                          const Text("لا توجد شركات نقل متاحة حالياً", style: TextStyle(color: darkBlue, fontSize: 16, fontWeight: FontWeight.bold)),
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
                        _buildUltimateCompanyCard(context, provider.companies[index], primaryColor, darkBlue),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardHeader(BuildContext context, Color primaryColor) {
    return Container(
      height: 125, // تم تقليل الارتفاع من 160 إلى 125
      width: double.infinity,
      decoration: BoxDecoration( 
        color: primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("شركات النقل", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text("اختر شريك رحلتك القادمة", style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltimateCompanyCard(BuildContext context, Company company, Color primary, Color dark) {
    return Stack(
      clipBehavior: Clip.none, alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: dark.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 35),
                Text(company.name, style: TextStyle(color: dark, fontWeight: FontWeight.w900, fontSize: 16), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    Text(" ${company.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text("| ${company.totalTrips} رحلة", style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyDetailsScreen(company: company)));
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(15)),
                    child: Center(child: Text("استكشف", style: TextStyle(color: dark, fontSize: 12, fontWeight: FontWeight.bold))),
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
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 8))],
              border: Border.all(color: Colors.white, width: 4),
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