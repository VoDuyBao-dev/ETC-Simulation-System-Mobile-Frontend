import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/transaction.dart';

class ApiService {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<User> fetchUser() async {
    final response = await http.get(Uri.parse('$baseUrl/users/1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        balance: 150000.0,
      );
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<Vehicle>> fetchVehicles() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Vehicle(plate: '51A-123.45', type: 'Ô tô'),
      Vehicle(plate: '59C-678.90', type: 'Xe tải'),
    ];
  }

  Future<List<Transaction>> fetchTransactions() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Transaction(date: '2025-10-18', description: 'Nạp tiền ví VETC', amount: 200000),
      Transaction(date: '2025-10-19', description: 'Thanh toán phí cầu đường', amount: -35000),
    ];
  }
}
