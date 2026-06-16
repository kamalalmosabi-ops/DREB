import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/company_model.dart';
import '../providers/company_details_provider.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart'; 
import 'package:darb/features/bookings/presentation/screens/trip_details_screen.dart'; 

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailsScreen({
    super.key,
    required this.company,
  });

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.company.id != null) {
        Provider.of<CompanyDetailsProvider>(context, listen: false)
            .fetchCompanyTrips(widget.company.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';

    const primaryColor = Color(0xFFE79C24);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(context, primaryColor, cardColor),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(textColor, loc),
                    const SizedBox(height: 30),
                    _buildSectionTitle(loc.translate('services_and_features'), textColor),
                    _buildModernAmenities(primaryColor, textColor, cardColor, loc),
                    const SizedBox(height: 30),
                    _buildSectionTitle(loc.translate('upcoming_trips'), textColor),
                    
                    Consumer<CompanyDetailsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Center(child: CircularProgressIndicator(color: primaryColor)),
                          );
                        }
                        if (provider.errorMessage.isNotEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
                            ),
                          );
                        }
                        if (provider.trips.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Text(loc.translate('no_scheduled_trips'), style: const TextStyle(color: Colors.grey)),
                            ),
                          );
                        }
                        return Column(
                          children: provider.trips
                              .map((trip) => _buildPremiumTripCard(context, trip, primaryColor, textColor, cardColor, loc))
                              .toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    _buildSectionTitle(loc.translate('main_branches'), textColor),
                    _buildHorizontalBranches(primaryColor, loc),
                    const SizedBox(height: 30),
                    _buildSectionTitle(loc.translate('travelers_reviews'), textColor),
                    _buildReviewCard(textColor, cardColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, Color primary, Color cardColor) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Center(
            child: Hero(
              tag: widget.company.name,
              child: Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: cardColor, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: widget.company.logoUrl != null && widget.company.logoUrl!.isNotEmpty
                      ? Image.network(widget.company.logoUrl!, fit: BoxFit.cover)
                      : Icon(Icons.business, color: primary, size: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(Color textColor, AppLocalizations loc) {
    return Center(
      child: Column(
        children: [
          Text(widget.company.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    Text(" ${widget.company.rating} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("(${widget.company.totalTrips} ${loc.translate('available_trips_count')})", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAmenities(Color primary, Color textColor, Color cardColor, AppLocalizations loc) {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.wifi_rounded, "label": loc.translate('internet')},
      {"icon": Icons.ac_unit_rounded, "label": loc.translate('ac')},
      {"icon": Icons.battery_charging_full_rounded, "label": loc.translate('charging')},
      {"icon": Icons.fastfood_rounded, "label": loc.translate('hospitality')},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) => Container(
        width: 75, padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
        child: Column(children: [Icon(item['icon'], color: primary, size: 28), const SizedBox(height: 8), Text(item['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))]),
      )).toList(),
    );
  }

  Widget _buildPremiumTripCard(BuildContext context, Trip trip, Color primary, Color textColor, Color cardColor, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Row(
            children: [
              _buildCityPoint(trip.fromCity, trip.departureTime, textColor),
              Expanded(child: Column(children: [Icon(Icons.chevron_left_rounded, color: primary.withValues(alpha: 0.5)), Container(height: 2, color: primary.withValues(alpha: 0.1), margin: const EdgeInsets.symmetric(horizontal: 10))])),
              _buildCityPoint(trip.toCity, loc.translate('expected_arrival'), textColor),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text("${trip.price} ${loc.translate('yer')}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)), 
                  // ✅ تم التعديل هنا واستخدام المتغير الصحيح seatsLeft
                  Text("${loc.translate('remaining_seats')} ${trip.seatsLeft}", style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))
                ]
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailsScreen(trip: trip, companyName: widget.company.name, rating: widget.company.rating))),
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(loc.translate('book_now'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityPoint(String city, String time, Color textColor) => Column(children: [Text(city, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)), const SizedBox(height: 4), Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12))]);
  
  Widget _buildHorizontalBranches(Color primary, AppLocalizations loc) {
    final branches = [loc.translate('branch_sanaa'), loc.translate('branch_aden'), loc.translate('branch_taiz')];
    return SizedBox(height: 45, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: branches.length, itemBuilder: (context, i) => Container(margin: const EdgeInsets.only(left: 10), padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: primary.withValues(alpha: 0.2))), child: Center(child: Text(branches[i], style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12))))));
  }
  
  Widget _buildReviewCard(Color textColor, Color cardColor) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const CircleAvatar(backgroundColor: Color(0xFFF0F3FF), child: Icon(Icons.person, color: Colors.grey)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("أحمد المعمري", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)), const Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), Text(" 5.0", style: TextStyle(fontSize: 12, color: Colors.grey))])]), const SizedBox(height: 5), const Text("باصات نظيفة جداً والسائق كان محترم والمواعيد مضبوطة بالدقيقة.", style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4))]))]));
  
  Widget _buildSectionTitle(String title, Color textColor) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)));
}