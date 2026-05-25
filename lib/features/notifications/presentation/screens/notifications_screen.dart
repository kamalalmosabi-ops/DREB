import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';
import 'package:darb/features/notifications/presentation/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final String userType;
  const NotificationsScreen({super.key, required this.userType});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String activeFilter = "الكل";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(widget.userType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;
    final filteredNotifications = NotificationModel.getFiltered(notifications, activeFilter);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: Column(
          children: [
            _buildPremiumHeader(context),
            _buildFilterTabs(),
            Expanded(
              child: notificationProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : _buildModernList(filteredNotifications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: topPadding + 20, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFE79C24), Color(0xFFD18B1E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22), onPressed: () => Navigator.pop(context)),
          const Text("مركز التنبيهات", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديد جميع الإشعارات كمقروءة")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ["الكل", "حجوزات", "تنبيهات إدارية", "المدفوعات"];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          String tab = tabs[index];
          bool isSelected = activeFilter == tab;
          return GestureDetector(
            onTap: () => setState(() => activeFilter = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D1B3E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text(tab, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernList(List<NotificationModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildEnhancedPremiumCard(list[index]),
    );
  }

  Widget _buildEnhancedPremiumCard(NotificationModel noti) {
    Color themeColor = _getThemeColor(noti.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0D1B3E).withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(noti.categoryName, themeColor),
                Row(
                  children: [
                    Text(_formatTimestampShort(noti.createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    if (!noti.isRead) ...[
                      const SizedBox(width: 8),
                      const CircleAvatar(radius: 3, backgroundColor: Color(0xFFE79C24)),
                    ]
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconBox(noti.category, themeColor),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(noti.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D1B3E))),
                      const SizedBox(height: 5),
                      Text(noti.body, style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(int category, Color color) {
    IconData iconData = Icons.notifications_none_rounded;
    if (category == 1) {
    iconData = Icons.directions_bus_filled_rounded;
  } else if (category == 3) {
    iconData = Icons.account_balance_wallet_rounded;
  }
  
  return Container(
    width: 45, 
    height: 45,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1), 
      borderRadius: BorderRadius.circular(14)
    ),
    child: Icon(iconData, color: color, size: 24),
  );
}
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(30)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getThemeColor(int category) {
    switch (category) {
      case 1: return Colors.green;
      case 3: return Colors.orange;
      default: return Colors.blue;
    }
  }

  String _formatTimestampShort(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
    return "${time.day}/${time.month}";
  }

  Widget _buildEmptyState() => const Center(child: Text("لا توجد تنبيهات"));
