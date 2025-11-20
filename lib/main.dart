import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/recharge_screen.dart';
import 'screens/vehicle_screen.dart';
import 'screens/topup_screen.dart';
import 'package:smarttoll_app/models/auth_service.dart';
import 'package:smarttoll_app/api/api_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(const SmartTollApp());
}


class SmartTollApp extends StatelessWidget {
  const SmartTollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartToll App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeScreen(),


      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;

          final email = args?['email'] ?? 'demo@example.com';
          return OtpScreen(email: email);
        },

        '/topup': (context) {
          if (AuthService.currentUser == null) {
            // Chưa đăng nhập → đẩy về login
            return const LoginScreen();
          }
          return TopupScreen(user: AuthService.currentUser!);
        },


      },


    );
  }
}
