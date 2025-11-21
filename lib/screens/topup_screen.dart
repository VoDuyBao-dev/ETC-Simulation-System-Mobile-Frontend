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
  String? _selectedBank;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateBalanceAfterPayment() async {
    final info = await ApiService.getMyInfo();
    if (info["code"] == 200 && info["result"] != null) {
      setState(() {
        widget.user.balance =
            double.tryParse(info["result"]["balance"].toString()) ?? 0.0;
      });
    }
  }

  void _startPayment(String amount, {String? bankCode}) async {
    setState(() => _isLoading = true);

    try {
      final response =
          await ApiService.createVNPAYPayment(amount: amount, bankCode: bankCode);

      if (!mounted) return;

      if (response["code"] == 200 &&
          response["result"] != null &&
          response["result"]["paymentUrl"] != null) {
        final paymentUrl = response["result"]["paymentUrl"];

        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              paymentUrl: paymentUrl,
              onPaymentComplete: (code, message) {
                debugPrint("💳 Payment callback: $code - $message");
              },
            ),
          ),
        );

        if (result != null && result["success"] == true) {
          await _updateBalanceAfterPayment();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Nạp thành công ${int.parse(amount).toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => "${m[1]}.",
                    )}₫!",
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
        _showError(response["message"] ?? "Lỗi tạo thanh toán.");
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          (widget.user.username ?? "U")[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.user.fullName?.isNotEmpty == true
                              ? widget.user.fullName!
                              : widget.user.username ?? "Người dùng",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Số tiền (VND)",
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Nhập số tiền";
                  final amount = int.tryParse(v);
                  if (amount == null || amount < 10000) {
                    return "Tối thiểu 10,000 VND";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _startPayment(_amountController.text,
                              bankCode: _selectedBank);
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Nạp tiền"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
