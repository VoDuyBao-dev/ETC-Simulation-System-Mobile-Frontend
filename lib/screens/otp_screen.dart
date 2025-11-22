import 'package:flutter/material.dart';
import 'package:smarttoll_app/api/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String email; // Chỉ cần email thôi!

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _timer.cancel();
    super.dispose();
  }

  // === XÁC MINH OTP ===
  Future<void> _verifyOtp() async {
    final otpCode = _otpControllers.map((c) => c.text).join();
    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 số")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.verifyOtp(
        email: widget.email.trim(),
        otpCode: otpCode,
      );

      setState(() => _isLoading = false);

      if (response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xác minh thành công!")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "OTP không đúng")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  // === GỬI LẠI OTP – CHỈ CẦN EMAIL ===
  Future<void> _resendOtp() async {
    if (_countdown > 0) return;

    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/auth/otp/resend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.email.trim(), // Chỉ cần cái này!
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() => _isResending = false);

      if (data["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi lại mã OTP! Kiểm tra email nhé")),
        );
        _startCountdown();
        for (var c in _otpControllers) c.clear();
        _focusNodes[0].requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Gửi lại thất bại")),
        );
      }
    } catch (e) {
      setState(() => _isResending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi mạng. Vui lòng thử lại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Xác minh OTP"),
        backgroundColor: const Color(0xFF0099FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text("Nhập mã OTP đã được gửi đến", style: TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(widget.email, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 50),

                // 6 ô OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => SizedBox(
                    width: 50,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.25),
                        contentPadding: const EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white70, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 3)),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (v.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        } else if (i == 5 && v.isNotEmpty) {
                          _focusNodes[i].unfocus();
                        }
                      },
                    ),
                  )),
                ),

                const SizedBox(height: 40),

                // Nút xác minh
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0099FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 8),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF0099FF))
                        : const Text("Xác minh OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                // Gửi lại mã
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Không nhận được mã? ", style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: _countdown > 0 || _isResending ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                        _countdown > 0 ? "Gửi lại sau $_countdown giây" : "Gửi lại mã",
                        style: TextStyle(color: _countdown > 0 ? Colors.white60 : Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}