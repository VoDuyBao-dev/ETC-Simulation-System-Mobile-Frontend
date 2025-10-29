import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart'; // ✅ Thêm màn hình OTP
import 'screens/recharge_screen.dart';

void main() {
  runApp(const SmartTollApp());
}

class SmartTollApp extends StatelessWidget {
  const SmartTollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartToll App', // ✅ Tên app
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // ✅ Trang đầu tiên khi mở app
      home: const HomeScreen(),

      // ✅ Danh sách route (đường dẫn đến các trang)
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (context) => const OtpScreen(), // ✅ Thêm route OTP
        '/recharge': (context) => const RechargeScreen(),
      },
    );
  }
}
