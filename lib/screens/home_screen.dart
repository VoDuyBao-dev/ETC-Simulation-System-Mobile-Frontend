import 'package:flutter/material.dart';
import 'package:smarttoll_app/api/api_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final data = await ApiService.fetchHomeServices();
      setState(() {
        _services = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===================== BANNER =====================
            Container(
              height: 230,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 40,
                    left: 16,
                    child: Icon(Icons.menu, color: Colors.white, size: 32),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CỨU HỘ TRỌN GÓI 3 KHÔNG",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _bannerChip("Không lo thời gian"),
                        _bannerChip("Không lo vị trí"),
                        _bannerChip("Không giới hạn lần sử dụng"),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 25,
                    bottom: 15,
                    child: Icon(
                      Icons.directions_car_filled,
                      size: 80,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),

            // ===================== MENU =====================
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _menuItem(Icons.account_balance_wallet, "Nạp tiền"),
                  _menuItem(Icons.confirmation_num, "Mua vé tháng"),
                  _menuItem(Icons.link, "Liên kết\nngân hàng", isNew: true),
                  _menuItem(Icons.directions_car, "Quản lý xe"),
                  _menuItem(Icons.shield, "Bảo hiểm\nTNDS", isNew: true),
                  _menuItem(Icons.emergency, "Cứu hộ\ntoàn quốc", isNew: true),
                  _menuItem(Icons.card_giftcard, "Smart Loyalty", isNew: true),
                  _menuItem(Icons.apps, "Tất cả"),
                ],
              ),
            ),

            // ===================== LOGO SMARTTOLL =====================
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 70,
                    child: CustomPaint(
                      painter: _SmartTollCarPainter(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "SmartToll - Giao thông thông minh",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ===================== QUẢNG CÁO =====================
            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _promoCard(
                    title: "Ưu đãi khách hàng thân thiết",
                    subtitle: "Tích điểm đổi quà dễ dàng",
                    color1: const Color(0xFF00C6FF),
                    color2: const Color(0xFF0072FF),
                    icon: Icons.star_rounded,
                  ),
                  _promoCard(
                    title: "Mở tài khoản SHB nhận 115K",
                    subtitle: "Ưu đãi độc quyền SmartToll",
                    color1: const Color(0xFFFFA726),
                    color2: const Color(0xFFFF7043),
                    icon: Icons.card_giftcard,
                  ),
                  _promoCard(
                    title: "Một chạm – Vạn tiện ích",
                    subtitle: "Thanh toán, cứu hộ, bảo hiểm...",
                    color1: const Color(0xFF66BB6A),
                    color2: const Color(0xFF43A047),
                    icon: Icons.touch_app_rounded,
                  ),
                  _promoCard(
                    title: "Dịch vụ cứu hộ 24/7",
                    subtitle: "Sẵn sàng mọi lúc mọi nơi",
                    color1: const Color(0xFF9C27B0),
                    color2: const Color(0xFFE040FB),
                    icon: Icons.support_agent_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===================== DỊCH VỤ API =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Các gói dịch vụ nổi bật",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_error != null)
                    Text('Lỗi tải dữ liệu: $_error',
                        style: const TextStyle(color: Colors.red)),
                  if (!_isLoading && _error == null)
                    for (var s in _services)
                      _serviceCard(
                        title: s['title'] ?? 'Chưa có tên',
                        desc: s['desc'] ?? 'Không có mô tả',
                        color: Colors.teal,
                        icon: Icons.workspace_premium_rounded,
                      ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ===================== WIDGET PHỤ =====================
  static Widget _bannerChip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  static Widget _menuItem(IconData icon, String title, {bool isNew = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            if (isNew)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Mới",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static Widget _promoCard({
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(icon, color: color1, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _serviceCard({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(desc, style: const TextStyle(color: Colors.black54)),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18),
      ),
    );
  }
}

// ===================== XE SMARTTOLL CÂN ĐỐI - RÕ NÉT =====================
class _SmartTollCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = 1.5;
    final scaledWidth = size.width * scale;
    final scaledHeight = size.height * 0.9;
    final dx = (size.width - scaledWidth) / 2;
    final dy = (size.height - scaledHeight) / 2;

    // --- Thân xe ---
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0066FF), Color(0xFF00CCFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(dx, dy, scaledWidth, scaledHeight))
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(dx + scaledWidth * 0.05, dy + scaledHeight * 0.65)
      ..quadraticBezierTo(dx + scaledWidth * 0.25, dy + scaledHeight * 0.2,
          dx + scaledWidth * 0.55, dy + scaledHeight * 0.2)
      ..quadraticBezierTo(dx + scaledWidth * 0.93, dy + scaledHeight * 0.35,
          dx + scaledWidth * 0.93, dy + scaledHeight * 0.65)
      ..quadraticBezierTo(dx + scaledWidth * 0.85, dy + scaledHeight * 0.85,
          dx + scaledWidth * 0.12, dy + scaledHeight * 0.85)
      ..quadraticBezierTo(dx + scaledWidth * 0.03, dy + scaledHeight * 0.72,
          dx + scaledWidth * 0.05, dy + scaledHeight * 0.65)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);

    // --- Viền xe ---
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(bodyPath, borderPaint);

    // --- Cửa sổ ---
    final windowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(dx, dy, scaledWidth, scaledHeight));

    final windowPath = Path()
      ..moveTo(dx + scaledWidth * 0.23, dy + scaledHeight * 0.32)
      ..quadraticBezierTo(dx + scaledWidth * 0.55, dy + scaledHeight * 0.18,
          dx + scaledWidth * 0.75, dy + scaledHeight * 0.32)
      ..lineTo(dx + scaledWidth * 0.75, dy + scaledHeight * 0.5)
      ..lineTo(dx + scaledWidth * 0.23, dy + scaledHeight * 0.5)
      ..close();
    canvas.drawPath(windowPath, windowPaint);

    // --- Bánh xe ---
    final wheelPaint = Paint()..color = Colors.black;
    final rimPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    const wheelRadius = 12.0;
    canvas.drawCircle(
        Offset(dx + scaledWidth * 0.25, dy + scaledHeight * 0.87),
        wheelRadius,
        wheelPaint);
    canvas.drawCircle(
        Offset(dx + scaledWidth * 0.25, dy + scaledHeight * 0.87),
        wheelRadius,
        rimPaint);

    canvas.drawCircle(
        Offset(dx + scaledWidth * 0.7, dy + scaledHeight * 0.87),
        wheelRadius,
        wheelPaint);
    canvas.drawCircle(
        Offset(dx + scaledWidth * 0.7, dy + scaledHeight * 0.87),
        wheelRadius,
        rimPaint);

    // --- Đèn xe ---
    final lightPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(
        Offset(dx + scaledWidth * 0.94, dy + scaledHeight * 0.58), 7, lightPaint);

    // --- Chữ SmartToll rõ nét ---
    final textPainter = TextPainter(
      text: TextSpan(
        text: "SmartToll",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 3, color: Colors.black26, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: scaledWidth);

    final textOffset = Offset(
      dx + (scaledWidth - textPainter.width) / 2,
      dy + scaledHeight * 0.46 - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}