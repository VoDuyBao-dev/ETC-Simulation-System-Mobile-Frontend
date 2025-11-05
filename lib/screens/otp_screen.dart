import 'package:flutter/material.dart';
import '../services/api_service.dart'; // để gọi verifyOtp() nếu cần

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  // ===================== XÁC MINH OTP =====================
  Future<void> _verifyOtp(String email) async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 ký tự OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔹 Nếu có server thật, bạn dùng:
      // final response = await ApiService.verifyOtp(email, otp);
      // if (response['success']) { ... }

      await Future.delayed(const Duration(seconds: 1)); // Giả lập chờ API
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xác minh OTP thành công!")),
      );

      // Sau khi xác minh, quay về màn hình đăng nhập
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ??
            'demo@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác minh OTP"),
        backgroundColor: const Color(0xFF0099FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text(
                  "Nhập mã OTP được gửi đến $email",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // ===================== 6 Ô NHẬP OTP =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _verifyOtp(email),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : const Text(
                    "Xác minh OTP",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF0099FF),
                    ),
                  ),
                ),
                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
