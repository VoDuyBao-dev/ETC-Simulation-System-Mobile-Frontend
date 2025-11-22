import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/recharge_screen.dart';
import 'screens/vehicle_screen.dart';

void main() {
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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final email = (args?['email'] as String?)?.trim() ?? '';

          if (email.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không có email để xác minh")));
              Navigator.pushReplacementNamed(context, '/login');
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return OtpScreen(email: email); // Chỉ cần email!
        },
      },
    );
  }
}