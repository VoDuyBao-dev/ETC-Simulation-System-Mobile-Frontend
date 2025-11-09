import 'package:flutter/material.dart';
import 'package:smarttoll_app/screens/history_screen.dart';
import 'package:smarttoll_app/screens/recharge_screen.dart';
import 'package:smarttoll_app/screens/vehicle_screen.dart';
import 'profile_screen.dart';
import 'recharge_screen.dart';
import 'vehicle_screen.dart';
import 'history_screen.dart';

class HomeLoggedScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeLoggedScreen({super.key, required this.userData});

  @override
  State<HomeLoggedScreen> createState() => _HomeLoggedScreenState();
}

class _HomeLoggedScreenState extends State<HomeLoggedScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  final List<String> _titles = [
    "Trang chủ",
    "Thông tin cá nhân",
    "Cài đặt",
  ];

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: const ProfileScreen(),
      ),
      _buildSettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ===================== APP BAR =====================
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),

      // ===================== BODY =====================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),

      // ===================== BOTTOM NAV =====================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Cá nhân"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Cài đặt"),
        ],
      ),
    );
  }

  // ===================== TRANG CHỦ =====================
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- THÔNG TIN NGƯỜI DÙNG -----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF0099FF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userData['name'] ?? 'Người dùng SmartToll',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.userData['email'] ?? 'user@example.com',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Số dư: ${widget.userData['balance'] ?? '0'}đ",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ----- LƯỚI CHỨC NĂNG -----
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: [
              _menuItem(Icons.account_balance_wallet_rounded, "Nạp tiền", "Nạp nhanh",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RechargeScreen()),
                ),
              ),
              _menuItem(Icons.receipt_long_rounded, "Tra cứu", "Xem giao dịch"),
              _menuItem(Icons.directions_car_rounded, "Quản lý phương tiện", "Xe đã đăng ký",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehicleScreen()),
                ),
              ),
              _menuItem(Icons.history_rounded, "Lịch sử thu phí", "Giao dịch gần đây",
                onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              _menuItem(Icons.card_giftcard_rounded, "Khuyến mãi", "Ưu đãi hấp dẫn"),
              _menuItem(Icons.support_agent_rounded, "Hỗ trợ", "Chat nhân viên"),
              _menuItem(Icons.account_balance_rounded, "Liên kết ngân hàng", ""),
              _menuItem(Icons.qr_code_scanner_rounded, "Quét mã trạm", "Dễ dàng qua trạm"),
              _menuItem(Icons.map_rounded, "Bản đồ trạm", "Xem vị trí gần nhất"),
              _menuItem(Icons.logout_rounded, "Đăng xuất", "Thoát tài khoản",
                  onTap: () => Navigator.pop(context)),
            ],
          ),

          const SizedBox(height: 25),

          // ----- BANNER -----
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: NetworkImage(
                    "https://cdn.dribbble.com/users/1162077/screenshots/3848914/media/7ed5a63e2b0046e4caa3b6c4d4d3b2b1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TRANG CÀI ĐẶT =====================
  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Cài đặt tài khoản",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _settingsTile(Icons.lock_outline_rounded, "Đổi mật khẩu"),
        _settingsTile(Icons.notifications_active_rounded, "Cài đặt thông báo"),
        _settingsTile(Icons.language_rounded, "Ngôn ngữ"),
        _settingsTile(Icons.info_outline_rounded, "Giới thiệu SmartToll"),
        _settingsTile(Icons.logout_rounded, "Đăng xuất",
            color: Colors.red, onTap: () => Navigator.pop(context)),
      ],
    );
  }

  // ===================== ITEM CÀI ĐẶT =====================
  Widget _settingsTile(IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return Card(
      elevation: 3,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color ?? primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }

  // ===================== ITEM MENU =====================
  Widget _menuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: primaryColor),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
