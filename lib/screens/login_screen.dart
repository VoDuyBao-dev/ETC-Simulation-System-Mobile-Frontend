import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpVisible = false; // 👉 Hiện form nhập OTP hay không

  // 🟢 B1: Gửi yêu cầu login để nhận OTP
  Future<void> _login() async {
    if (_accountController.text.isEmpty) {
      _showError('Vui lòng nhập Email hoặc tài khoản');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/smarttoll/api/login.php'),
        body: {'account': _accountController.text},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // 👉 Server gửi OTP đến email / điện thoại
          setState(() => _isOtpVisible = true);
          _showError('Vui lòng nhập mã OTP được gửi tới tài khoản');

          // ✅ CHỈ THÊM DÒNG NÀY: mở sang trang OTP
          Navigator.pushNamed(context, '/otp');
        } else {
          _showError(data['message'] ?? 'Sai thông tin đăng nhập');
        }
      } else {
        _showError('Lỗi máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Không thể kết nối tới máy chủ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🟢 B2: Xác minh OTP
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showError('Vui lòng nhập mã OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/smarttoll/api/verify_otp.php'),
        body: {
          'account': _accountController.text,
          'otp': _otpController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError(data['message'] ?? 'Mã OTP không đúng');
        }
      } else {
        _showError('Lỗi máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Không thể xác minh OTP');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    size: 55,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'SmartToll xin chào!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                if (!_isOtpVisible) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nhập Email hoặc Tài khoản thu phí',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Nhập Email hoặc TK thu phí',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ] else ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nhập mã OTP được gửi tới tài khoản',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã OTP',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isOtpVisible ? _verifyOtp : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isOtpVisible ? 'Xác minh OTP' : 'Đăng nhập',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!_isOtpVisible)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Chưa có tài khoản? Đăng ký ngay",
                      style: TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
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
