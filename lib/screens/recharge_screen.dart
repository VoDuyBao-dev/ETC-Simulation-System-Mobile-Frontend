import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/auth_service.dart';
import '../api/api_service.dart';
import 'login_screen.dart';
import 'payment_webview.dart';

class RechargeScreen extends StatefulWidget {


  const RechargeScreen({super.key});
  //  sửa tới đoạn recharge này rồi

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {

  User? user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = AuthService.currentUser;
    _refreshBalance();
  }

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  String _selectedMethod = 'Thanh toán qua ngân hàng (VNPay)';
  String? _selectedBank;

  final List<String> _quickAmounts = [
    '50000',
    '100000',
    '200000',
    '500000',
    '1000000',
    '2000000',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // CHỈ LẤY BALANCE → NHANH, CHÍNH XÁC, KHÔNG TẢI LẠI TOÀN BỘ USER
  Future<void> _refreshBalance() async {
    try {
      final newBalance = await ApiService.getWalletBalance();
      final updatedUser = user?.copyWith(balance: newBalance)
          ?? AuthService.currentUser?.copyWith(balance: newBalance);

      if (updatedUser != null && mounted) {
        setState(() => user = updatedUser);
        AuthService.setUser(updatedUser); // Cập nhật cache toàn app
      }
    } catch (e) {
      debugPrint("Lỗi refresh balance: $e");
      // Không crash, vẫn dùng balance cũ
    }
  }

  // SAU KHI NẠP THÀNH CÔNG → CHỈ LÀM 1 LẦN DUY NHẤT Ở ĐÂY
  Future<void> _handlePaymentSuccess(String amount) async {
    await _refreshBalance(); // ← Cập nhật số dư mới nhất từ server

    if (!mounted) return;

    // Chỉ show 1 lần duy nhất ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nạp thành công ${formatAmount(amount)}₫!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );

    _amountController.clear();
    setState(() => _selectedBank = null);
  }

// Format tiền đẹp (50000 → 50.000, 100000 → 100.000)
  String formatAmount(String rawAmount) {
    final clean = rawAmount.replaceAll('.', '').replaceAll(',', '');
    final number = int.tryParse(clean) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
  }

// HÀM CHÍNH – ĐÃ SẠCH, KHÔNG DƯ THỪA
  void _startPayment(String amount, {String? bankCode}) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.createVNPAYPayment(
        amount: amount,
        bankCode: bankCode,
      );

      if (!mounted) return;

      if (response["code"] == 200 &&
          response["result"]?["paymentUrl"] != null) {

        final paymentUrl = response["result"]["paymentUrl"];

        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebView(
              paymentUrl: paymentUrl,
              onPaymentComplete: (code, message) {
                debugPrint("Payment callback: $code - $message");
              },
            ),
          ),
        );

        // THÀNH CÔNG
        if (result?["success"] == true) {
          await _handlePaymentSuccess(amount); // ← TẤT CẢ XỬ LÝ Ở ĐÂY
        }
        // THẤT BẠI
        else if (result != null) {
          _showError(result["message"] ?? "Thanh toán bị hủy hoặc thất bại");
        }
      } else {
        _showError(response["message"] ?? "Không tạo được link thanh toán");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    AuthService.clearUser();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 65,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0099FF),
                Color(0xFF00CC99),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Nạp tiền",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- SỐ DƯ HIỆN TẠI ----------
              // Thay toàn bộ phần hiển thị số dư bằng đoạn này:
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Số dư hiện tại",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // HIỂN THỊ SỐ DƯ ĐẸP + AN TOÀN
                    if (user == null)
                      const SizedBox(
                        height: 36,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    else
                      Text(
                        "${user!.balance.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]}.',
                        )} VND",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------- NHẬP SỐ TIỀN ----------
              const Text(
                "Nhập số tiền muốn nạp",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Nhập số tiền (VNĐ)",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.attach_money_rounded, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  // Loại bỏ dấu phẩy trước khi parse
                  final cleanValue = value.replaceAll(',', '');
                  final amount = int.tryParse(cleanValue);

                  if (amount == null || amount < 10000) {
                    return 'Số tiền tối thiểu 10,000 VND';
                  }
                  if (amount > 500000000) {
                    return 'Số tiền tối đa 500,000,000 VND';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ---------- CHỌN NHANH ----------
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickAmounts.map((amount) {
                  return _quickAmountButton(amount);
                }).toList(),
              ),

              const SizedBox(height: 25),

              // ---------- CHỌN PHƯƠNG THỨC ----------
              const Text(
                "Phương thức thanh toán",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              _paymentMethod(
                  "Thanh toán qua ngân hàng (VNPay)",
                  Icons.account_balance_wallet_rounded
              ),

              const SizedBox(height: 30),

              // ---------- NÚT NẠP TIỀN ----------
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    // Loại bỏ dấu phẩy trước khi gửi
                    final amount = _amountController.text.replaceAll(',', '');
                    _startPayment(amount, bankCode: _selectedBank);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isLoading
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Xác nhận nạp tiền",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- BUTTON CHỌN NHANH ----------
  Widget _quickAmountButton(String amount) {
    final displayAmount = '${int.parse(amount) ~/ 1000}K';
    return ChoiceChip(
      label: Text(displayAmount),
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: _amountController.text == amount ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      selected: _amountController.text == amount,
      onSelected: (selected) {
        setState(() {
          _amountController.text = amount;
        });
      },
    );
  }

  // ---------- PHƯƠNG THỨC THANH TOÁN ----------
  Widget _paymentMethod(String title, IconData icon) {
    final bool isSelected = _selectedMethod == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}