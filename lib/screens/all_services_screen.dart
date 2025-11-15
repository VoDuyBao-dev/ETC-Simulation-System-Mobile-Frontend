import 'package:flutter/material.dart';
import 'package:smarttoll_app/screens/recharge_screen.dart';
import 'package:smarttoll_app/screens/history_screen.dart';
import 'package:smarttoll_app/screens/vehicle_screen.dart';
import 'package:smarttoll_app/screens/transaction_history_screen.dart';
import 'profile_screen.dart';

class AllServicesScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AllServicesScreen({super.key, required this.userData});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tất cả dịch vụ"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),

      backgroundColor: const Color(0xFFF2F4F8),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [

                _menuItem(Icons.person_rounded, "Thông tin cá nhân", "",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    )),

                _menuItem(Icons.account_balance_wallet_rounded, "Nạp tiền", "Nạp nhanh",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RechargeScreen()),
                    )),

                _menuItem(Icons.receipt_long_rounded, "Lịch sử nạp tiền", "Xem giao dịch",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()))),

                _menuItem(Icons.directions_car_rounded, "Quản lý phương tiện", "Xe đã đăng ký",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VehicleScreen()))),

                _menuItem(Icons.history_rounded, "Lịch sử thu phí", "Giao dịch gần đây",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    )),

                _menuItem(Icons.card_giftcard_rounded, "Khuyến mãi", "Ưu đãi hấp dẫn"),
                _menuItem(Icons.support_agent_rounded, "Hỗ trợ", "Chat nhân viên"),
                _menuItem(Icons.qr_code_scanner_rounded, "Quét mã trạm", "Dễ dàng qua trạm"),
                _menuItem(Icons.map_rounded, "Bản đồ trạm", "Xem vị trí gần nhất"),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON BACKGROUND GRADIENT
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
