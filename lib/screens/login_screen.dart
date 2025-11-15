import 'package:flutter/material.dart';
import 'package:smarttoll_app/api/api_service.dart';
import 'home_logged_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ==================== GỌI API ĐĂNG NHẬP ====================
  Future<void> _login() async {
    if (_accountController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        username: _accountController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("LOGIN RESPONSE: $response");

      if (response['code'] == 200) {
        if (!mounted) return;

        // ------------ LƯU TOKEN CHO TOÀN APP ------------
        final result = response["result"];
        ApiService.accessToken = result["accessToken"];   // TOKEN BACKEND TRẢ VỀ

        // ------------ THÔNG BÁO ------------
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Đăng nhập thành công')),
        );

        // ------------ CHUYỂN TRANG HOME ------------
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeLoggedScreen(
              userData: {
                "name": result["fullname"] ?? "User",
                "email": result["email"] ?? _accountController.text,
                "balance": result["balance"]?.toString() ?? "0",
              },
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Sai tài khoản hoặc mật khẩu');
      }
    } catch (e) {
      _showError('Không thể kết nối tới máy chủ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==================== SHOW ERROR ====================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Đăng nhập SmartToll',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInput(
                    "Tài khoản hoặc Email",
                    Icons.person_outline,
                    _accountController,
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    "Mật khẩu",
                    Icons.lock_outline,
                    _passwordController,
                    true,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0099FF),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Chưa có tài khoản? Đăng ký ngay",
                      style: TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TEXT INPUT ====================
  Widget _buildInput(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
