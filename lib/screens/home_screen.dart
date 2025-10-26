import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  // Nút menu
                  const Positioned(
                    top: 40,
                    left: 16,
                    child: Icon(Icons.menu, color: Colors.white, size: 32),
                  ),

                  // 🔹 Nút Đăng nhập
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

                  // Nội dung banner
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
                      color: Colors.white.withValues(alpha: 0.25),
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
                    color: Colors.black12.withValues(alpha: 0.1),
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

            // ===================== LOGO & KHẨU HIỆU =====================
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 60,
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

            // ===================== QUẢNG CÁO DẠNG SLIDE =====================
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

            // ===================== GIỚI THIỆU GÓI DỊCH VỤ =====================
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
                  _serviceCard(
                    title: "Gói SmartToll Cơ Bản",
                    desc: "Dành cho cá nhân, bao gồm nạp tiền và quản lý xe.",
                    color: Colors.blueAccent,
                    icon: Icons.account_balance_wallet,
                  ),
                  _serviceCard(
                    title: "Gói Premium 24/7",
                    desc:
                    "Cứu hộ toàn quốc, hỗ trợ kỹ thuật và bảo hiểm TNDS tích hợp.",
                    color: Colors.teal,
                    icon: Icons.workspace_premium_rounded,
                  ),
                  _serviceCard(
                    title: "Gói Doanh Nghiệp",
                    desc:
                    "Quản lý đội xe lớn, xuất hóa đơn định kỳ và dịch vụ hỗ trợ riêng.",
                    color: Colors.deepPurple,
                    icon: Icons.business_center,
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
            color: color1.withValues(alpha: 0.25),
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
              backgroundColor: Colors.white.withValues(alpha: 0.9),
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
            color: Colors.black12.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
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

// ===================== XE SMARTTOLL LOGO =====================
class _SmartTollCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double carHeight = size.height * 0.6;

    // 🌈 Hiệu ứng mờ phía sau xe
    final blurPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00BFA5), Color(0xFF81C784), Color(0xFFFFFFFF)],
        stops: [0.0, 0.4, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, carHeight))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    final blurPath = Path()
      ..moveTo(size.width * 0.1, carHeight)
      ..lineTo(size.width * 0.9, carHeight)
      ..lineTo(size.width * 0.9, carHeight * 0.4)
      ..lineTo(size.width * 0.1, carHeight * 0.4)
      ..close();
    canvas.drawPath(blurPath, blurPaint);

    // 🚘 Thân xe
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00A86B), Color(0xFFFFA726)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, carHeight))
      ..style = PaintingStyle.fill;

    final body = Path()
      ..moveTo(size.width * 0.1, carHeight)
      ..quadraticBezierTo(
          size.width * 0.15, carHeight * 0.25, size.width * 0.4, carHeight * 0.25)
      ..lineTo(size.width * 0.8, carHeight * 0.25)
      ..quadraticBezierTo(
          size.width * 0.95, carHeight * 0.3, size.width * 0.9, carHeight)
      ..close();
    canvas.drawShadow(body, Colors.black.withOpacity(0.2), 4, true);
    canvas.drawPath(body, bodyPaint);

    // 🪟 Kính xe
    final windowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, carHeight))
      ..style = PaintingStyle.fill;
    final window = Path()
      ..moveTo(size.width * 0.25, carHeight * 0.35)
      ..lineTo(size.width * 0.55, carHeight * 0.35)
      ..lineTo(size.width * 0.5, carHeight * 0.55)
      ..lineTo(size.width * 0.3, carHeight * 0.55)
      ..close();
    canvas.drawPath(window, windowPaint);

    // 🚗 Bánh xe
    final wheelPaint = Paint()..color = Colors.black87;
    final wheelInner = Paint()..color = Colors.white;
    for (final x in [size.width * 0.28, size.width * 0.75]) {
      canvas.drawCircle(Offset(x, size.height * 0.63), 7, wheelPaint);
      canvas.drawCircle(Offset(x, size.height * 0.63), 3, wheelInner);
    }

    // 💡 Đèn xe
    final lightPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(
        Offset(size.width * 0.12, size.height * 0.47), 3.5, lightPaint);
    canvas.drawCircle(
        Offset(size.width * 0.87, size.height * 0.47), 3.5, lightPaint);

    // 📶 Sóng tín hiệu
    final signalPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 2; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.93, size.height * 0.42),
          radius: 6 + i * 4,
        ),
        -1.0,
        1.7,
        false,
        signalPaint,
      );
    }

    // 🅿️ Logo chữ “SmartToll”
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "SmartToll",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height * 0.36),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
