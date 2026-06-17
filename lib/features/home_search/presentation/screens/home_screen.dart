import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'search_results.dart';
import 'package:darb/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:darb/features/bookings/presentation/screens/my_bookings_screen.dart';
import 'companies_screen.dart';
import 'all_trips_screen.dart';
import 'package:darb/features/home_search/presentation/providers/home_provider.dart';

import 'package:darb/features/bookings/data/models/booking_service.dart';
import 'package:darb/core/network/dio_client.dart';

import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // هنا الاسم سيبدأ افتراضياً بـ "يا صديقي" حتى يتم جلبه من السيرفر/الذاكرة
  String userName = "يا صديقي";
  String userToken = "";
  Map<String, dynamic>? upcomingTrip;
  List<dynamic> companyAvatars = [];
  bool isExtraLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData();
      _loadExtraDynamicData();
    });
  }

  // الدالة المعدلة لجلب الاسم الحقيقي
  Future<void> _loadExtraDynamicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // جلب الاسم من الذاكرة المحلية (التي تم تحديثها عند تسجيل الدخول)
      String? savedName = prefs.getString('userName') ?? prefs.getString('fullName') ?? prefs.getString('name');
      String? email = prefs.getString('email');
      
      if (savedName == null && email != null) {
        savedName = email.split('@').first;
      }
      
      // تحديث الحالة ليتغير النص في الواجهة فوراً
      if (savedName != null && savedName.isNotEmpty) {
        setState(() {
          userName = savedName!;
        });
      }

      userToken = prefs.getString('token') ?? prefs.getString('accessToken') ?? '';
      
      final bookingService = BookingService();
      var trips = await bookingService.getBookingsByStatus(1);
      if (trips.isEmpty) {
        trips = await bookingService.getBookingsByStatus(2);
      }
      if (trips.isNotEmpty) {
        upcomingTrip = trips.first;
      }

      final dio = DioClient();
      final res = await dio.get('/Customer/home/companies/avatar');
      if (res.statusCode == 200 && res.data != null) {
        if (res.data is List) {
          companyAvatars = res.data;
        } else if (res.data is Map && res.data['data'] is List) {
          companyAvatars = res.data['data'];
        }
      }
    } catch (e) {
      debugPrint("Error loading dynamic home data: $e");
    } finally {
      if (mounted) {
        setState(() => isExtraLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, HomeProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE79C24)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.updateSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final loc = AppLocalizations.of(context)!;
    
    final isDark = settings.isDark;
    const isAr = true;
    
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FD);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            final governorates = homeProvider.searchData?.governorates ?? [];
            final companiesList = homeProvider.searchData?.companies ?? [];
            final times = homeProvider.searchData?.periods ?? [];

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildUpperSection(homeProvider, governorates, companiesList, times, isDark, isAr, loc),
                      const SizedBox(height: 25),
                      
                      _buildSectionTitle(loc.translate('your_upcoming_trips'), textColor, loc, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
                      }),
                      
                      _buildEnhancedTripCard(isDark, loc, isAr),
                      const SizedBox(height: 25),
                      
                      _buildSectionTitle(loc.translate('transport_companies'), textColor, loc, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CompaniesScreen()));
                      }),
                      
                      _buildCompaniesList(isDark),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                if (homeProvider.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE79C24)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpperSection(HomeProvider provider, List<String> governorates, List<String> companies, List<String> times, bool isDark, bool isAr, AppLocalizations loc) {
    return Stack(
      children: [
        Container(
          height: 240,
          decoration: const BoxDecoration(
            color: Color(0xFFE79C24),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(loc),
              const SizedBox(height: 10),
              _buildSearchCard(provider, governorates, companies, times, isDark, isAr, loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF0D1B3E),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // هنا يظهر الاسم المحدث
                  Text("أهلاً بك، $userName 👋", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(loc.translate('where_to_go_today'), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(
                      userType: "passenger",
                      token: userToken,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(HomeProvider provider, List<String> governorates, List<String> companies, List<String> times, bool isDark, bool isAr, AppLocalizations loc) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        children: [
          _buildDropdownField(Icons.location_on, loc.translate('from_governorate'), provider.selectedFrom, governorates, (val) => provider.updateSelectedFrom(val), isDark, isAr),
          const SizedBox(height: 12),
          _buildDropdownField(Icons.navigation, loc.translate('to_governorate'), provider.selectedTo, governorates, (val) => provider.updateSelectedTo(val), isDark, isAr),
          const SizedBox(height: 12),
          _buildDropdownField(Icons.business_rounded, loc.translate('transport_company'), provider.selectedCompany, companies, (val) => provider.updateSelectedCompany(val), isDark, isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(Icons.access_time, loc.translate('period'), provider.selectedTime, times, (val) => provider.updateSelectedTime(val), isDark, isAr),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, provider),
                  child: _buildSearchField(Icons.calendar_today, loc.translate('date'), "${provider.selectedDate.day} / ${provider.selectedDate.month}", isDark, isAr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(
                      fromCity: provider.selectedFrom ?? '',
                      toCity: provider.selectedTo ?? '',
                      company: provider.selectedCompany ?? '',
                      travelDate: provider.selectedDate,
                      timePeriod: provider.selectedTime ?? '',
                      fromCityId: provider.selectedFromId,
                      toCityId: provider.selectedToId,
                      companyId: provider.selectedCompanyId,
                      periodId: provider.selectedPeriodId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE79C24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(
                loc.translate('search_trips'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTripsScreen()));
            },
            child: Text(
              loc.translate('explore_all_trips'),
              style: const TextStyle(
                color: Color(0xFFE79C24),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFE79C24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String label, String? currentValue, List<String> items, Function(String?) onChanged, bool isDark, bool isAr) {
    final String? verifiedValue = items.contains(currentValue) ? currentValue : (items.isNotEmpty ? items.first : null);
    final fieldBgColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? Colors.transparent : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final labelColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: fieldBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE79C24), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: verifiedValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF), size: 18),
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                  items: items.map((String value) => DropdownMenuItem(
                    value: value,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(IconData icon, String label, String value, bool isDark, bool isAr) {
    final fieldBgColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? Colors.transparent : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final labelColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: fieldBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE79C24), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTripCard(bool isDark, AppLocalizations loc, bool isAr) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFF0D1B3E);
    
    if (isExtraLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        height: 120,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25)),
        child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (upcomingTrip == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: cardColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))]
        ),
        child: const Column(
          children: [
            Icon(Icons.bus_alert, color: Colors.white54, size: 40),
            SizedBox(height: 10),
            Text("لا توجد لديك رحلات قادمة حالياً", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("احجز رحلتك الآن وانطلق في مغامرتك القادمة!", style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 10),
          ],
        ),
      );
    }

    final trip = upcomingTrip!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: cardColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("رقم الحجز #${trip['bookingId'] ?? '---'}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text("رحلة قادمة", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tripLocation(trip['startGovernorate'] ?? "انطلاق", ""),
              const Icon(Icons.swap_horiz, color: Colors.orange, size: 28),
              _tripLocation(trip['endGovernorate'] ?? "وصول", ""),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(trip['companyName'] ?? "شركة النقل", style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
              Text("${trip['totalAmount'] ?? 0} ${loc.translate('riyals')}", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _tripLocation(String city, String time) {
    return Column(
      children: [
        Text(city, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        if (time.isNotEmpty) Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildCompaniesList(bool isDark) {
    if (isExtraLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)));
    }
    if (companyAvatars.isEmpty) {
      return const SizedBox();
    }

    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: companyAvatars.length,
        itemBuilder: (context, index) {
          final comp = companyAvatars[index];
          final String logoUrl = comp['logo'] ?? '';
          final String name = comp['name'] ?? 'شركة نقل';

          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          logoUrl,
                          height: 40,
                          width: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_bus, color: Color(0xFFE79C24), size: 30),
                        ),
                      )
                    : const Icon(Icons.directions_bus_filled_rounded, color: Color(0xFFE79C24), size: 35),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor, AppLocalizations loc, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          GestureDetector(
            onTap: onTap,
            child: Text(loc.translate('view_all'), style: const TextStyle(fontSize: 12, color: Color(0xFFE79C24), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}