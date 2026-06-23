import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'search_results.dart';
import 'package:darb/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:darb/features/notifications/presentation/providers/notification_provider.dart';
import 'companies_screen.dart';
import 'package:darb/features/home_search/presentation/providers/home_provider.dart';
import 'package:darb/core/network/dio_client.dart';
import 'package:darb/core/localization/app_localizations.dart';
import 'package:darb/features/settings/presentation/providers/settings_provider.dart';
import 'package:darb/features/home_search/data/models/company_model.dart';
import 'company_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "جاري التحميل...";
  String userToken = "";
  List<dynamic> companyAvatars = [];
  bool isExtraLoading = true;

  final PageController _adController = PageController(viewportFraction: 0.9);
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchHomeData().then((_) {
        _startAdTimer();
      });
      _loadExtraDynamicData();
      
      context.read<NotificationProvider>().fetchNotificationsSilently();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        context.read<NotificationProvider>().fetchNotificationsSilently();
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    super.dispose();
  }

  void _startAdTimer() {
    final ads = Provider.of<HomeProvider>(context, listen: false).ads;
    if (ads.length > 1) {
      _adTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_adController.hasClients) {
          int nextPage = _adController.page!.round() + 1;
          if (nextPage >= ads.length) nextPage = 0;
          _adController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
          );
        }
      });
    }
  }

  Future<void> _loadExtraDynamicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedName = prefs.getString('userName') ?? prefs.getString('fullName') ?? prefs.getString('name');
      String? email = prefs.getString('email');
      
      if (savedName == null && email != null) savedName = email.split('@').first;
      if (savedName != null && savedName.isNotEmpty) {
        if(mounted) setState(() => userName = savedName!);
      } else {
        if(mounted) setState(() => userName = "مرحباً بك");
      }

      userToken = prefs.getString('token') ?? prefs.getString('accessToken') ?? '';
      
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
      if (mounted) setState(() => isExtraLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, HomeProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE79C24))),
        child: child!,
      ),
    );
    if (picked != null) {
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
            final ads = homeProvider.ads;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildUpperSection(homeProvider, isDark, isAr, loc),
                      const SizedBox(height: 25),

                      if (ads.isNotEmpty) ...[
                        _buildAdsCarousel(ads, isDark),
                        const SizedBox(height: 25),
                      ] else ...[
                        _buildNoAdsPlaceholder(isDark),
                        const SizedBox(height: 25),
                      ],
                      
                      _buildSectionTitle('شركات النقل', textColor, () {
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
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24))),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdsCarousel(List<dynamic> ads, bool isDark) {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _adController,
        physics: const BouncingScrollPhysics(),
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          final String imageUrl = ad['image'] ?? '';
          final String title = ad['title'] ?? '';

          return AnimatedBuilder(
            animation: _adController,
            builder: (context, child) {
              double value = 1.0;
              if (_adController.position.haveDimensions) {
                value = _adController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 140,
                  width: Curves.easeOut.transform(value) * double.infinity,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[300],
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
                image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
              ),
              child: imageUrl.isEmpty
                  ? Center(child: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)))
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(15),
                      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoAdsPlaceholder(bool isDark) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, color: Colors.grey.shade400, size: 45),
            const SizedBox(height: 8),
            Text("مساحة إعلانية", style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("ترقبوا أقوى العروض والخصومات قريباً!", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpperSection(HomeProvider provider, bool isDark, bool isAr, AppLocalizations loc) {
    return Stack(
      children: [
        Container(
          height: 240,
          decoration: const BoxDecoration(
            color: Color(0xFFE79C24),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildSearchCard(provider, isDark, isAr, loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ التعديل هنا: إضافة Expanded لمنع تجاوز الحجم (Overflow) عند طول الاسم
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(radius: 22, backgroundColor: Color(0xFF0D1B3E), child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "أهلاً بك، $userName 👋", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1, // منع النص من النزول لسطر جديد
                        overflow: TextOverflow.ellipsis, // وضع (...) إذا كان الاسم طويلاً جداً
                      ),
                      const Text(
                        'إلى أين وجهتك اليوم؟', 
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // مسافة أمان قبل أيقونة الإشعارات
          Consumer<NotificationProvider>(
            builder: (context, notiProvider, child) {
              int unread = notiProvider.unreadCount;
              return Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: Badge(
                    isLabelVisible: unread > 0, 
                    label: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.red,
                    offset: const Offset(-5, -5),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const NotificationsScreen(userType: "passenger"))
                    );
                    if (context.mounted) {
                      context.read<NotificationProvider>().fetchNotificationsSilently();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(HomeProvider provider, bool isDark, bool isAr, AppLocalizations loc) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08);

    final governorates = provider.searchData?.governorates ?? [];
    final companies = provider.searchData?.companies ?? [];
    final times = provider.searchData?.periods ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 30, offset: const Offset(0, 15))]),
      child: Column(
        children: [
          _buildDropdownField(Icons.location_on, loc.translate('from_governorate') ?? 'من محافظة', provider.selectedFrom, governorates, (val) => provider.updateSelectedFrom(val), isDark, isAr),
          const SizedBox(height: 12),
          _buildDropdownField(Icons.navigation, loc.translate('to_governorate') ?? 'إلى محافظة', provider.selectedTo, governorates, (val) => provider.updateSelectedTo(val), isDark, isAr),
          const SizedBox(height: 12),
          _buildDropdownField(Icons.business_rounded, loc.translate('transport_company') ?? 'شركة النقل', provider.selectedCompany, companies, (val) => provider.updateSelectedCompany(val), isDark, isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdownField(Icons.access_time, loc.translate('period') ?? 'الفترة', provider.selectedTime, times, (val) => provider.updateSelectedTime(val), isDark, isAr)),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFF3F4F6))),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFE79C24), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(loc.translate('date') ?? 'التاريخ', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280))),
                              Text(
                                provider.selectedDate != null ? "${provider.selectedDate!.year}/${provider.selectedDate!.month}/${provider.selectedDate!.day}" : "الكل", 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D1B3E)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (provider.selectedDate != null)
                          GestureDetector(
                            onTap: () => provider.updateSelectedDate(null),
                            child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: () {
                String actualFrom = provider.selectedFrom ?? '';
                String actualTo = provider.selectedTo ?? '';
                String actualComp = provider.selectedCompany ?? '';
                String actualTime = provider.selectedTime ?? '';

                int finalFromId = actualFrom.isEmpty ? 0 : (provider.selectedFromId ?? 0);
                int finalToId = actualTo.isEmpty ? 0 : (provider.selectedToId ?? 0);
                int finalCompanyId = actualComp.isEmpty ? 0 : (provider.selectedCompanyId ?? 0);
                int finalPeriodId = actualTime.isEmpty ? 0 : (provider.selectedPeriodId ?? 0);

                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(
                  fromCity: actualFrom.isEmpty ? "الكل" : actualFrom, 
                  toCity: actualTo.isEmpty ? "الكل" : actualTo, 
                  company: actualComp.isEmpty ? "الكل" : actualComp, 
                  travelDate: provider.selectedDate, 
                  timePeriod: actualTime.isEmpty ? "الكل" : actualTime, 
                  fromCityId: finalFromId,      
                  toCityId: finalToId,          
                  companyId: finalCompanyId,    
                  periodId: finalPeriodId,      
                )));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE79C24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
              child: Text(loc.translate('search_trips') ?? 'ابحث عن الرحلات', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(IconData icon, String label, String? currentValue, List<String> items, Function(String?) onChanged, bool isDark, bool isAr) {
    final String? verifiedValue = items.contains(currentValue) ? currentValue : null;
    final fieldBgColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? Colors.transparent : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    final labelColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: fieldBgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE79C24), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String?>(
                  value: verifiedValue,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF), size: 18),
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  decoration: InputDecoration(
                    labelText: label, 
                    labelStyle: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w500), 
                    border: InputBorder.none, 
                    alignLabelWithHint: true
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      alignment: Alignment.centerRight,
                      child: Text("الكل (بدون فلتر)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                    ),
                    ...items.map((String value) => DropdownMenuItem<String?>(
                      value: value, 
                      alignment: Alignment.centerRight, 
                      child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis)
                    )),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesList(bool isDark) {
    if (isExtraLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE79C24)));
    if (companyAvatars.isEmpty) return const SizedBox();

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

          return GestureDetector(
            onTap: () {
              final companyObj = Company(
                id: comp['companyId'] ?? comp['id'] ?? 0,
                name: name,
                rating: 5.0, 
                totalTrips: 0,
                logoUrl: logoUrl,
              );
              Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailsScreen(company: companyObj)));
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  logoUrl.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(logoUrl, height: 40, width: 50, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.directions_bus, color: Color(0xFFE79C24), size: 30)))
                      : const Icon(Icons.business, color: Color(0xFFE79C24), size: 35),
                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          GestureDetector(
            onTap: onTap,
            child: const Text('عرض الكل', style: TextStyle(fontSize: 12, color: Color(0xFFE79C24), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}