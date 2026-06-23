import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/company_model.dart';
import '../providers/company_details_provider.dart';
import 'package:darb/features/home_search/data/models/trip_model.dart'; 
import 'package:darb/features/bookings/presentation/screens/trip_details_screen.dart'; 
import 'package:darb/core/network/dio_client.dart';

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
  // متغيرات التقييمات
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;
  
  // متغير لتخزين متوسط التقييم الديناميكي
  double _averageRating = 5.0; 

  @override
  void initState() {
    super.initState();
    _averageRating = widget.company.rating; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.company.id != null) {
        Provider.of<CompanyDetailsProvider>(context, listen: false)
            .fetchCompanyTrips(widget.company.id!);
        
        // جلب التقييمات فور فتح الشاشة
        _fetchReviews();
      }
    });
  }

  // دالة جلب التقييمات من السيرفر وحساب المتوسط
  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final response = await DioClient().get('/Customer/company/${widget.company.id}/reviews');
      if (response.statusCode == 200 && response.data != null) {
        if (mounted) {
          setState(() {
            _reviews = response.data['data'] ?? [];
            
            // الحساب الديناميكي لمتوسط التقييمات
            if (_reviews.isNotEmpty) {
              double sum = 0.0;
              for (var review in _reviews) {
                sum += double.tryParse(review['rating']?.toString() ?? "5") ?? 5.0;
              }
              _averageRating = sum / _reviews.length; 
            }

            _isLoadingReviews = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  // دالة إظهار نافذة إضافة التقييم (Bottom Sheet)
  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReviewSheet(
        companyId: widget.company.id!,
        onReviewAdded: () {
          // تحديث التقييمات بعد الإضافة بنجاح ليتغير المتوسط فوراً
          _fetchReviews();
        },
      ),
    );
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
                    _buildSectionTitle(loc.translate('services_and_features') ?? 'الخدمات والمميزات', textColor),
                    _buildModernAmenities(primaryColor, textColor, cardColor, loc),
                    const SizedBox(height: 30),
                    _buildSectionTitle(loc.translate('upcoming_trips') ?? 'الرحلات القادمة', textColor),
                    
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
                              child: Text(loc.translate('no_scheduled_trips') ?? 'لا توجد رحلات مجدولة', style: const TextStyle(color: Colors.grey)),
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

                    // قسم التقييمات 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(loc.translate('travelers_reviews') ?? 'آراء المسافرين', textColor),
                        TextButton.icon(
                          onPressed: _showAddReviewSheet,
                          icon: const Icon(Icons.add_comment_rounded, color: primaryColor, size: 18),
                          label: const Text("أضف تقييمك", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    
                    if (_isLoadingReviews)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: primaryColor)))
                    else if (_reviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text("لا توجد تقييمات لهذه الشركة حتى الآن. كن أول من يقيّم!", style: TextStyle(color: Colors.grey[500], fontSize: 13), textAlign: TextAlign.center),
                        ),
                      )
                    else
                      Column(
                        children: _reviews.map((review) => _buildDynamicReviewCard(review, textColor, cardColor)).toList(),
                      ),
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

  // ✅ تم التعديل هنا: إزالة جملة (عدد الرحلات المتاحة) والإبقاء على التقييم فقط
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
                    Text(" ${_averageRating.toStringAsFixed(1)} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAmenities(Color primary, Color textColor, Color cardColor, AppLocalizations loc) {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.wifi_rounded, "label": loc.translate('internet') ?? 'إنترنت'},
      {"icon": Icons.ac_unit_rounded, "label": loc.translate('ac') ?? 'تكييف'},
      {"icon": Icons.battery_charging_full_rounded, "label": loc.translate('charging') ?? 'شحن'},
      {"icon": Icons.fastfood_rounded, "label": loc.translate('hospitality') ?? 'ضيافة'},
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
              _buildCityPoint(trip.toCity, loc.translate('expected_arrival') ?? 'وقت الوصول', textColor),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text("${trip.price} ${loc.translate('yer') ?? 'ريال'}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)), 
                  Text("${loc.translate('remaining_seats') ?? 'المقاعد المتبقية:'} ${trip.seatsLeft}", style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))
                ]
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailsScreen(
                  trip: trip, 
                  companyName: widget.company.name, 
                  rating: double.parse(_averageRating.toStringAsFixed(1)) 
                ))),
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(loc.translate('book_now') ?? 'احجز الآن', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityPoint(String city, String time, Color textColor) => Column(children: [Text(city, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)), const SizedBox(height: 4), Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12))]);
  
  Widget _buildDynamicReviewCard(dynamic review, Color textColor, Color cardColor) {
    final String name = review['customerName'] ?? review['userName'] ?? review['name'] ?? "عميل درب";
    final String desc = review['description'] ?? review['comment'] ?? "بدون تعليق";
    final double rating = double.tryParse(review['rating']?.toString() ?? "5") ?? 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3))]
      ), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFF0F3FF), child: Icon(Icons.person, color: Colors.grey)), 
          const SizedBox(width: 15), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)), 
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14), 
                        Text(" $rating", style: const TextStyle(fontSize: 12, color: Colors.grey))
                      ]
                    )
                  ]
                ), 
                const SizedBox(height: 8), 
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4))
              ]
            )
          )
        ]
      )
    );
  }
  
  Widget _buildSectionTitle(String title, Color textColor) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)));
}


// =====================================================================
// كلاس خاص بالنافذة المنبثقة (Bottom Sheet) لإضافة تقييم جديد
// =====================================================================
class AddReviewSheet extends StatefulWidget {
  final int companyId;
  final VoidCallback onReviewAdded;

  const AddReviewSheet({super.key, required this.companyId, required this.onReviewAdded});

  @override
  State<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<AddReviewSheet> {
  int _selectedRating = 5;
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى كتابة تعليق لوصف تجربتك"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await DioClient().post('/Customer/reviews', data: {
        "companyId": widget.companyId,
        "rating": _selectedRating,
        "description": _descController.text.trim(),
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تمت إضافة تقييمك بنجاح! شكراً لك."), backgroundColor: Colors.green));
          widget.onReviewAdded(); 
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل إضافة التقييم، حاول مجدداً."), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint("Submit Review Error: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ في الاتصال بالسيرفر."), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDark;
    final isAr = settings.locale.languageCode == 'ar';

    final Color bgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    const Color primaryColor = Color(0xFFE79C24);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("قيم تجربتك مع الشركة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() => _selectedRating = index + 1);
                    },
                    icon: Icon(
                      index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _descController,
                maxLines: 4,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "كيف كانت رحلتك وتعامل الشركة؟...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF6F8FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("إرسال التقييم", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}