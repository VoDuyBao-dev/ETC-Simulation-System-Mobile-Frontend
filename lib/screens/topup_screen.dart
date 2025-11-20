import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/auth_service.dart';
import '../api/api_service.dart';
import 'login_screen.dart';
import 'payment_webview.dart';

class TopupScreen extends StatefulWidget {
  final User user;

  const TopupScreen({super.key, required this.user});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _apiService = ApiService();
  String? _selectedBank;
  bool _isLoading = false;

  final List<Map<String, String>> _banks = [
    {'code': '', 'name': 'Cổng thanh toán VNPAYQR'},
    {'code': 'VNPAYQR', 'name': 'Thanh toán qua QR Code'},
    {'code': 'NCB', 'name': 'Ngân hàng NCB'},
    {'code': 'BIDV', 'name': 'Ngân hàng BIDV'},
    {'code': 'VCB', 'name': 'Ngân hàng Vietcombank'},
    {'code': 'MB', 'name': 'Ngân hàng MB'},
    {'code': 'TCB', 'name': 'Ngân hàng Techcombank'},
  ];

  final List<String> _quickAmounts = [
    '50000',
    '100000',
    '200000',
    '500000',
    '1000000',
    '2000000',
    '3000000',
    '4000000',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _startPayment(String amount, {String? bankCode}) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.createVNPAYPayment(
        amount: amount,
        bankCode: bankCode,
      );

      if (!mounted) return;

      if (response["code"] == 200 &&
          response["result"] != null &&
          response["result"]["paymentUrl"] != null) {

        final paymentUrl = response["result"]["paymentUrl"];

        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              paymentUrl: paymentUrl,
              onPaymentComplete: (code, message) {},
            ),
          ),
        );

        if (result != null && result["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nạp thành công ${int.parse(amount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}₫!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          _amountController.clear();
          setState(() => _selectedBank = null);
        } else if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? "Thanh toán thất bại"),
              backgroundColor: Colors.red,
            ),
          );
        }

      } else {
        _showError(response["message"] ?? "Lỗi tạo thanh toán");
      }
    } catch (e) {
      _showError("Lỗi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
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
      appBar: AppBar(
        title: const Text('Nạp tiền'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User info card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            (widget.user.username ?? "U")[0].toUpperCase(),

                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                          widget.user.fullName?.isNotEmpty == true
                          ? widget.user.fullName!
                              : widget.user.username ?? 'Người dùng',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tiền (VND)',
                    hintText: 'Nhập số tiền cần nạp',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null || amount < 10000) {
                      return 'Số tiền tối thiểu 10,000 VND';
                    }
                    if (amount > 500000000) {
                      return 'Số tiền tối đa 500,000,000 VND';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quick amount buttons
                const Text(
                  'Chọn nhanh:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amount) {
                    return ActionChip(
                      label: Text('${int.parse(amount) ~/ 1000}K'),
                      onPressed: () {
                        _amountController.text = amount;
                      },
                      backgroundColor: Colors.blue[50],
                      labelStyle: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Payment button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      final amount = _amountController.text;
                      _startPayment(amount, bankCode: _selectedBank);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment),
                      SizedBox(width: 8),
                      Text(
                        'Nạp tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
